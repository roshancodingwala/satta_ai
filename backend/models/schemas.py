from pydantic import BaseModel, Field
from typing import Optional, Literal


# ── Emotion Analysis ─────────────────────────────────────────────────────

class EmotionTextRequest(BaseModel):
    text: str = Field(..., min_length=2, max_length=5000, description="User's emotional expression in text")


class EmotionResponse(BaseModel):
    primary_emotion: str = Field(..., description="Detected primary emotion, e.g. 'anxiety', 'sadness'")
    stress_level: int = Field(..., ge=0, le=10, description="Stress level from 0 (calm) to 10 (crisis)")
    energy_frequency: str = Field(..., description="Qualitative energy level: 'low' | 'medium' | 'high'")
    emotion_detail: Optional[str] = Field(None, description="Brief explanation of emotional analysis")
    is_crisis: bool = Field(False, description="True if crisis keywords were detected")


# ── Wisdom / Story Reframing ─────────────────────────────────────────────

class WisdomRequest(BaseModel):
    stressor: str = Field(..., min_length=5, max_length=2000)
    emotion: Optional[str] = Field(None, description="Primary emotion detected from prior analysis")
    stress_level: Optional[int] = Field(None, ge=0, le=10)


class WisdomResponse(BaseModel):
    fable: str = Field(..., description="3-paragraph Panchatantra-style fable")
    niti: str = Field(..., description="The moral / Niti of the fable")
    rag_context_used: bool = Field(False, description="Whether RAG context was injected")
    is_crisis: bool = Field(False)
    helplines: list[dict] = Field(default_factory=list)


# ── Raaga Recommendation ─────────────────────────────────────────────────

class RaagaResponse(BaseModel):
    raaga_name: str
    instrument: str
    mood_descriptor: str
    stress_range: str
    asset_key: str  # Used by Flutter to load local audio asset
    description: str


# ── Safety / Crisis ──────────────────────────────────────────────────────

class CrisisInfo(BaseModel):
    is_crisis: bool
    helplines: list[dict]


# ── Health Check ─────────────────────────────────────────────────────────

class HealthResponse(BaseModel):
    status: str
    app: str
    version: str
