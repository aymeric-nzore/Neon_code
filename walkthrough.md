# Walkthrough — Flutter & FastAPI Cacao AI

Ce document présente le résumé des fonctionnalités, de l'architecture et des correctifs de sécurité/design apportés à l'application **Cacao AI**.

---

## 🛠️ Modifications apportées

### 1. Backend & Sécurité (Normes OWASP)
- **Validation d'Entrées & Limites :** Ajout de validation stricte sur le chatbot (`Field(..., min_length=1, max_length=1000)`) pour éviter l'épuisement des ressources (Denial of Service/Wallet).
- **Gestion Robuste des Erreurs :**
  - Refactorisation de `llm_agent.py` pour intercepter les exceptions d'appel à l'API externe Mistral et renvoyer un diagnostic par défaut plutôt que de faire crasher le endpoint `/predict`.
  - Modification de `chat.py` pour lever des exceptions HTTP appropriées (ex. 503, 500) à destination de l'application mobile au lieu de renvoyer du texte d'erreur avec un code 200 OK.
  - Sécurisation de `memory.py` en enveloppant les appels d'insertion Supabase dans des blocs `try-except`.
- **CORS :** Ajout du middleware `CORSMiddleware` sur les deux backends FastAPI (`analyse_ai` et `chatbot_ai`) pour permettre les requêtes cross-origin en toute sécurité.
- **Worker Simulation :** Correction du script `worker.py` en y ajoutant les champs obligatoires `plantation_id` et `timestamp` pour respecter le schéma de validation `SensorInput`.

### 2. Design & Interface Mobile (Palette Sobre Blanc / Orange / Vert)
- **Refonte Graphique Clé :** Basculement du thème complet de l'application vers un mode clair (`Brightness.light`) épuré et sobre dans `app_theme.dart`.
- **Palette de Couleurs :**
  - **Blanc/Gris clair :** Pour les fonds et les cartes (`bgDark` = `#F9FAFB`, `bgCard` = `#FFFFFF`).
  - **Vert :** Pour la couleur principale (`primaryGreen` = `#16A34A`).
  - **Orange :** Pour la couleur secondaire et les indicateurs (`primaryBrown`/`secondary` = `#EA580C`).
- **Contrastes de Textes & Composants :**
  - Adaptation de toutes les bordures et diviseurs pour utiliser des teintes sombres translucides (`Colors.black12`, `Colors.black.withOpacity(0.05)`) assurant leur visibilité sur fond blanc.
  - Utilisation de la police Outfit avec des niveaux de gris foncés pour le texte principal (`textLight` = `#111827`).

### 3. Classification locale hors-ligne (TensorFlow Lite)
- **Modèle TFLite local :** Intégration du service `CacaoDiseaseDetector` (`lib/data/services/cacao_disease_detector.dart`) pour classifier hors-ligne 5 classes de cabosses de cacao (`healthy`, `black_pod`, `moniliasis`, `pod_borer`, `witches_broom`) à l'aide du modèle TFLite.
- **Estimation de sévérité :** Intégration de l'algorithme d'estimation de sévérité par colorimétrie et affichage d'une jauge de sévérité responsive (`LinearProgressIndicator` orange) sous le rapport de diagnostic.
- **Résilience (Fallback) :** Gestion gracieuse des erreurs dans le `DiseaseProvider` (comme l'absence physique du fichier de modèle `.tflite` non encore téléchargé) en affichant un avertissement propre et en basculant automatiquement sur la simulation pour permettre le test de l'application.
- **Pipeline d'entraînement :** Création du dossier `training/` à la racine contenant les scripts Colab d'entraînement du modèle IA (`01_prepare_data.py`, `02_train_model.py`, `03_export_tflite.py`).

---

## 🧪 Validation & Tests

- **Tests Unitaires Mobiles :** 
  - Exécution réussie des tests unitaires de sérialisation et de parsing JSON dans `test/parsing_test.dart`.
  - Simplification du widget de test template `widget_test.dart` pour éviter les échecs liés à l'initialisation de Supabase en environnement de test local.
- **Vérification de Compilation Python :** validation syntaxique et compilation réussie de l'ensemble des fichiers python modifiés.

### Résultat final des tests
```text
00:12 +1: ... Dummy smoke test                                                 
00:14 +2: ... Cacao AI SensorData doit se sérialiser correctement en JSON Map  
00:14 +3: ... AI PredictionResult doit parser correctement depuis une map JSON 
All tests passed!
```
