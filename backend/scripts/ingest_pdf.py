"""
PDF Ingestion Script — run once to build the ChromaDB vector index.

Usage (from the backend/ directory):
    python scripts/ingest_pdf.py
    python scripts/ingest_pdf.py --pdf path/to/custom.pdf

The PDF should contain verified Indian psychological wisdom:
  Panchatantra, Yoga Sutras, Bhagavad Gita excerpts, Ayurvedic wellness texts, etc.
"""
import sys
import os
import argparse

# Ensure the backend root is on the path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.rag_service import ingest_pdf
from config import get_settings

settings = get_settings()


def main():
    parser = argparse.ArgumentParser(description="Ingest a PDF into SattvaAI's RAG vector database.")
    parser.add_argument(
        "--pdf",
        type=str,
        default=settings.wisdom_pdf_path,
        help=f"Path to the PDF file (default: {settings.wisdom_pdf_path})",
    )
    args = parser.parse_args()

    print(f"📖 Starting PDF ingestion from: {args.pdf}")
    try:
        count = ingest_pdf(args.pdf)
        print(f"✅ Success! Stored {count} chunks in ChromaDB at: {settings.chroma_persist_dir}")
    except FileNotFoundError as e:
        print(f"❌ File not found: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Ingestion failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
