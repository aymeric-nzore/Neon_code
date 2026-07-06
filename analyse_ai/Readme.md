🌱 Cacao AI — API de prédiction et agent intelligent

API basée sur FastAPI + PyTorch + Mistral AI, permettant de :

Prédire le risque de maladies du cacao 🍫
Analyser les données agricoles via IA 🤖
Stocker l’historique des capteurs 📊
Générer des recommandations intelligentes pour les plantations 🌿
🚀 Architecture du projet
analyse_ai/
│
├── api/
│   ├── main.py              # API FastAPI
│   ├── schemas.py          # Validation des données (Pydantic)
│   ├── agent/               # Agent IA
│   │   ├── agent.py
│   │   ├── llm_agent.py     # IA Mistral
│   │   ├── actions.py       # Actions (alertes + DB)
│   │   ├── memory.py        # Historique Supabase
│   │   ├── utils.py         # Prétraitement ML
│   │   ├── model_loader.py  # Chargement modèle PyTorch
│   │   └── worker.py
│
├── models/                  # Modèle ML + scalers
│   ├── cacao_lstm.pth
│   ├── scaler_x.pkl
│   ├── scaler_y.pkl
│   └── model_config.json
│
├── Dockerfile
├── requirements.txt
└── README.md
🧠 Comment fonctionne l’IA ?

Le système est composé de 3 couches intelligentes :

1. 📊 Machine Learning (PyTorch LSTM)
Prédit le risque de maladie du cacao
Sortie :
{
  "risk_today": 0.16,
  "risk_7d": 0.25,
  "risk_14d": 0.34,
  "risk_21d": 0.28
}
2. 🤖 Agent intelligent (Mistral AI)

L’agent :

Analyse les capteurs
Interprète les prédictions ML
Génère un rapport agricole structuré en JSON
Propose des actions concrètes
3. 🧠 Memory + Actions (Supabase)
Stocke les données capteurs
Sauvegarde les prédictions
Analyse les tendances
Déclenche des alertes automatiques
⚙️ Installation
1. Cloner le projet
git clone <repo>
cd analyse_ai
2. Créer l’environnement virtuel
python -m venv .venv
source .venv/bin/activate
3. Installer les dépendances
pip install -r requirements.txt
4. Créer le fichier .env
OPENAI_API_KEY=xxx
MISTRAL_API_KEY=xxx
SUPABASE_URL=xxx
SUPABASE_KEY=xxx
5. Lancer l’API
uvicorn api.main:app --reload
📡 Utilisation de l’API
🔹 Endpoint principal
POST /predict
🔹 Exemple de requête
{
  "plantation_id": "plant_001",
  "temperature_air": 30.2,
  "humidity_air": 95,
  "rainfall": 40,
  "light_intensity": 150,
  "soil_moisture": 80,
  "soil_ph": 4.9
}
🔹 Exemple de réponse
{
  "status": "success",
  "prediction": {
    "risk_today": 0.16,
    "risk_7d": 0.25,
    "risk_14d": 0.34,
    "risk_21d": 0.28
  },
  "agent": {
    "trend": "increasing_risk",
    "alert": {
      "level": "HIGH",
      "message": "Surveillance recommandée"
    },
    "ai_report": {
      "diagnostic": "...",
      "risk_level": "medium",
      "actions": ["...", "..."]
    }
  }
}
🧠 Intelligence de l’agent

L’agent exécute automatiquement :

📥 Sauvegarde des données capteurs
📊 Analyse des tendances historiques
🚨 Déclenchement d’alertes
🤖 Génération de rapport IA (Mistral)
📤 Retour structuré JSON
🚨 Gestion des alertes
Niveau	Condition
CRITICAL	risk_today > 0.7
HIGH	risk_7d > 0.6
MEDIUM	risk_14d > 0.5
LOW	sinon
🧪 Test rapide (.rest)
POST http://127.0.0.1:8000/predict
Content-Type: application/json

{
  "plantation_id": "test_001",
  "temperature_air": 28,
  "humidity_air": 80,
  "rainfall": 20,
  "light_intensity": 120,
  "soil_moisture": 60,
  "soil_ph": 5.2
}
🐳 Docker (optionnel)
docker build -t cacao-ai .
docker run -p 8000:8000 cacao-ai
🔮 Améliorations futures
Dashboard web agricole 📊
Notifications WhatsApp 📱
Mode offline edge IA 🌍
Multi-plantation scaling 🌱
Vision IA (détection maladies sur images) 📸
⚠️ Notes importantes
Nécessite une clé API Mistral valide
Supabase doit être configuré avec tables :
sensor_history
ai_events
Le modèle ML doit être présent dans /models
👨‍🌾 Objectif du projet

Aider les agriculteurs de cacao à :

anticiper les maladies
optimiser les récoltes
réduire les pertes agricoles grâce à l’IA