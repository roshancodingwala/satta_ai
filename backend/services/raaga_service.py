"""
RaagaService — maps a stress level (0-10) to an Indian Classical Raaga.

Mapping philosophy:
  8-10  High anxiety / acute stress → Raaga Ahir Bhairav (Flute) — morning calm
  5-7   Moderate stress / restlessness → Raaga Yaman (Sitar) — evening serenity
  3-4   Low energy / mild sadness → Raaga Bilawal (Sitar) — gentle uplift
  0-2   Calm / peaceful → Raaga Bhupali (Bansuri) — pure joy
"""

RAAGA_MAP = [
    {
        "range": (8, 10),
        "raaga_name": "Raaga Ahir Bhairav",
        "instrument": "Bansuri (Flute)",
        "mood_descriptor": "Soothing dawn calm — dissolves acute anxiety",
        "stress_range": "High (8–10)",
        "asset_key": "ahir_bhairav",
        "description": (
            "Ahir Bhairav is a morning raaga that combines the serenity of Bhairav "
            "with the earthiness of Kafi. Its gentle komal (flat) tones descend like "
            "cool morning mist, calming an overactive nervous system."
        ),
    },
    {
        "range": (5, 7),
        "raaga_name": "Raaga Yaman",
        "instrument": "Sitar",
        "mood_descriptor": "Evening twilight — eases restlessness and overthinking",
        "stress_range": "Moderate (5–7)",
        "asset_key": "yaman",
        "description": (
            "Yaman is one of the most beloved evening raagas. Its teevra (sharp) "
            "Madhyam gives it an expansive, hopeful quality — ideal for softening "
            "mental restlessness and reconnecting with inner peace."
        ),
    },
    {
        "range": (3, 4),
        "raaga_name": "Raaga Bilawal",
        "instrument": "Sitar",
        "mood_descriptor": "Gentle uplift — lifts low energy and mild sadness",
        "stress_range": "Low-Moderate (3–4)",
        "asset_key": "bilawal",
        "description": (
            "Bilawal is a morning raaga that mirrors the natural major scale, "
            "radiating brightness and clarity. It is known to gently lift spirit "
            "and restore gentle optimism without overwhelming the senses."
        ),
    },
    {
        "range": (0, 2),
        "raaga_name": "Raaga Bhupali",
        "instrument": "Bansuri (Flute)",
        "mood_descriptor": "Pure joy and inner stillness — your natural state",
        "stress_range": "Calm (0–2)",
        "asset_key": "bhupali",
        "description": (
            "Bhupali uses only five notes (pentatonic), giving it a timeless, "
            "uncluttered beauty. Associated with Lord Krishna's flute, it evokes "
            "deep contentment and a feeling of being at home within oneself."
        ),
    },
]


def get_raaga_for_stress(stress_level: int) -> dict:
    """Return the Raaga profile matching the given stress level (0-10)."""
    level = max(0, min(10, stress_level))
    for entry in RAAGA_MAP:
        lo, hi = entry["range"]
        if lo <= level <= hi:
            return {k: v for k, v in entry.items() if k != "range"}
    # Fallback
    return {k: v for k, v in RAAGA_MAP[0].items() if k != "range"}
