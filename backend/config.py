from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # Gemini
    gemini_api_key: str = "YOUR_GEMINI_API_KEY"
    gemini_model: str = "gemini-2.0-flash"

    # ChromaDB / RAG
    chroma_persist_dir: str = "./data/chroma_db"
    wisdom_pdf_path: str = "./data/wisdom.pdf"
    rag_top_k: int = 4

    # App
    debug: bool = False
    app_name: str = "SattvaAI"
    app_version: str = "1.0.0"


@lru_cache
def get_settings() -> Settings:
    return Settings()
