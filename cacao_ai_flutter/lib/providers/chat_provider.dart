import 'package:flutter/material.dart';
import '../data/models/chat_message.dart';
import '../data/services/backend_api_service.dart';

class ChatProvider extends ChangeNotifier {
  final BackendApiService _apiService = BackendApiService();

  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  String? _errorMessage;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;

  ChatProvider() {
    _sendWelcomeMessage();
  }

  // Send message to FastAPI chatbot
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reply = await _apiService.sendChatMessage(text);
      final aiMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMsg);
    } catch (e) {
      _errorMessage = "Impossible de contacter l'agent AgriIA. Réessayez plus tard.";
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Restart conversation
  void restartConversation() {
    _messages.clear();
    _errorMessage = null;
    _isGenerating = false;
    _sendWelcomeMessage();
  }

  void _sendWelcomeMessage() {
    _messages.add(
      ChatMessage(
        id: 'welcome',
        text: "Bonjour ! Je suis AgriIA, votre assistant agricole pour le cacao. Décrivez-moi l'état de vos cacaoyers ou posez-moi vos questions.",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
