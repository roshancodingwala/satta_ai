"""
Router: /emotion
Endpoint: POST /emotion/analyze-vibe
Accepts text or audio file, returns emotion analysis via Gemini.
"""
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional

from models.schemas import EmotionResponse
from services import gemini_service, safety_service

router = APIRouter()


@router.post("/analyze-vibe", response_model=EmotionResponse)
async def analyze_vibe(
    text: Optional[str] = Form(None, description="User's emotional expression in text"),
    audio: Optional[UploadFile] = File(None, description="Audio file (wav/mp3/ogg)"),
):
    """
    Multimodal emotion analysis endpoint.
    Provide either 'text' (form field) or 'audio' (file upload) — not both.
    Returns primary_emotion, stress_level (0-10), energy_frequency.
    """
    if not text and not audio:
        raise HTTPException(
            status_code=422,
            detail="Provide either 'text' or 'audio' in the request.",
        )

    try:
        if audio:
            audio_bytes = await audio.read()
            mime = audio.content_type or "audio/wav"
            result = gemini_service.analyze_audio_emotion(audio_bytes, mime)
        else:
            result = gemini_service.analyze_text_emotion(text)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Gemini analysis failed: {exc}")

    # Safety check on original text (or placeholder for audio)
    check_text = text or "audio input"
    safety = safety_service.check_for_crisis(check_text)

    return EmotionResponse(
        primary_emotion=result.get("primary_emotion", "unknown"),
        stress_level=int(result.get("stress_level", 5)),
        energy_frequency=result.get("energy_frequency", "medium"),
        emotion_detail=result.get("emotion_detail"),
        is_crisis=safety["is_crisis"],
    )
