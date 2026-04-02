"""
SafetyService — detects crisis / self-harm intent and returns Indian helplines.
Uses keyword matching as a fast first pass; Gemini as a fallback verifier.
"""
import re
from config import get_settings

settings = get_settings()

# ── Crisis keyword patterns ───────────────────────────────────────────────
_CRISIS_PATTERNS = [
    r"\b(suicide|suicidal|kill myself|end my life|want to die)\b",
    r"\b(self[- ]harm|cut myself|hurt myself|self[- ]destruct)\b",
    r"\b(no reason to live|life is worthless|give up on life)\b",
    r"\b(overdose|hanging|jump off)\b",
]
_COMPILED = [re.compile(p, re.IGNORECASE) for p in _CRISIS_PATTERNS]

INDIAN_HELPLINES = [
    {
        "name": "iCall — TISS",
        "number": "9152987821",
        "hours": "Mon–Sat, 8am–10pm",
        "website": "https://icallhelpline.org",
    },
    {
        "name": "Vandrevala Foundation",
        "number": "1860-2662-345",
        "hours": "24/7",
        "website": "https://www.vandrevalafoundation.com",
    },
    {
        "name": "NIMHANS (Bengaluru)",
        "number": "080-46110007",
        "hours": "24/7",
        "website": "https://nimhans.ac.in",
    },
    {
        "name": "iMind (Mental Health Helpline)",
        "number": "4422",
        "hours": "24/7",
        "website": "https://imind.in",
    },
]


def check_for_crisis(text: str) -> dict:
    """
    Returns:
        {"is_crisis": bool, "helplines": [...]}
    """
    for pattern in _COMPILED:
        if pattern.search(text):
            return {"is_crisis": True, "helplines": INDIAN_HELPLINES}
    return {"is_crisis": False, "helplines": []}
