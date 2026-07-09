# CACAO-PREDICT — Pipeline de détection multi-maladies

## Ce que ça fait
1. Télécharge et fusionne les datasets (Kaggle + Zenodo) pour 5 classes :
   `healthy`, `black_pod`, `moniliasis`, `pod_borer`, `witches_broom`
2. Entraîne un modèle de classification (transfer learning MobileNetV3)
3. Sauvegarde automatiquement sur Google Drive à chaque étape (pour ne plus jamais perdre le travail si la session Colab expire)
4. Exporte le modèle en `.tflite` (3-4 Mo, tourne hors-ligne sur smartphone)
5. Fournit le code Flutter pour appeler le modèle depuis l'appli, 100% local, sans API

## ⚠️ Règle d'or pour éviter de perdre le travail
Colab efface tout `/content/` dès que la session se déconnecte (inactivité, fermeture d'onglet, timeout ~90 min). **Chaque script ci-dessous sauvegarde automatiquement ses résultats dans ton Google Drive** (`/content/drive/MyDrive/cacao_predict_models/`). Ne saute jamais cette étape, même pour "juste tester".

## Ordre d'exécution (tout se fait sur Google Colab)

### Étape 0 — Setup Colab
1. https://colab.research.google.com → nouveau notebook
2. `Exécution > Modifier le type d'exécution > GPU (T4)`
3. Crée un token API Kaggle sur `kaggle.com/settings` → `Create New API Token` (télécharge `kaggle.json`)
4. Dans une cellule :
```python
from google.colab import files
files.upload()  # upload kaggle.json ici
!mkdir -p ~/.kaggle
!cp kaggle.json ~/.kaggle/
!chmod 600 ~/.kaggle/kaggle.json
!pip install kaggle -q
```

### Étape 1 — Prépare les données
Copie `training/01_prepare_data.py` dans une cellule et exécute.
Télécharge automatiquement :
- Kaggle `zaldyjr/cacao-diseases` → healthy, black_pod, pod_borer
- Zenodo `CocoaMoniliaDataSet` (6,2 Go) → moniliasis (h0/m1/m2/m3 fusionnés) + renfort healthy

⚠️ Si les chemins ne correspondent pas après téléchargement (structure de dossier qui change), lance :
```python
!find /content/raw_datasets -maxdepth 4 -type d
```
et ajuste les variables `KAGGLE_BASE` / `MONILIA_BASE` en haut du script en conséquence.

### Étape 2 — Entraîne le modèle
Copie `training/02_train_model.py`. Durée : 30-60 min sur GPU T4.
Le meilleur modèle est sauvegardé sur Drive après chaque phase — si la session meurt en cours de route, tu ne repars pas de zéro.

### Étape 3 — Exporte en TFLite
Copie `training/03_export_tflite.py`. Produit `cacao_model.tflite` (~3-4 Mo), copié automatiquement sur Drive **et** proposé en téléchargement navigateur.
Récupère-le depuis `MyDrive/cacao_predict_models/cacao_model.tflite` si le téléchargement navigateur échoue.

### Étape 4 — Intègre dans Flutter
Voir `flutter_integration/`. Place `cacao_model.tflite` dans `assets/models/` de ton projet Flutter.

## Classes finales du modèle (ordre confirmé après entraînement réel)
```
['black_pod', 'healthy', 'moniliasis', 'pod_borer', 'witches_broom']
```
Cet ordre est **déjà appliqué** dans `cacao_disease_detector.dart` — ne le modifie que si tu ré-entraînes avec des classes différentes.

## Sources des données
- Kaggle *"cacao-diseases"* (zaldyjr) — black pod rot, pod borer, healthy
- Zenodo *CocoaMoniliaDataSet* (record 17716661) — moniliasis, 4 niveaux de progression h0/m1/m2/m3

⚠️ Ces datasets viennent de contextes différents (pas forcément Côte d'Ivoire). C'est à annoncer honnêtement au jury comme MVP — une phase 2 de collecte terrain locale est prévue en roadmap.

## Limitation assumée sur la sévérité
Le modèle classe la maladie, mais n'a pas encore de score de sévérité entraîné pour toutes les classes. On utilise une heuristique de segmentation couleur côté Flutter (`_estimateSeverity` dans `cacao_disease_detector.dart`) — suffisant pour un MVP, à annoncer comme v1 au jury. Pour la moniliasis spécifiquement, le dataset contient déjà des labels de sévérité réels (m1/m2/m3) qui pourraient servir à entraîner un vrai modèle de sévérité dédié en v2.

## Fonctionnement de l'appli : pas d'API nécessaire
Le modèle `.tflite` tourne 100% en local sur le téléphone, sans connexion internet. Voir la note dans `flutter_integration/00_pubspec_deps.md` pour les axes d'évolution (LLM pour les messages, backend pour la boucle de rétroaction) si tu veux aller plus loin après le MVP.
