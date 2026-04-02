"""
RAGService — LangChain + ChromaDB pipeline for Indian Wisdom retrieval.

Usage:
  1. Ingest: python scripts/ingest_pdf.py
  2. Retrieve: rag_service.retrieve_context("I feel overwhelmed with work")

Handles Gemini embedding rate-limits by batching chunks and adding
exponential back-off between batches.
"""
import os
import time
from pathlib import Path
from typing import Optional

from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import Chroma
from langchain_google_genai import GoogleGenerativeAIEmbeddings

try:
    from langchain_text_splitters import RecursiveCharacterTextSplitter
except ImportError:
    from langchain.text_splitter import RecursiveCharacterTextSplitter

from config import get_settings

settings = get_settings()

_COLLECTION_NAME = "indian_wisdom"
_vectorstore: Optional[Chroma] = None

# Gemini free-tier embedding: ~300 req/min → 5 chunks per batch, 12s pause
_BATCH_SIZE = 5
_BATCH_PAUSE_SECS = 12


def _get_embeddings() -> GoogleGenerativeAIEmbeddings:
    return GoogleGenerativeAIEmbeddings(
        model="models/gemini-embedding-001",
        google_api_key=settings.gemini_api_key,
    )


def ingest_pdf(pdf_path: Optional[str] = None) -> int:
    """
    Load a PDF, chunk it, embed with Gemini in batches, persist to ChromaDB.
    Automatically retries on rate-limit errors with exponential back-off.
    Returns the number of chunks stored.
    """
    global _vectorstore
    path = pdf_path or settings.wisdom_pdf_path

    if not Path(path).exists():
        raise FileNotFoundError(
            f"PDF not found at '{path}'. "
            "Place your Indian Wisdom PDF at backend/data/wisdom.pdf "
            "or set WISDOM_PDF_PATH in .env."
        )

    print(f"   Loading PDF: {path}")
    loader = PyPDFLoader(path)
    docs = loader.load()
    print(f"   Pages loaded: {len(docs)}")

    splitter = RecursiveCharacterTextSplitter(
        chunk_size=600,        # smaller chunks = fewer tokens per batch
        chunk_overlap=80,
        separators=["\n\n", "\n", "।", ".", " "],
    )
    chunks = splitter.split_documents(docs)
    print(f"   Chunks to embed: {len(chunks)}")

    embeddings = _get_embeddings()

    # ── Batched ingestion with rate-limit back-off ────────────────────
    # First batch creates the store; subsequent batches add to it.
    _vectorstore = None
    persist_dir = settings.chroma_persist_dir

    for i in range(0, len(chunks), _BATCH_SIZE):
        batch = chunks[i: i + _BATCH_SIZE]
        batch_num = i // _BATCH_SIZE + 1
        total_batches = (len(chunks) + _BATCH_SIZE - 1) // _BATCH_SIZE
        print(f"   Embedding batch {batch_num}/{total_batches} ({len(batch)} chunks)…")

        retry = 0
        while True:
            try:
                if _vectorstore is None:
                    _vectorstore = Chroma.from_documents(
                        documents=batch,
                        embedding=embeddings,
                        collection_name=_COLLECTION_NAME,
                        persist_directory=persist_dir,
                    )
                else:
                    _vectorstore.add_documents(batch)
                break  # success
            except Exception as exc:
                err = str(exc)
                if "RESOURCE_EXHAUSTED" in err or "quota" in err.lower():
                    wait = _BATCH_PAUSE_SECS * (2 ** retry)
                    print(f"   ⏳ Rate limit hit — waiting {wait}s before retry…")
                    time.sleep(wait)
                    retry += 1
                    if retry > 5:
                        raise RuntimeError(
                            "Exceeded max retries on embedding rate limit. "
                            "Wait a few minutes and re-run the ingestion."
                        ) from exc
                else:
                    raise

        # Polite pause between batches
        if i + _BATCH_SIZE < len(chunks):
            time.sleep(_BATCH_PAUSE_SECS)

    if _vectorstore:
        _vectorstore.persist()

    print(f"   ✅ Persisted {len(chunks)} chunks to {persist_dir}")
    return len(chunks)


def retrieve_context(query: str, top_k: Optional[int] = None) -> str:
    """
    Retrieve the most relevant wisdom passages for a given query.
    Returns a single concatenated string for injection into a prompt.
    """
    global _vectorstore
    k = top_k or settings.rag_top_k

    # Lazy-load from persisted store
    if _vectorstore is None:
        persist_dir = settings.chroma_persist_dir
        if not Path(persist_dir).exists() or not os.listdir(persist_dir):
            return ""  # No index yet — gracefully degrade
        embeddings = _get_embeddings()
        _vectorstore = Chroma(
            collection_name=_COLLECTION_NAME,
            embedding_function=embeddings,
            persist_directory=persist_dir,
        )

    try:
        docs = _vectorstore.similarity_search(query, k=k)
    except Exception:
        return ""

    if not docs:
        return ""

    combined = "\n\n---\n\n".join(d.page_content for d in docs)
    return combined
