from .llm_agent import LLMCacaoAgent
from .actions import ActionEngine
from .memory import MemoryEngine


class CacaoRiskAgent:

    def __init__(self, model):
        self.model = model
        self.llm = LLMCacaoAgent()
        self.memory = MemoryEngine()
        self.actions = ActionEngine()

    def analyze_trend(self, history):

        if len(history) < 3:
            return "insufficient_data"

        risks = [h["risk_today"] for h in history]

        if risks[-1] > risks[0]:
            return "increasing_risk"

        elif risks[-1] < risks[0]:
            return "decreasing_risk"

        return "stable"

    def run(self, plantation_id, sensor_data, prediction):

        # Génération du rapport IA
        ai_report = self.llm.generate_report(
            prediction,
            sensor_data
        )

        # Sauvegarde historique
        self.memory.save(
            plantation_id,
            sensor_data,
            prediction
        )

        # Historique
        history = self.memory.get_last_days(
            plantation_id,
            5
        )

        trend = self.analyze_trend(history)

        # Déclenchement éventuel d'une alerte
        alert = self.actions.trigger_alert(prediction)

        # Journalisation
        self.actions.log_event(
            plantation_id,
            prediction,
            ai_report
        )

        return {
            "prediction": prediction,
            "trend": trend,
            "alert": alert,
            "ai_report": ai_report
        }