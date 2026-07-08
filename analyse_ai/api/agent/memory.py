from datetime import datetime, timezone
from supabase import create_client
import os

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)


class MemoryEngine:

    def save(self, plantation_id, data, prediction):

        timestamp = data.get("timestamp")

        if isinstance(timestamp, datetime):
            timestamp = timestamp.isoformat()

        if timestamp is None:
            timestamp = datetime.now(timezone.utc).isoformat()

        try:
            return supabase.table("sensor_history").insert({
                "plantation_id": plantation_id,
                "timestamp": timestamp,
                "temperature_air": data["temperature_air"],
                "humidity_air": data["humidity_air"],
                "rainfall": data["rainfall"],
                "light_intensity": data["light_intensity"],
                "soil_moisture": data["soil_moisture"],
                "soil_ph": data["soil_ph"],
                "risk_today": prediction["risk_today"]
            }).execute()
        except Exception as e:
            print(f"[Supabase] Erreur lors de l'enregistrement de l'historique : {e}")
            return None


    def get_last_days(self, plantation_id, n=5):
        res = (
            supabase.table("sensor_history")
            .select("*")
            .eq("plantation_id", plantation_id)
            .order("timestamp", desc=True)
            .limit(n)
            .execute()
        )

        return list(reversed(res.data))