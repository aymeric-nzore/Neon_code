from datetime import datetime, UTC
from supabase import create_client
import os

# ======================================================
# Configuration
# ======================================================

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError(
        "SUPABASE_URL ou SUPABASE_KEY est manquant dans les variables d'environnement."
    )

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# ======================================================
# Seuils d'alerte
# ======================================================

CRITICAL_THRESHOLD = 0.70
HIGH_THRESHOLD = 0.60
MEDIUM_THRESHOLD = 0.50
LOW_THRESHOLD = 0.45


# ======================================================
# Action Engine
# ======================================================

class ActionEngine:
    """
    Responsable des actions automatiques après une prédiction.

    - Journalisation des analyses
    - Détermination du niveau d'alerte
    """

    def log_event(self, plantation_id, prediction, ai_report):
        """
        Enregistre une analyse IA dans Supabase.
        """

        data = {
            "plantation_id": plantation_id,
            "timestamp": datetime.now(UTC).isoformat(),
            "risk_today": prediction["risk_today"],
            "risk_7d": prediction["risk_7d"],
            "risk_14d": prediction["risk_14d"],
            "risk_21d": prediction["risk_21d"],
            "ai_report": ai_report
        }

        try:
            response = (
                supabase
                .table("ai_events")
                .insert(data)
                .execute()
            )

            return response

        except Exception as e:
            print(f"[Supabase] Erreur lors de l'enregistrement : {e}")
            return None

    def trigger_alert(self, prediction):
        """
        Détermine automatiquement le niveau d'alerte
        selon les risques prédits.
        """

        if prediction["risk_today"] >= CRITICAL_THRESHOLD:
            return {
                "level": "CRITICAL",
                "message": "Risque immédiat très élevé. Intervention recommandée."
            }

        if prediction["risk_7d"] >= HIGH_THRESHOLD:
            return {
                "level": "HIGH",
                "message": "Le risque devrait fortement augmenter dans les prochains jours."
            }

        if prediction["risk_14d"] >= MEDIUM_THRESHOLD:
            return {
                "level": "WARNING",
                "message": "Surveillance renforcée recommandée."
            }

        if prediction["risk_21d"] >= LOW_THRESHOLD:
            return {
                "level": "INFO",
                "message": "Une légère augmentation du risque est prévue."
            }

        return {
            "level": "SAFE",
            "message": "Aucun risque important détecté."
        }