"""
Router: /rag
Utility endpoints for managing the RAG knowledge base.
"""
import os
from fastapi import APIRouter, HTTPException, UploadFile, File
from pydantic import BaseModel
from services.rag_service import ingest_pdf, retrieve_context
from config import get_settings

settings = get_settings()
router = APIRouter()


class RetrieveRequest(BaseModel):
    query: str
    top_k: int = 4


class IngestResponse(BaseModel):
    success: bool
    chunks_stored: int
    message: str


@router.post("/ingest", response_model=IngestResponse, )
async def ingest_pdf_endpoint(file: UploadFile = File(...)):
    """
    Upload a PDF and ingest it into the ChromaDB vector database.
    This replaces any existing index.
    """
    if not file.filename.endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are accepted.")

    # Save upload to data dir temporarily
    save_path = os.path.join(settings.chroma_persist_dir, "..", "wisdom.pdf")
    save_path = os.path.normpath(save_path)
    os.makedirs(os.path.dirname(save_path), exist_ok=True)

    content = await file.read()
    with open(save_path, "wb") as f:
        f.write(content)

    try:
        count = ingest_pdf(save_path)
        return IngestResponse(
            success=True,
            chunks_stored=count,
            message=f"Successfully ingested {count} chunks into ChromaDB.",
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@router.post("/retrieve", )
async def retrieve_context_endpoint(req: RetrieveRequest):
    """
    Retrieve the most relevant wisdom passages for a given query.
    Useful for testing the RAG pipeline independently.
    """
    context = retrieve_context(req.query, top_k=req.top_k)
    if not context:
        return {"context": "", "message": "No index found. Please ingest a PDF first."}
    return {"context": context, "chunks": req.top_k}


@router.get("/status")
async def rag_status():
    """Check whether the ChromaDB index exists and has data."""
    persist_dir = settings.chroma_persist_dir
    exists = os.path.isdir(persist_dir) and bool(os.listdir(persist_dir))
    return {
        "index_ready": exists,
        "persist_dir": persist_dir,
        "wisdom_pdf_path": settings.wisdom_pdf_path,
    }
