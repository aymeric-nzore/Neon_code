from fastapi import FastAPI

from api.schemas import SensorInput

from api.agent.model_loader import load_artifacts
from api.agent.utils import predict_risk
from api.agent.agent import CacaoRiskAgent


# ==========================================================
# Initialisation
# ==========================================================

app = FastAPI(
    title="Cacao AI API",
    version="1.0.0",
    description="API de prédiction des maladies du cacao"
)

# Chargement du modèle une seule fois
model, scaler_x, scaler_y, config = load_artifacts()

# Initialisation de l'agent
agent = CacaoRiskAgent(model)


# ==========================================================
# Routes
# ==========================================================

@app.get("/")
def health():
    return {
        "status": "online",
        "model_loaded": True
    }


@app.post("/predict")
def predict(data: SensorInput):

    # -----------------------------
    # 1. Prédiction Machine Learning
    # -----------------------------

    prediction = predict_risk(
        model=model,
        scaler_x=scaler_x,
        scaler_y=scaler_y,
        data=data,
        features=config["features"]
    )

    # -----------------------------
    # 2. Agent IA
    # -----------------------------

    agent_result = agent.run(
        plantation_id=data.plantation_id,
        sensor_data=data.model_dump(),
        prediction=prediction
    )

    # -----------------------------
    # 3. Réponse API
    # -----------------------------

    return {
        "status": "success",
        "prediction": prediction,
        "agent": agent_result
    }