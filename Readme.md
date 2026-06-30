# 🌾 AgriIA - Backend API

Backend API construit avec FastAPI permettant d'exposer un chatbot via une API REST.

---

## 🚀 Fonctionnalités

- API REST `/chat`
- Intégration API IA (Mistral ou équivalent)
- Compatible Flutter / Web / Mobile
- Déploiement local + Docker
- Configuration via variables d'environnement

---

## 🧱 Architecture

Client (Flutter / Web)
        ↓
FastAPI Backend
        ↓
API IA externe
        ↓
Réponse JSON

---

## ⚙️ Installation

### 1. Cloner le projet

git clone https://github.com/aymeric-nzore/Neon_code.git
cd Neon_code/chatbot_ai

---

# 🐍 Option 1 — UV (RECOMMANDÉ)

## Installer UV

Linux / Mac :
curl -LsSf https://astral.sh/uv/install.sh | sh

Windows :
irm https://astral.sh/uv/install.ps1 | iex

Lien :
https://github.com/astral-sh/uv

---

## Initialiser environnement

uv venv
source .venv/bin/activate

Windows :
.venv\Scripts\activate

---

## Installer dépendances

uv add fastapi uvicorn httpx python-dotenv

---

## Lancer serveur

uv run uvicorn app:app --reload

---

# 🐍 Option 2 — pip classique

python3 -m venv venv
source venv/bin/activate

pip install fastapi uvicorn httpx python-dotenv

uvicorn app:app --reload

---

# 🐳 Option 3 — Docker

docker build -t chatbot-ai .
docker run -p 8000:8000 --env-file .env chatbot-ai

---

## 🔐 Configuration

Créer un fichier `.env` :

MISTRAL_API_KEY=your_api_key_here

⚠️ Ne jamais pousser ce fichier sur GitHub

---

## 📡 API Endpoint

POST /chat

Request :
{
  "message": "Mon champ de cacao a un problème"
}

Response :
{
  "response": "..."
}

---

## 🧪 Test rapide

curl -X POST http://127.0.0.1:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Comment améliorer mon rendement de riz ?"}'

---

## 📱 Exemple Flutter

final response = await http.post(
  Uri.parse("http://YOUR_IP:8000/chat"),
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({"message": "Mon champ est malade"}),
);

---

## 📦 Dépendances

- FastAPI
- Uvicorn
- HTTPX
- Python-dotenv

---

## 🔒 Sécurité

- Ne jamais commit `.env`
- Toujours utiliser `.gitignore`
- Ne pas exposer la clé API

---

## 🚀 Installation rapide

uv venv
source .venv/bin/activate
uv add fastapi uvicorn httpx python-dotenv
uv run uvicorn app:app --reload