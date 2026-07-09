"""
ÉTAPE 1 — Préparation et fusion des datasets
À exécuter dans Google Colab, après avoir configuré kaggle.json (voir README).
"""

import os
import shutil
import random
from pathlib import Path

# ---------------------------------------------------------------------------
# 0. Montage Drive dès le début — pour ne jamais perdre le travail si la
#    session Colab expire en cours de route
# ---------------------------------------------------------------------------
from google.colab import drive
drive.mount('/content/drive')

DRIVE_SAVE_DIR = "/content/drive/MyDrive/cacao_predict_models"
os.makedirs(DRIVE_SAVE_DIR, exist_ok=True)

# ---------------------------------------------------------------------------
# 1. Téléchargement du dataset Kaggle (black pod, pod borer, healthy)
# ---------------------------------------------------------------------------
os.makedirs("/content/raw_datasets", exist_ok=True)
os.chdir("/content/raw_datasets")

print("Téléchargement de zaldyjr/cacao-diseases ...")
os.system("kaggle datasets download -d zaldyjr/cacao-diseases -p /content/raw_datasets --unzip")

# ---------------------------------------------------------------------------
# 2. Dataset moniliasis (peau jaune) — CocoaMoniliaDataSet (Zenodo, 6.2 Go)
#    Contient déjà 4 classes de progression : h0 (sain), m1/m2/m3 (sévérité
#    croissante). h0 renforce "healthy", m1/m2/m3 sont fusionnés en "moniliasis".
# ---------------------------------------------------------------------------
print("Téléchargement de CocoaMoniliaDataSet depuis Zenodo (6.2 Go, 5-15 min)...")
os.makedirs("/content/raw_datasets/monilia", exist_ok=True)
os.system(
    "wget -q --show-progress -O /content/raw_datasets/monilia/CocoaMoniliaDataSet.zip "
    "'https://zenodo.org/records/17716661/files/CocoaMoniliaDataSet.zip?download=1'"
)
os.system(
    "unzip -q /content/raw_datasets/monilia/CocoaMoniliaDataSet.zip "
    "-d /content/raw_datasets/monilia/"
)

# ---------------------------------------------------------------------------
# 3. Structure finale unifiée
# ---------------------------------------------------------------------------
FINAL_DIR = Path("/content/dataset_final")
CLASSES = ["healthy", "black_pod", "moniliasis", "pod_borer", "witches_broom"]

for split in ["train", "val", "test"]:
    for c in CLASSES:
        (FINAL_DIR / split / c).mkdir(parents=True, exist_ok=True)


def split_and_copy(source_dir, target_class, train_ratio=0.7, val_ratio=0.15):
    """Répartit toutes les images d'un dossier source en train/val/test
    dans la classe cible."""
    source_dir = Path(source_dir)
    if not source_dir.exists():
        print(f"⚠️  {source_dir} introuvable, skip.")
        return

    images = [f for f in source_dir.glob("*") if f.suffix.lower() in [".jpg", ".jpeg", ".png"]]
    random.shuffle(images)

    n = len(images)
    n_train = int(n * train_ratio)
    n_val = int(n * val_ratio)

    splits = {
        "train": images[:n_train],
        "val": images[n_train:n_train + n_val],
        "test": images[n_train + n_val:],
    }

    for split, files in splits.items():
        for f in files:
            dest = FINAL_DIR / split / target_class / f"{source_dir.name}_{f.name}"
            shutil.copy(f, dest)

    print(f"{target_class} <- {source_dir.name}: {n} images réparties")


# --- Chemins vérifiés le 08/07 via `find /content/raw_datasets -maxdepth 3 -type d` ---
KAGGLE_BASE = "/content/raw_datasets/cacao_diseases/cacao_photos"
MONILIA_BASE = "/content/raw_datasets/monilia/CocoaMoniliaDataSet/cocoapods_images"
# ⚠️ Si la structure diffère après téléchargement, vérifie avec :
# !find /content/raw_datasets -maxdepth 4 -type d
# et ajuste les deux lignes ci-dessus avant de continuer.

split_and_copy(f"{KAGGLE_BASE}/healthy", "healthy")
split_and_copy(f"{KAGGLE_BASE}/black_pod_rot", "black_pod")
split_and_copy(f"{KAGGLE_BASE}/pod_borer", "pod_borer")

split_and_copy(f"{MONILIA_BASE}/h0", "healthy")
split_and_copy(f"{MONILIA_BASE}/m1", "moniliasis")
split_and_copy(f"{MONILIA_BASE}/m2", "moniliasis")
split_and_copy(f"{MONILIA_BASE}/m3", "moniliasis")

# Pas de source pour witches_broom pour l'instant : si tu trouves un dataset,
# ajoute une ligne split_and_copy(...) ici. En son absence, retire cette classe
# de CLASSES ci-dessus avant de lancer l'entraînement (02_train_model.py
# détecte les classes automatiquement depuis les dossiers non vides).

# ---------------------------------------------------------------------------
# 4. Vérification finale + sauvegarde de la liste des comptages sur Drive
# ---------------------------------------------------------------------------
print("\n--- Répartition finale ---")
report_lines = []
for split in ["train", "val", "test"]:
    for c in CLASSES:
        n = len(list((FINAL_DIR / split / c).glob("*")))
        line = f"{split}/{c}: {n} images"
        print(line)
        report_lines.append(line)

with open(f"{DRIVE_SAVE_DIR}/dataset_report.txt", "w") as f:
    f.write("\n".join(report_lines))

print(f"\n✅ Rapport sauvegardé sur Drive : {DRIVE_SAVE_DIR}/dataset_report.txt")
print("➡️  Le dataset lui-même reste dans /content/dataset_final (trop volumineux")
print("    pour copier sur Drive) — passe directement à 02_train_model.py")
print("    SANS redémarrer la session Colab, sinon il faudra relancer cette étape.")
