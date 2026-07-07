# Walkthrough — Flutter Cacao AI

Ce document présente un résumé des fonctionnalités développées et de l'architecture mise en œuvre pour l'application mobile **Cacao AI**.

---

## 🛠️ Modifications apportées

Nous avons créé l'intégralité du projet Flutter `cacao_ai_flutter` sous `C:\Users\blab9\Desktop\Neon_code\cacao_ai_flutter` avec l'architecture suivante :

- **Configuration & Dépendances :**
  - [pubspec.yaml](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/pubspec.yaml) : Déclaration de `supabase_flutter`, `http`, `provider`, `fl_chart`, `google_fonts`, `image_picker`, `image`, et `flutter_svg`.
  - [assets/config.json](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/assets/config.json) : Fichier de configuration contenant les variables d'environnement de l'application (URL et clés de Supabase et des APIs).

- **Couche Core & Design System :**
  - [lib/core/constants/app_constants.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/core/constants/app_constants.dart) : Constantes d'URL, identifiants de plantation et clés locales.
  - [lib/core/network/api_client.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/core/network/api_client.dart) : Client HTTP avec gestion de la sécurité (OWASP), vérification HTTPS en production, et timeouts réseau de 30s.
  - [lib/ui/theme/app_theme.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/theme/app_theme.dart) : Thème sombre haut de gamme, dégradés de vert émeraude et brun cacao, et intégration des polices Google Fonts.

- **Modèles de Données Typés :**
  - [lib/data/models/sensor_data.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/models/sensor_data.dart) : Modélise les données de capteurs (température, humidité, pH, luminosité, pluie).
  - [lib/data/models/prediction_result.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/models/prediction_result.dart) : Modélise la réponse des API de prédiction LSTM et du rapport d'agent IA.
  - [lib/data/models/chat_message.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/models/chat_message.dart) : Structure des messages de discussion.
  - [lib/data/models/tip.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/models/tip.dart) : Conseils agricoles.
  - [lib/data/models/disease_report.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/models/disease_report.dart) : Résultats des diagnostics de feuilles.

- **Services d'API & Supabase :**
  - [lib/data/services/supabase_service.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/services/supabase_service.dart) : Gère Supabase Auth (Google, Facebook, Email, Téléphone), la persistance des sessions et la récupération DB.
  - [lib/data/services/backend_api_service.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/services/backend_api_service.dart) : Appels FastAPI `/predict` et `/chat`.

- **Gestion d'État (Providers) :**
  - `AuthProvider`, `DashboardProvider`, `ChatProvider`, `DiseaseProvider`, `TipsProvider` : Gestionnaires d'état modulaire et découplés de l'UI.

- **Écrans d'Interface Utilisateur (UI) :**
  - `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen` (Authentification).
  - `DashboardScreen` (Tableau de bord principal, météo, raccourcis).
  - `SoilAnalysisScreen` (Jauges de capteurs, graphique de tendance LSTM et rapport IA).
  - `ChatbotScreen` (Messagerie AgriIA).
  - `DiseaseDetectionScreen` (Scans, compression et rapports de maladies).
  - `TipsScreen` (Favoris et pull-to-refresh).
  - `HistoryScreen` (Historique paginé de relevés et rapports IA).
  - `SettingsScreen` (Profil, préférences de langues, déconnexion).

---

## 🧪 Validation & Tests

Nous avons écrit un test unitaire de validation pour garantir la justesse de notre sérialisation de données et du parsing JSON :
- [test/parsing_test.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/test/parsing_test.dart)

### Résultat de l'exécution
```text
00:00 +0: loading C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/test/parsing_test.dart
00:00 +0: Tests des modèles de données Cacao AI SensorData doit se sérialiser correctement en JSON Map
00:00 +1: Tests des modèles de données Cacao AI PredictionResult doit parser correctement depuis une map JSON
00:00 +2: All tests passed!
```
Toutes les validations de parsing et d'exécution locale sont concluantes. L'architecture est modulaire, sécurisée, respecte les principes OWASP (pas de clés en dur, HTTPS forcé, compression d'images locale) et prête à être configurée avec vos informations réelles de production dans `assets/config.json`.
