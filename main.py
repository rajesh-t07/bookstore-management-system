from fastapi import FastAPI, Request
import time
import logging
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from prometheus_client import REGISTRY
from fastapi.responses import Response

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(title="BookStore API", version="1.0.0")

# Prometheus metrics
REQUEST_COUNT = Counter('bookstore_requests_total', 'Total number of requests', ['method', 'endpoint', 'http_status'])
REQUEST_LATENCY = Histogram('bookstore_request_latency_seconds', 'Request latency', ['endpoint'])

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time

    REQUEST_COUNT.labels(request.method, request.url.path, response.status_code).inc()
    REQUEST_LATENCY.labels(request.url.path).observe(process_time)

    logger.info(f"{request.method} {request.url.path} completed in {process_time:.4f}s")
    return response

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/books")
def get_books():

    books = [
        {"id": 1, "title": "The Pragmatic Programmer", "author": "Andrew Hunt"},
        {"id": 2, "title": "Clean Code", "author": "Robert C. Martin"},
        {"id": 3, "title": "Designing Data-Intensive Applications", "author": "Martin Kleppmann"}
    ]
    return {"books": books}

@app.get("/simulate_latency")
def simulate_latency(ms: int = 200):
    time.sleep(ms / 1000.0)
    return {"message": f"Simulated {ms}ms latency"}

@app.get("/metrics")
def metrics():
    data = generate_latest(REGISTRY)
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)
