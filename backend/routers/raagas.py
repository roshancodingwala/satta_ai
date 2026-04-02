"""
Router: /raagas
Endpoint: GET /raagas/raaga-recommendation?stress_level=N
Returns the Indian Classical Raaga profile mapped to the given stress level.
"""
from fastapi import APIRouter, Query
from models.schemas import RaagaResponse
from services.raaga_service import get_raaga_for_stress

router = APIRouter()


@router.get("/raaga-recommendation", response_model=RaagaResponse)
async def raaga_recommendation(
    stress_level: int = Query(..., ge=0, le=10, description="Stress level from 0 (calm) to 10 (acute)"),
):
    """
    Returns a Raaga therapy recommendation based on the user's stress level.

    Mapping:
    - 8-10 → Raaga Ahir Bhairav (Flute) — dissolves acute anxiety
    - 5-7  → Raaga Yaman (Sitar) — eases restlessness
    - 3-4  → Raaga Bilawal (Sitar) — lifts low energy
    - 0-2  → Raaga Bhupali (Flute) — celebrates inner calm
    """
    raaga = get_raaga_for_stress(stress_level)
    return RaagaResponse(**raaga)


@router.get("/all-raagas")
async def all_raagas():
    """Returns the complete Raaga therapy catalogue."""
    from services.raaga_service import RAAGA_MAP
    return [
        {k: v for k, v in entry.items() if k != "range"}
        for entry in RAAGA_MAP
    ]
