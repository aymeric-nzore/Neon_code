import httpx
import os
from dotenv import load_dotenv
import json
load_dotenv()

def safe_json_parse(text: str):
    try:
        # suppression des blocs markdown éventuels
        text = text.replace("```json", "").replace("```", "").strip()
        return json.loads(text)
    except Exception:
        return {
            "diagnostic": "parse_error",
            "risk_level": "unknown",
            "risks": {},
            "analysis": {},
            "actions": [],
            "alert": {
                "active": False,
                "message": "LLM parse failed"
            }
        }

class LLMCacaoAgent:

    def __init__(self):
        self.api_key = os.getenv("MISTRAL_API_KEY")
        self.base_url = "https://api.mistral.ai/v1/chat/completions"
        if not self.api_key:
            raise ValueError("MISTRAL_API_KEY manquante dans .env")


    def generate_report(self, prediction, sensor_data):
        """
        Génère une analyse agricole intelligente
        """

        prompt = f"""
        Tu es un expert agronome spécialisé dans la culture du cacao en Côte d'Ivoire.

        Analyse ces données :

        CAPTEURS:
        - température: {sensor_data['temperature_air']}
        - humidité: {sensor_data['humidity_air']}
        - pluie: {sensor_data['rainfall']}
        - lumière: {sensor_data['light_intensity']}
        - humidité sol: {sensor_data['soil_moisture']}
        - pH sol: {sensor_data['soil_ph']}

        PRÉDICTIONS ML:
        - risque aujourd'hui: {prediction['risk_today']}
        - risque 7 jours: {prediction['risk_7d']}
        - risque 14 jours: {prediction['risk_14d']}
        - risque 21 jours: {prediction['risk_21d']}

        Donne:
        1. Diagnostic clair
        2. Niveau de danger (faible, moyen, élevé)
        3. Actions concrètes à faire dans une plantation
        4. Alerte si urgence

        Tu DOIS répondre uniquement en JSON valide.

        FORMAT OBLIGATOIRE:
        {
            "diagnostic": "string court",
            "risk_level": "low | medium | high",
            "risks": {
                "today": float,
                "7d": float,
                "14d": float,
                "21d": float
            },
            "analysis": {
                "temperature": "string",
                "humidity": "string",
                "soil": "string"
            },
            "actions": [
                "action 1",
                "action 2",
                "action 3"
            ],
            "alert": {"active": true,
                "message": "string court"
            }
        }

            RÈGLES:
            - JSON strict uniquement
            - pas de markdown
            - pas de texte hors JSON
            - pas d'explication 
        """

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        payload = {
            "model": "mistral-small-latest",
            "messages": [
                {"role": "system", "content": "Expert agronome IA."},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.3
        }

        try:
            response = httpx.post(
                self.base_url,
                headers=headers,
                json=payload,
                timeout=30
            )

            response.raise_for_status()

            data = response.json()

            content = data["choices"][0]["message"]["content"]
            return safe_json_parse(content)
        except Exception as e:
            print(f"[Mistral API] Erreur lors de l'appel LLM: {e}")
            return {
                "diagnostic": "api_error",
                "risk_level": "unknown",
                "risks": {
                    "today": prediction["risk_today"],
                    "7d": prediction["risk_7d"],
                    "14d": prediction["risk_14d"],
                    "21d": prediction["risk_21d"]
                },
                "analysis": {
                    "error": "L'analyse IA est temporairement indisponible."
                },
                "actions": [
                    "Vérifiez l'historique et les relevés manuellement.",
                    "Contactez l'assistance si le problème persiste."
                ],
                "alert": {
                    "active": False,
                    "message": "LLM API request failed"
                }
            }
       