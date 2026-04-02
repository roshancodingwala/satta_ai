# 🕉️ SattvaAI — AI Mental Wellness App

> **तनाव को पहचानें · शांति को पाएं**  
> *Recognize Stress · Find Peace*

SattvaAI is a cross-platform mental wellness application that blends **Google Gemini multimodal AI** with **Indian Classical Wisdom** — Panchatantra fables, Raaga therapy, and Mandala breathing — to provide culturally grounded emotional support.

---

## ✨ Features

| Module | Description |
|---|---|
| 🧠 **Multimodal Emotion Analysis** | Gemini 1.5 Flash analyses text or voice for `primary_emotion`, `stress_level` (0–10), `energy_frequency` |
| 📖 **Panchatantra Wisdom Engine** | RAG-powered story reframing — your stressor becomes a 3-paragraph fable ending with a *Niti* (moral) |
| 🎵 **Raaga Therapy** | Stress level maps to an Indian Classical Raaga (Ahir Bhairav, Yaman, Bilawal, Bhupali) |
| 🌸 **Mandala Breathing** | Flutter `CustomPainter` Mandala driven by a 4-7-8 breathing `Stream` |
| 🚨 **Crisis Safety System** | Keyword + Gemini crisis detection → instant display of Indian helplines (iCall, Vandrevala, NIMHANS) |

---

## 🏗️ Project Structure

```
AI Based Mental Wellness/
├── backend/                    ← FastAPI (Python 3.11+)
│   ├── main.py                 ← App entry, CORS, router registration
│   ├── config.py               ← Pydantic-settings (.env loader)
│   ├── requirements.txt
│   ├── .env.example            ← Copy to .env and fill in keys
│   ├── data/
│   │   └── wisdom.pdf          ← Place your Indian Wisdom PDF here
│   ├── models/
│   │   └── schemas.py          ← Pydantic request/response models
│   ├── routers/
│   │   ├── emotion.py          ← POST /emotion/analyze-vibe
│   │   ├── wisdom.py           ← POST /wisdom/wisdom-reframe
│   │   ├── raagas.py           ← GET  /raagas/raaga-recommendation
│   │   └── rag.py              ← POST /rag/ingest, GET /rag/status
│   ├── services/
│   │   ├── gemini_service.py   ← Gemini text + audio multimodal
│   │   ├── rag_service.py      ← LangChain + ChromaDB RAG
│   │   ├── story_service.py    ← Panchatantra fable generator
│   │   ├── raaga_service.py    ← Stress → Raaga mapping
│   │   └── safety_service.py   ← Crisis detection + helplines
│   └── scripts/
│       └── ingest_pdf.py       ← CLI: python scripts/ingest_pdf.py
│
└── frontend/                   ← Flutter (Dart)
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── theme/app_theme.dart
        ├── providers/emotion_provider.dart
        ├── services/api_service.dart
        ├── screens/
        │   ├── home_screen.dart
        │   ├── checkin_screen.dart
        │   ├── result_screen.dart
        │   └── crisis_screen.dart
        └── widgets/
            ├── mandala_painter.dart   ← CustomPainter + BreathingController
            └── breathing_timer.dart   ← Standalone BreathingTimerWidget
```

---

## 🚀 Setup & Running

### Prerequisites

| Tool | Version | Install |
|---|---|---|
| Python | 3.11+ | [python.org](https://python.org) |
| Flutter SDK | 3.19+ | [flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows) |
| Android Studio / Xcode | Latest | For device emulation |
| Gemini API Key | — | [aistudio.google.com](https://aistudio.google.com/app/apikey) |

---

### Step 1 — Backend Setup

```powershell
cd "AI Based Mental Wellness\backend"

# 1. Create virtualenv (recommended)
python -m venv venv
.\venv\Scripts\Activate.ps1

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure environment
Copy-Item .env.example .env
# Open .env and set GEMINI_API_KEY=your_key_here

# 4. Start server
uvicorn main:app --reload --port 8000
```

Open **http://localhost:8000/docs** to explore all endpoints in Swagger UI.

---

### Step 2 — RAG Knowledge Base (Optional but Recommended)

```powershell
# Place any Indian Wellness PDF at:
#   backend/data/wisdom.pdf
# Examples: Panchatantra, Bhagavad Gita excerpts, Yoga Sutras, Ayurvedic texts

python scripts/ingest_pdf.py

# Or ingest via API:
# POST http://localhost:8000/rag/ingest  (upload the PDF as form-data)
```

---

### Step 3 — Flutter App Setup

```powershell
# Install Flutter SDK first: https://docs.flutter.dev/get-started/install/windows

cd "AI Based Mental Wellness\frontend"

flutter pub get

# For Android emulator (uses 10.0.2.2 → your machine's localhost):
flutter run

# For physical device — update lib/services/api_service.dart:
#   static const String _baseUrl = 'http://YOUR_LOCAL_IP:8000';
```

---

## 🔌 API Reference

### `GET /health`
```json
{ "status": "ok", "app": "SattvaAI", "version": "1.0.0" }
```

### `POST /emotion/analyze-vibe`
**Form-data:** `text` (string) *or* `audio` (file)

```json
{
  "primary_emotion": "anxiety",
  "stress_level": 7,
  "energy_frequency": "low",
  "emotion_detail": "The user shows signs of overwhelm and mental fatigue.",
  "is_crisis": false
}
```

### `GET /raagas/raaga-recommendation?stress_level=8`
```json
{
  "raaga_name": "Raaga Ahir Bhairav",
  "instrument": "Bansuri (Flute)",
  "mood_descriptor": "Soothing dawn calm — dissolves acute anxiety",
  "stress_range": "High (8–10)",
  "asset_key": "ahir_bhairav",
  "description": "Ahir Bhairav is a morning raaga..."
}
```

### `POST /wisdom/wisdom-reframe`
**Body:** `{ "stressor": "I keep failing at work", "emotion": "hopeless" }`

```json
{
  "fable": "In a forest at the edge of the world lived a tortoise...",
  "niti": "Persistence in the face of failure is the seed of mastery.",
  "rag_context_used": true,
  "is_crisis": false,
  "helplines": []
}
```

### `POST /rag/ingest` — Upload PDF to build knowledge base
### `GET /rag/status` — Check if index is ready

---

## 🛡️ Ethical Safeguards

- **Crisis gate runs first** on every endpoint — before any AI call
- **No audio storage** — bytes are processed in-memory and discarded
- **4 verified Indian helplines**: iCall (TISS), Vandrevala Foundation, NIMHANS, iMind
- Fable generation is **bypassed** when crisis is detected

---

## 🗺️ Raaga Stress Mapping

| Stress Level | Raaga | Instrument | Effect |
|---|---|---|---|
| 8–10 | Ahir Bhairav | Bansuri (Flute) | Dissolves acute anxiety |
| 5–7 | Yaman | Sitar | Eases restlessness |
| 3–4 | Bilawal | Sitar | Lifts low energy |
| 0–2 | Bhupali | Bansuri (Flute) | Celebrates inner calm |

---

## 🔮 Future Enhancements

- [ ] Firebase Auth + Firestore session logging
- [ ] Real Raaga audio assets (audio/ directory)
- [ ] Pinecone cloud vector DB (replace local ChromaDB)
- [ ] Multilingual support (Hindi, Tamil, Bengali)
- [ ] Wearable integration (heart rate → stress level override)
- [ ] Guided meditation sessions with Mandala + Raaga combined
