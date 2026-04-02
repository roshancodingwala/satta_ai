"""
GeminiService — wraps the new Google Gen AI SDK (google-genai) for:
  • Text-based emotion analysis
  • Audio-based (multimodal) emotion analysis
  • Generic text generation (used by story_service)

Includes automatic retry with exponential back-off on quota errors.
"""
import json
import time
import base64
import re

from google import genai
from google.genai import types

from config import get_settings

settings = get_settings()

_client = genai.Client(api_key=settings.gemini_api_key)

EMOTION_SYSTEM_PROMPT = (
    "You are SattvaAI's emotion analyst blending modern psychology with Ayurvedic insight. "
    "Analyse the user's message and respond STRICTLY in valid JSON with these keys:\n"
    '{"primary_emotion": "<single dominant emotion, e.g. anxiety, sadness, anger, joy>", '
    '"stress_level": <integer 0-10>, '
    '"energy_frequency": "<low|medium|high>", '
    '"emotion_detail": "<1-2 sentence empathetic explanation>"}\n'
    "Do NOT include markdown fences or extra text — raw JSON only."
)

_MAX_RETRIES = 4
_BASE_WAIT = 5  # seconds


def _call_with_retry(fn, *args, **kwargs):
    """Call fn(*args, **kwargs) with exponential back-off on 429/RESOURCE_EXHAUSTED."""
    for attempt in range(_MAX_RETRIES):
        try:
            return fn(*args, **kwargs)
        except Exception as exc:
            err = str(exc)
            if "429" in err or "RESOURCE_EXHAUSTED" in err:
                wait = _BASE_WAIT * (2 ** attempt)
                print(f"[GeminiService] Rate limit hit — waiting {wait}s (attempt {attempt+1}/{_MAX_RETRIES})")
                time.sleep(wait)
            else:
                raise
    raise RuntimeError(
        "Gemini API quota exhausted after retries. "
        "Please wait a minute and try again, or upgrade your API plan."
    )


def _parse_emotion_json(raw: str) -> dict:
    """Strip markdown fences and parse JSON robustly."""
    cleaned = re.sub(r"```(?:json)?", "", raw).strip().strip("`").strip()
    return json.loads(cleaned)


def _do_generate(model, contents, config):
    return _client.models.generate_content(
        model=model, contents=contents, config=config
    )


def analyze_text_emotion(text: str) -> dict:
    """Analyse emotion from plain text using Gemini."""
    response = _call_with_retry(
        _do_generate,
        settings.gemini_model,
        text,
        types.GenerateContentConfig(
            system_instruction=EMOTION_SYSTEM_PROMPT,
            temperature=0.3,
        ),
    )
    return _parse_emotion_json(response.text)


def analyze_audio_emotion(audio_bytes: bytes, mime_type: str = "audio/wav") -> dict:
    """Analyse emotion from audio bytes using Gemini multimodal."""
    audio_part = types.Part.from_bytes(data=audio_bytes, mime_type=mime_type)
    prompt = EMOTION_SYSTEM_PROMPT + "\n\nListen to the audio clip and analyse the speaker's emotional state."

    response = _call_with_retry(
        _do_generate,
        settings.gemini_model,
        [audio_part, prompt],
        types.GenerateContentConfig(temperature=0.3),
    )
    return _parse_emotion_json(response.text)


def generate_content(prompt: str) -> str:
    """Generic text generation helper (used by story_service etc.)."""
    response = _call_with_retry(
        _do_generate,
        settings.gemini_model,
        prompt,
        types.GenerateContentConfig(temperature=0.8, max_output_tokens=1024),
    )
    return response.text
