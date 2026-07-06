# 🌱 Cacao AI — API de prédiction et agent intelligent

API basée sur **FastAPI**, **PyTorch** et **Mistral AI**, permettant de :

- 🍫 Prédire le risque de maladies du cacao
- 🤖 Analyser les données agricoles grâce à une IA
- 📊 Stocker l'historique des capteurs
- 🌿 Générer des recommandations intelligentes pour les plantations

---

# 🚀 Architecture du projet

```text
analyse_ai/
│
├── api/
│   ├── main.py              # API FastAPI
│   ├── schemas.py           # Validation des données (Pydantic)
│   ├── agent/
│   │   ├── agent.py         # Orchestrateur principal
│   │   ├── llm_agent.py     # IA Mistral
│   │   ├── actions.py       # Alertes + stockage événements
│   │   ├── memory.py        # Historique Supabase
│   │   ├── utils.py         # Prétraitement ML
│   │   ├── model_loader.py  # Chargement du modèle PyTorch
│   │   └── worker.py
│
├── models/
│   ├── cacao_lstm.pth
│   ├── scaler_x.pkl
│   ├── scaler_y.pkl
│   └── model_config.json
│
├── Dockerfile
├── requirements.txt
└── README.md
```

---

# 🧠 Comment fonctionne l'IA ?

Le système est composé de **3 couches intelligentes**.

## 1️⃣ Machine Learning (PyTorch LSTM)

Le modèle LSTM prédit le risque d'apparition de maladies du cacao à différents horizons temporels.

### Exemple de sortie

```json
{
  "risk_today": 0.16,
  "risk_7d": 0.25,
  "risk_14d": 0.34,
  "risk_21d": 0.28
}
```

---

## 2️⃣ Agent intelligent (Mistral AI)

L'agent IA :

- analyse les données des capteurs ;
- interprète les prédictions du modèle ML ;
- génère un rapport agricole structuré au format JSON ;
- propose des recommandations adaptées à la plantation.

---

## 3️⃣ Memory + Actions (Supabase)

L'agent conserve un historique afin de pouvoir :

- 📥 enregistrer les données des capteurs ;
- 📈 sauvegarder les prédictions ;
- 📊 analyser les tendances ;
- 🚨 déclencher automatiquement des alertes.

---

# ⚙️ Installation

## 1. Cloner le projet

```bash
git clone <repository-url>
cd analyse_ai
```

---

## 2. Créer un environnement virtuel

### Linux / macOS

```bash
python -m venv .venv
source .venv/bin/activate
```

### Windows

```powershell
python -m venv .venv
.venv\Scripts\activate
```

---

## 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

---

## 4. Créer le fichier `.env`

```env
MISTRAL_API_KEY=your_api_key

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your_service_role_key
```

> **Remarque :** si vous utilisez OpenAI au lieu de Mistral, ajoutez également :

```env
OPENAI_API_KEY=your_api_key
```

---

## 5. Lancer l'API

```bash
uvicorn api.main:app --reload
```

L'API sera disponible sur :

```
http://127.0.0.1:8000
```

---

# 📡 Utilisation de l'API

## Endpoint principal

```http
POST /predict
```

---

## Exemple de requête

```json
{
  "plantation_id": "plant_001",
  "temperature_air": 30.2,
  "humidity_air": 95,
  "rainfall": 40,
  "light_intensity": 150,
  "soil_moisture": 80,
  "soil_ph": 4.9
}
```

---

## Exemple de réponse

```json
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
      "actions": [
        "...",
        "..."
      ]
    }
  }
}
```

---

# 🤖 Intelligence de l'agent

À chaque requête, l'agent exécute automatiquement les étapes suivantes :

1. 📥 Sauvegarde des données des capteurs
2. 📊 Analyse de l'historique de la plantation
3. 📈 Détection des tendances
4. 🚨 Déclenchement éventuel d'une alerte
5. 🤖 Génération d'un rapport IA avec Mistral
6. 📤 Retour d'une réponse JSON structurée

---

# 🚨 Gestion des alertes

| Niveau | Condition |
|---------|-----------|
| 🔴 CRITICAL | `risk_today > 0.70` |
| 🟠 HIGH | `risk_7d > 0.60` |
| 🟡 MEDIUM | `risk_14d > 0.50` |
| 🟢 LOW | Sinon |

---

# 🧪 Test rapide (.rest)

```http
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
```

---

# 🐳 Docker

## Construire l'image

```bash
docker build -t cacao-ai .
```

## Lancer le conteneur

```bash
docker run --env-file .env -p 8000:8000 cacao-ai
```

---

# 🔮 Améliorations futures

- 📊 Dashboard web agricole
- 📱 Notifications WhatsApp
- 🌍 Fonctionnement offline (Edge AI)
- 🌱 Gestion de plusieurs plantations
- 📸 Détection des maladies sur images (Computer Vision)
- 📡 Intégration avec objets connectés (IoT)

---

# ⚠️ Notes importantes

- Une clé API **Mistral** valide est nécessaire.
- Supabase doit contenir les tables :
  - `sensor_history`
  - `ai_events`
- Le dossier `models/` doit contenir :
  - `cacao_lstm.pth`
  - `scaler_x.pkl`
  - `scaler_y.pkl`
  - `model_config.json`

---

# 👨‍🌾 Objectif du projet

Ce projet vise à aider les producteurs de cacao à :

- 🌱 anticiper les maladies ;
- 📈 optimiser les rendements ;
- 💰 réduire les pertes agricoles ;
- 🤖 bénéficier de recommandations intelligentes basées sur l'intelligence artificielle.
