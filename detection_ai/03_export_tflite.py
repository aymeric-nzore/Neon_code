"""
ÉTAPE 3 — Export du modèle en TFLite pour Flutter
À exécuter après 02_train_model.py.
Fonctionne aussi si la session a été perdue, TANT QUE le modèle a été
sauvegardé sur Drive à l'étape précédente (voir bloc de secours plus bas).
"""

import os
import json
import numpy as np
import tensorflow as tf

DRIVE_SAVE_DIR = "/content/drive/MyDrive/cacao_predict_models"

# ---------------------------------------------------------------------------
# 0. Si la session a été perdue : remonte Drive et recharge depuis là-bas
# ---------------------------------------------------------------------------
if not os.path.exists("/content/cacao_model_final.keras"):
    print("Modèle local introuvable, tentative de récupération depuis Drive...")
    from google.colab import drive
    drive.mount('/content/drive')
    assert os.path.exists(f"{DRIVE_SAVE_DIR}/cacao_model_final.keras"), (
        "Le modèle n'existe ni en local ni sur Drive. "
        "Il faut relancer 02_train_model.py."
    )
    MODEL_PATH = f"{DRIVE_SAVE_DIR}/cacao_model_final.keras"
else:
    MODEL_PATH = "/content/cacao_model_final.keras"

os.makedirs(DRIVE_SAVE_DIR, exist_ok=True)

# ---------------------------------------------------------------------------
# 1. Chargement du modèle entraîné
# ---------------------------------------------------------------------------
model = tf.keras.models.load_model(MODEL_PATH)

with open(f"{DRIVE_SAVE_DIR}/class_names.json") as f:
    class_names = json.load(f)

# ---------------------------------------------------------------------------
# 2. Conversion TFLite avec quantification dynamique
# ---------------------------------------------------------------------------
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

LOCAL_TFLITE_PATH = "/content/cacao_model.tflite"
DRIVE_TFLITE_PATH = f"{DRIVE_SAVE_DIR}/cacao_model.tflite"

with open(LOCAL_TFLITE_PATH, "wb") as f:
    f.write(tflite_model)
with open(DRIVE_TFLITE_PATH, "wb") as f:
    f.write(tflite_model)

size_mb = os.path.getsize(LOCAL_TFLITE_PATH) / (1024 * 1024)
print(f"Modèle TFLite exporté : {size_mb:.2f} Mo")
print(f"✅ Copié sur Drive : {DRIVE_TFLITE_PATH}")

# ---------------------------------------------------------------------------
# 3. Test rapide de l'inférence TFLite (sanity check)
# ---------------------------------------------------------------------------
interpreter = tf.lite.Interpreter(model_path=LOCAL_TFLITE_PATH)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("\nInput shape attendu :", input_details[0]['shape'])
print("Output shape :", output_details[0]['shape'])
print("Classes (ordre de sortie du modèle) :", class_names)

dummy_input = np.random.rand(1, 224, 224, 3).astype(np.float32)
interpreter.set_tensor(input_details[0]['index'], dummy_input)
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]['index'])
print("\nSortie test (probabilités par classe) :", output)

# ---------------------------------------------------------------------------
# 4. Téléchargement navigateur (en plus de la copie Drive déjà faite)
# ---------------------------------------------------------------------------
from google.colab import files
try:
    files.download(LOCAL_TFLITE_PATH)
    files.download(f"{DRIVE_SAVE_DIR}/class_names.json")
except Exception as e:
    print(f"Téléchargement navigateur échoué ({e}) — pas grave, récupère le fichier")
    print(f"directement depuis Google Drive : {DRIVE_SAVE_DIR}/")

print(f"\n➡️  Le fichier est de toute façon disponible sur ton Drive : {DRIVE_SAVE_DIR}/cacao_model.tflite")
print("➡️  Place-le dans assets/models/ de ton projet Flutter")
print("➡️  L'ORDRE des classes affiché ci-dessus doit correspondre exactement")
print("    à _classNames dans cacao_disease_detector.dart")
