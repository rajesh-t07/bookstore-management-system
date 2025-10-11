# 📚 BookStore API — Phase 1 (SRE Hands-on)

A simple FastAPI-based microservice exposing Prometheus metrics.

## 🚀 Run Locally (Python)
```bash
python3 -m venv venv
source venv/bin/activate # or venv\\Scripts\\activate on Windows
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload