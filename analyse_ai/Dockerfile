# =========================
# 1. BUILD STAGE
# =========================
FROM python:3.12-slim AS builder

WORKDIR /app

# Dépendances système minimales (torch, numpy, etc.)
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Installer dépendances Python
COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install --user --no-cache-dir -r requirements.txt


# =========================
# 2. RUNTIME STAGE
# =========================
FROM python:3.12-slim

WORKDIR /app

# Copie des packages installés
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copier le code
COPY api ./api
COPY models ./models

# Variables Python optimisées
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Port FastAPI
EXPOSE 8000

# Lancer uvicorn
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]