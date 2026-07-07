class AppConstants {
  // Base URLs for FastAPI services (configurable)
  // 10.0.2.2 is the special IP address to access localhost from the Android emulator
  static const String defaultPredictApiUrl = 'http://10.0.2.2:8000';
  static const String defaultChatApiUrl = 'http://10.0.2.2:8001';

  // Config file asset path
  static const String configAssetPath = 'assets/config.json';

  // Local storage keys
  static const String keyUserSession = 'cacao_ai_user_session';
  static const String keyFavoriteTips = 'cacao_ai_favorite_tips';
  static const String keyHistoryTips = 'cacao_ai_history_tips';

  // Default values
  static const int defaultPlantationId = 1;
}
