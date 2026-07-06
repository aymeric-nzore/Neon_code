import time
import requests
import random


API_URL = "http://127.0.0.1:8000/predict"


def generate_fake_sensor():
    return {
        "temperature_air": random.uniform(24, 32),
        "humidity_air": random.uniform(60, 95),
        "rainfall": random.uniform(0, 50),
        "light_intensity": random.uniform(100, 800),
        "soil_moisture": random.uniform(20, 90),
        "soil_ph": random.uniform(4.5, 6.5)
    }


def run_cycle():
    payload = generate_fake_sensor()

    response = requests.post(API_URL, json=payload)

    if response.status_code == 200:
        print("✔ Cycle OK")
        print(response.json())
    else:
        print("❌ Error:", response.text)


if __name__ == "__main__":

    print("🚀 Worker started...")

    while True:
        run_cycle()

        # simulation 5 jours → 5 secondes
        time.sleep(5)