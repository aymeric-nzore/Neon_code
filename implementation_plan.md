# Plan d'implémentation — Flutter Cacao AI

Ce plan d'implémentation détaille la création et la configuration de l'application Flutter **Cacao AI** sur le bureau de l'utilisateur dans le répertoire `C:\Users\blab9\Desktop\Neon_code\cacao_ai_flutter`. L'application se connectera aux services FastAPI existants (`analyse_ai` et `chatbot_ai`) et utilisera Supabase pour l'authentification, la base de données et le stockage.

---

## User Review Required

> [!IMPORTANT]
> **Configuration de Supabase et Mistral AI**
> - Nous devons configurer un fichier `.env` ou un fichier de configuration pour stocker de manière sécurisée les clés d'API (comme `SUPABASE_URL`, `SUPABASE_ANON_KEY` et la clé d'API Mistral pour le backend). 
> - Nous fournirons un modèle de configuration afin que vous puissiez saisir vos informations d'identification Supabase réelles pour tester l'authentification et l'historique RLS.

> [!WARNING]
> **Base de données Supabase**
> - Pour que l'historique et l'agent fonctionnent correctement, les tables `sensor_history`, `ai_events` et `agricultural_tips` (pour les conseils agricoles) doivent être configurées dans Supabase avec les politiques RLS appropriées. Nous fournirons un script SQL à exécuter dans votre console Supabase si ces tables ne sont pas encore créées.

---

## Open Questions

1. **Clés d'authentification tierces (Google & Facebook) :**
   Avez-vous déjà configuré les identifiants OAuth Google et Facebook dans votre console Supabase ? Si non, nous allons implémenter le flux standard via `supabase_flutter` afin que la connexion soit fonctionnelle dès que les identifiants seront saisis dans votre tableau de bord Supabase.

2. **Backend URLs :**
   Les backends FastAPI (`analyse_ai` à `http://127.0.0.1:8000` et `chatbot_ai` à `http://127.0.0.1:8001`) tournent-ils en local ou sur un serveur distant ? Nous allons rendre l'URL du backend configurable via un fichier de configuration ou des variables d'environnement.

---

## Proposed Changes

Nous allons créer un projet Flutter nommé `cacao_ai_flutter` sous `C:\Users\blab9\Desktop\Neon_code\`. L'architecture choisie est modulaire et inspirée de la Clean Architecture.

```text
cacao_ai_flutter/
├── assets/
│   └── config.json           # Configuration des URLs et clés publiques (sans secrets critiques)
├── lib/
│   ├── core/
│   │   ├── constants/        # Couleurs, styles, dimensions
│   │   ├── network/          # Client HTTP sécurisé, gestion des erreurs
│   │   └── utils/            # Formateurs de dates, compression d'images, etc.
│   ├── data/
│   │   ├── models/           # Modèles de données typés (SensorData, Prediction, Message, Tip)
│   │   ├── repositories/     # Abstraction d'accès aux données
│   │   └── services/         # Appels réseau directs (Supabase & FastAPI)
│   ├── providers/            # Gestion d'état avec Provider (Auth, Chat, Dashboard, Tips, Disease)
│   ├── ui/
│   │   ├── theme/            # Design System (Dark mode, dégradés, polices modernes)
│   │   ├── widgets/          # Composants réutilisables (boutons, inputs, cartes)
│   │   └── screens/          # Écrans de l'application
│   │       ├── auth/         # Login, Register, Forgot Password
│   │       ├── dashboard/    # Tableau de bord principal
│   │       ├── soil/         # Écran Analyse du sol & prédictions
│   │       ├── chat/         # Écran Chatbot IA
│   │       ├── disease/      # Écran Détection de maladie
│   │       ├── tips/         # Écran Conseils agricoles
│   │       ├── history/      # Écran Historique paginé
│   │       └── settings/     # Écran Paramètres & Profil
│   └── main.dart             # Initialisation et routage de l'application
└── pubspec.yaml              # Dépendances Flutter
```

### [NEW] [cacao_ai_flutter](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter)

#### [pubspec.yaml](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/pubspec.yaml)
- Déclarer les dépendances nécessaires :
  - `supabase_flutter: ^2.6.0` (Auth, base de données et stockage)
  - `http: ^1.2.0` (appels aux API FastAPI)
  - `provider: ^6.1.2` (gestion d'état)
  - `fl_chart: ^0.71.0` (graphiques pour l'évolution du risque et des mesures)
  - `google_fonts: ^6.2.0` (typographie élégante : Outfit ou Inter)
  - `image_picker: ^1.1.2` (capture et sélection d'images pour les maladies)
  - `image: ^4.2.0` (compression d'image côté client avant upload)
  - `flutter_svg: ^2.0.10` (pour les icônes vectorielles)

#### [lib/core/network/api_client.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/core/network/api_client.dart)
- Classe utilitaire pour exécuter des requêtes HTTP avec gestion des timeouts, validation HTTPS, et formatage sécurisé des erreurs (sans exposer de stack traces sensibles aux utilisateurs).

#### [lib/data/services/supabase_service.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/services/supabase_service.dart)
- Encapsule les interactions avec Supabase :
  - Inscription, connexion par Email/Mot de passe et Téléphone/Mot de passe.
  - Connexion SSO avec Google et Facebook.
  - Gestion de session (persistance automatique, refresh de token).
  - Récupération sécurisée de l'historique de plantation et des alertes.

#### [lib/data/services/backend_api_service.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/data/services/backend_api_service.dart)
- Appels aux backends FastAPI :
  - `POST /predict` (analyse_ai) : envoie les mesures des capteurs et retourne les prédictions LSTM et le rapport IA.
  - `POST /chat` (chatbot_ai) : envoie le message de l'utilisateur à l'assistant virtuel AgriIA.

#### [lib/providers/auth_provider.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/providers/auth_provider.dart)
- Gère l'état d'authentification de l'utilisateur, les messages d'erreur et les transitions d'écran.

#### [lib/providers/dashboard_provider.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/providers/dashboard_provider.dart)
- Gère l'état des données d'analyse courante, le niveau de risque global et la date de dernière synchronisation.

#### [lib/providers/chat_provider.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/providers/chat_provider.dart)
- Gère l'historique des messages de la session active de chat, l'état de chargement/génération, et les erreurs de communication avec le backend.

#### [lib/ui/theme/app_theme.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/theme/app_theme.dart)
- Palette de couleurs riche et moderne : vert émeraude profond (`#00A86B`), marron cacao chaleureux (`#3D2314`), arrière-plan sombre haut de gamme, effets de glassmorphisme pour les cartes, animations de survol fluides. Compatible dark mode.

#### [lib/ui/screens/auth/login_screen.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/screens/auth/login_screen.dart)
- Interface d'authentification complète avec onglets pour connexion Email et Téléphone, et boutons de connexion sociale (Google, Facebook).

#### [lib/ui/screens/dashboard/dashboard_screen.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/screens/dashboard/dashboard_screen.dart)
- Tableau de bord responsive avec :
  - Accueil personnalisé (nom d'utilisateur, date de synchronisation).
  - Badge dynamique du niveau de risque actuel (Vert = Sûr, Jaune = Moyen, Orange = Élevé, Rouge = Critique).
  - Grille adaptative de raccourcis vers les différentes fonctionnalités.
  - Mini-carte météo stylisée.

#### [lib/ui/screens/soil/soil_analysis_screen.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/screens/soil/soil_analysis_screen.dart)
- Visualisation moderne des données de capteurs :
  - Barres de progression stylisées pour chaque mesure (Humidité air/sol, Température, pH, Conductivité, Luminosité, Pluie).
  - Graphiques interactifs (via `fl_chart`) montrant l'évolution du risque et des mesures sur le temps.
  - Section de recommandation agronomique issue directement du rapport IA.

#### [lib/ui/screens/chat/chatbot_screen.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/screens/chat/chatbot_screen.dart)
- Interface de discussion de type messagerie instantanée, affichage de l'état "génération en cours", possibilité de rejouer une requête en cas d'erreur.

#### [lib/ui/screens/disease/disease_detection_screen.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/screens/disease/disease_detection_screen.dart)
- Interface de capture caméra / sélection galerie. Compression de l'image sélectionnée côté client (redimensionnement et compression JPEG) et simulation d'upload avec rapport d'analyse structuré prêt pour la future connexion d'API.

#### [lib/ui/screens/tips/tips_screen.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/screens/tips/tips_screen.dart)
- Écran des conseils agricoles du jour, support du "pull-to-refresh", gestion des favoris locaux et historique de consultation.

#### [lib/ui/screens/history/history_screen.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/screens/history/history_screen.dart)
- Historique paginé des analyses et des alertes enregistrées sur Supabase pour la plantation en cours.

#### [lib/ui/screens/settings/settings_screen.dart](file:///C:/Users/blab9/Desktop/Neon_code/cacao_ai_flutter/lib/ui/screens/settings/settings_screen.dart)
- Profil de l'utilisateur, préférences de langue, bascule de notifications, politique de confidentialité, déconnexion sécurisée.

---

## Verification Plan

### Automated Tests
- Nous allons créer des tests unitaires de base pour valider les modèles de données et les services de parsing API :
  - `flutter test test/parsing_test.dart`

### Manual Verification
- Nous validerons le design sur l'émulateur Web/Android (ou en mode build) pour s'assurer de sa réactivité et de la fluidité des animations.
- Vérification des politiques de sécurité : s'assurer qu'aucun token ou clé sensible n'est journalisé et que toutes les requêtes utilisent exclusivement le protocole HTTPS en production.
