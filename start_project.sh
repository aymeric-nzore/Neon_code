#!/bin/bash

# Script de lancement complet de Cacao AI (Azur)
# Conçu pour être autonome et auto-installer toutes les dépendances

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}🌱    Préparation et Lancement du projet Cacao AI   ${NC}"
echo -e "${BLUE}====================================================${NC}"

# Liste des PIDs à stopper à la fermeture
PIDS=()

cleanup() {
  echo -e "\n${RED}🛑 Arrêt de tous les services en cours...${NC}"
  for pid in "${PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      echo -e "   - Processus $pid arrêté."
    fi
  done
  exit 0
}

# Attacher le nettoyage à l'interruption (Ctrl+C) et la sortie
trap cleanup SIGINT SIGTERM EXIT

# --------------------------------------------------
# ÉTAPE 0 : VÉRIFICATION ET INSTALLATION DES DÉPENDANCES
# --------------------------------------------------
echo -e "\n${YELLOW}⚙️ Étape 0 : Vérification et installation des dépendances...${NC}"

# Vérifier Python3
if ! command -v python3 &> /dev/null; then
  echo -e "${RED}❌ Erreur : python3 n'est pas disponible sur ce système. Veuillez l'installer.${NC}"
  exit 1
fi

setup_python_env() {
  local folder_path=$1
  echo -e "\n${BLUE}📦 Configuration de l'API dans : $folder_path...${NC}"
  cd "$folder_path" || exit 1
  
  if [ ! -d ".venv" ]; then
    echo -e "   - Création de l'environnement virtuel (.venv)..."
    python3 -m venv .venv
  fi
  
  # Activation du venv pour installer les dépendances
  source .venv/bin/activate
  echo -e "   - Installation / mise à jour des packages depuis requirements.txt..."
  pip install --upgrade pip
  if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
  else
    echo -e "${RED}   - [ATTENTION] Aucun fichier requirements.txt trouvé dans $folder_path.${NC}"
  fi
  deactivate
  cd ..
}

# Configurer l'API d'analyse et prédictions
setup_python_env "/home/aymeric/Documents/Neon_code/analyse_ai"

# Configurer l'API Chatbot
setup_python_env "/home/aymeric/Documents/Neon_code/chatbot_ai"

# Configurer le frontend Flutter
echo -e "\n${BLUE}📦 Récupération des packages Flutter (pub get)...${NC}"
cd "/home/aymeric/Documents/Neon_code/cacao_ai_flutter" || exit 1
flutter pub get
cd ..

echo -e "\n${GREEN}✅ Toutes les dépendances sont prêtes !${NC}"

# --------------------------------------------------
# ÉTAPE 1 : LANCEMENT DES APIS ET FRONTEND
# --------------------------------------------------

# 1. Lancement de l'API d'analyse et prédiction (Port 8000)
echo -e "\n${YELLOW}1. Démarrage de l'API de prédiction (analyse_ai) sur le port 8000...${NC}"
cd "/home/aymeric/Documents/Neon_code/analyse_ai" || exit 1
source .venv/bin/activate
uvicorn api.main:app --port 8000 --reload > uvicorn_analyse.log 2>&1 &
PREDICT_PID=$!
PIDS+=($PREDICT_PID)
deactivate
echo -e "${GREEN}   - API de prédiction démarrée (PID: $PREDICT_PID) | Logs -> analyse_ai/uvicorn_analyse.log${NC}"

# 2. Lancement du Chatbot AI (Port 8001)
echo -e "\n${YELLOW}2. Démarrage du Chatbot AI (chatbot_ai) sur le port 8001...${NC}"
cd "/home/aymeric/Documents/Neon_code/chatbot_ai" || exit 1
source .venv/bin/activate
uvicorn app:app --port 8001 --reload > uvicorn_chatbot.log 2>&1 &
CHATBOT_PID=$!
PIDS+=($CHATBOT_PID)
deactivate
echo -e "${GREEN}   - Chatbot AI démarré (PID: $CHATBOT_PID) | Logs -> chatbot_ai/uvicorn_chatbot.log${NC}"

# Laisser un peu de temps d'init aux APIs
sleep 2

# 3. Lancement du frontend Flutter (Port 8080)
echo -e "\n${YELLOW}3. Démarrage du Frontend Flutter (cacao_ai_flutter) sur le port 8080...${NC}"
echo -e "${YELLOW}   (Le terminal interactif Flutter va se lancer ci-dessous)${NC}\n"
cd "/home/aymeric/Documents/Neon_code/cacao_ai_flutter" || exit 1
flutter run -d web-server --web-port 8080
