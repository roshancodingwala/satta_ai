"""
SattvaAI — FastAPI Entry Point
──────────────────────────────
Registers all routers, CORS middleware, and the /health endpoint.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import get_settings
from routers import emotion, wisdom, raagas, rag

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description=(
        "SattvaAI — AI-powered emotional wellness backed by Indian Classical Wisdom. "
        "Combines Google Gemini multimodal analysis with Panchatantra-inspired narrative "
        "reframing, Raaga therapy, and Mandala breathing."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS ─────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],       # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ───────────────────────────────────────────────────────────────
app.include_router(emotion.router, prefix="/emotion", tags=["Emotion Analysis"])
app.include_router(wisdom.router, prefix="/wisdom", tags=["Wisdom Engine"])
app.include_router(raagas.router, prefix="/raagas", tags=["Raaga Therapy"])
app.include_router(rag.router, prefix="/rag", tags=["RAG Knowledge Base"])


# ── Health Check ─────────────────────────────────────────────────────────
@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "ok",
        "app": settings.app_name,
        "version": settings.app_version,
    }


# ── Root ─────────────────────────────────────────────────────────────────
@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "🙏 Welcome to SattvaAI — तनाव को पहचानें, शांति को पाएं",
        "docs": "/docs",
    }
