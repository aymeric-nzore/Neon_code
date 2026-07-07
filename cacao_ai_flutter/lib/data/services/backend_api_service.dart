import 'dart:convert';
import '../../core/network/api_client.dart';
import '../models/sensor_data.dart';
import '../models/prediction_result.dart';
import 'supabase_service.dart';

class BackendApiService {
  final SupabaseService _supabaseService = SupabaseService();

  // Call predict LSTM endpoint
  Future<PredictionResult> predict(SensorData data) async {
    final url = '${_supabaseService.predictApiUrl}/predict';
    final response = await ApiClient.post(url, data.toMap());

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return PredictionResult.fromMap(decoded);
    } else {
      throw Exception('Erreur serveur lors de la prédiction (code ${response.statusCode})');
    }
  }

  // Call Chatbot endpoint
  Future<String> sendChatMessage(String message) async {
    final url = '${_supabaseService.chatApiUrl}/chat';
    final response = await ApiClient.post(url, {
      'message': message,
    });

    if (response.statusCode == 200) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return decoded['response'] ?? 'Aucune réponse générée par l\'IA.';
    } else {
      throw Exception('Erreur serveur lors de la discussion (code ${response.statusCode})');
    }
  }
}
