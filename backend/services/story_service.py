"""
StoryService — Panchatantra-inspired fable generator.

Combines RAG-retrieved wisdom context with Gemini to produce a 3-paragraph
narrative reframe of the user's stressor, ending with a Niti (moral).
"""
from services.gemini_service import generate_content
from services.rag_service import retrieve_context

FABLE_PROMPT_TEMPLATE = """
You are SattvaAI's Wisdom Weaver, a storyteller steeped in Indian classical tradition.
The user is feeling **{emotion}** and their primary stressor is:

"{stressor}"

{rag_section}

Your task:
Write exactly 3 paragraphs as a **Panchatantra-style fable** featuring animals or elements of nature as characters.
The fable must subtly mirror the user's situation and journey toward resolution.
End with a bolded "**Niti:**" line — a single-sentence moral that encourages resilience and inner strength.

Rules:
- Use gentle, evocative, nature-rich language.
- Do NOT mention therapy, doctors, or Western psychology.
- Do NOT name the user or reference modern technology.
- The tone must feel like a wise elder telling a story by firelight.
- Respond in English but you may include one Sanskrit or Hindi phrase (with translation).
- Total response: ~250-350 words.
"""

RAG_SECTION_TEMPLATE = """
Draw upon the following wisdom from ancient Indian texts as inspiration for your fable:
---
{context}
---
"""


def generate_fable(stressor: str, emotion: str = "distressed") -> dict:
    """
    Generate a Panchatantra-style fable + Niti for the given stressor.
    Returns {"fable": str, "niti": str, "rag_context_used": bool}
    """
    # Attempt RAG context retrieval
    context = retrieve_context(f"{stressor} {emotion}")
    rag_section = ""
    rag_used = False

    if context.strip():
        rag_section = RAG_SECTION_TEMPLATE.format(context=context)
        rag_used = True

    prompt = FABLE_PROMPT_TEMPLATE.format(
        emotion=emotion,
        stressor=stressor,
        rag_section=rag_section,
    )

    raw_response = generate_content(prompt)

    # Split Niti from main narrative
    niti = ""
    fable_text = raw_response.strip()

    if "**Niti:**" in fable_text:
        parts = fable_text.split("**Niti:**", 1)
        fable_text = parts[0].strip()
        niti = parts[1].strip().lstrip("—").strip()
    elif "Niti:" in fable_text:
        parts = fable_text.split("Niti:", 1)
        fable_text = parts[0].strip()
        niti = parts[1].strip()

    return {
        "fable": fable_text,
        "niti": niti or "Every storm passes; the tree that bends survives.",
        "rag_context_used": rag_used,
    }
