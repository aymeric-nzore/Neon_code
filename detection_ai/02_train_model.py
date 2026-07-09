"""
ÉTAPE 2 — Entraînement du modèle de classification multi-maladies
À exécuter dans Colab juste après 01_prepare_data.py, SANS redémarrer la session.
GPU requis (Exécution > Modifier le type d'exécution > GPU).
"""

import os
import json
import tensorflow as tf
from tensorflow.keras import layers, models
import matplotlib.pyplot as plt

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
DATA_DIR = "/content/dataset_final"
DRIVE_SAVE_DIR = "/content/drive/MyDrive/cacao_predict_models"
os.makedirs(DRIVE_SAVE_DIR, exist_ok=True)

# ---------------------------------------------------------------------------
# 1. Chargement des données avec augmentation
# ---------------------------------------------------------------------------
train_ds = tf.keras.utils.image_dataset_from_directory(
    f"{DATA_DIR}/train",
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical",
)
val_ds = tf.keras.utils.image_dataset_from_directory(
    f"{DATA_DIR}/val",
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical",
)

CLASS_NAMES = train_ds.class_names
NUM_CLASSES = len(CLASS_NAMES)
print("Classes détectées :", CLASS_NAMES)

# Sauvegarde immédiate des noms de classes sur Drive (fichier tout petit, aucun risque de le perdre)
with open(f"{DRIVE_SAVE_DIR}/class_names.json", "w") as f:
    json.dump(CLASS_NAMES, f)

data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal_and_vertical"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.15),
    layers.RandomContrast(0.15),
    layers.RandomBrightness(0.15),
])

AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.map(lambda x, y: (data_augmentation(x, training=True), y)).prefetch(AUTOTUNE)
val_ds = val_ds.prefetch(AUTOTUNE)

# ---------------------------------------------------------------------------
# 2. Modèle : transfer learning MobileNetV3Large (léger, adapté au mobile)
# ---------------------------------------------------------------------------
base_model = tf.keras.applications.MobileNetV3Large(
    input_shape=IMG_SIZE + (3,),
    include_top=False,
    weights="imagenet",
    include_preprocessing=True,
)
base_model.trainable = False  # phase 1 : on gèle le backbone

inputs = tf.keras.Input(shape=IMG_SIZE + (3,))
x = base_model(inputs, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.3)(x)
x = layers.Dense(128, activation="relu")(x)
x = layers.Dropout(0.2)(x)
outputs = layers.Dense(NUM_CLASSES, activation="softmax")(x)

model = models.Model(inputs, outputs)

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

model.summary()

# ---------------------------------------------------------------------------
# 3. Phase 1 : entraînement de la tête seulement
#    Checkpoint sauvegardé DIRECTEMENT sur Drive à chaque amélioration
# ---------------------------------------------------------------------------
callbacks_phase1 = [
    tf.keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True),
    tf.keras.callbacks.ModelCheckpoint(
        f"{DRIVE_SAVE_DIR}/best_model_phase1.keras", save_best_only=True
    ),
]

history1 = model.fit(train_ds, validation_data=val_ds, epochs=15, callbacks=callbacks_phase1)

# ---------------------------------------------------------------------------
# 4. Phase 2 : fine-tuning des dernières couches du backbone
# ---------------------------------------------------------------------------
base_model.trainable = True
for layer in base_model.layers[:-40]:
    layer.trainable = False

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

callbacks_phase2 = [
    tf.keras.callbacks.EarlyStopping(patience=5, restore_best_weights=True),
    tf.keras.callbacks.ModelCheckpoint(
        f"{DRIVE_SAVE_DIR}/best_model_final.keras", save_best_only=True
    ),
]

history2 = model.fit(train_ds, validation_data=val_ds, epochs=15, callbacks=callbacks_phase2)

# ---------------------------------------------------------------------------
# 5. Sauvegarde finale (locale + Drive) + courbes
# ---------------------------------------------------------------------------
model.save("/content/cacao_model_final.keras")
model.save(f"{DRIVE_SAVE_DIR}/cacao_model_final.keras")

plt.figure(figsize=(10, 4))
plt.subplot(1, 2, 1)
plt.plot(history1.history["accuracy"] + history2.history["accuracy"], label="train")
plt.plot(history1.history["val_accuracy"] + history2.history["val_accuracy"], label="val")
plt.title("Accuracy")
plt.legend()

plt.subplot(1, 2, 2)
plt.plot(history1.history["loss"] + history2.history["loss"], label="train")
plt.plot(history1.history["val_loss"] + history2.history["val_loss"], label="val")
plt.title("Loss")
plt.legend()
plt.savefig(f"{DRIVE_SAVE_DIR}/training_curves.png")
plt.show()

print(f"\n✅ Modèle sauvegardé sur Drive : {DRIVE_SAVE_DIR}/cacao_model_final.keras")
print(f"✅ Classes sauvegardées : {DRIVE_SAVE_DIR}/class_names.json")
print("➡️  Passe directement à 03_export_tflite.py, SANS redémarrer la session.")
