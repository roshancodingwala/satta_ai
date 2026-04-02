"""
Router: /wisdom
Endpoint: POST /wisdom/wisdom-reframe
Generates a Panchatantra fable reframing the user's stressor.
Crisis check is performed first — if triggered, skips fable.
"""
from fastapi import APIRouter, HTTPException
from models.schemas import WisdomRequest, WisdomResponse
from services import safety_service, story_service

router = APIRouter()


@router.post("/wisdom-reframe", response_model=WisdomResponse)
async def wisdom_reframe(req: WisdomRequest):
    """
    RAG + Gemini powered wisdom reframe.
    1) Safety filter — crisis → return helplines immediately.
    2) Retrieve relevant Indian wisdom passages (RAG).
    3) Generate Panchatantra fable + Niti via Gemini.
    """
    # ── Step 1 : Safety check ──────────────────────────────────────────
    safety = safety_service.check_for_crisis(req.stressor)
    if safety["is_crisis"]:
        return WisdomResponse(
            fable="",
            niti="",
            rag_context_used=False,
            is_crisis=True,
            helplines=safety["helplines"],
        )

    # ── Step 2 & 3 : Fable generation ─────────────────────────────────
    try:
        result = story_service.generate_fable(
            stressor=req.stressor,
            emotion=req.emotion or "distressed",
        )
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Story generation failed: {exc}")

    return WisdomResponse(
        fable=result["fable"],
        niti=result["niti"],
        rag_context_used=result["rag_context_used"],
        is_crisis=False,
        helplines=[],
    )
