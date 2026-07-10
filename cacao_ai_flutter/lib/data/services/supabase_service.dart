import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _initialized = false;
  late String _predictApiUrl;
  late String _chatApiUrl;

  String get predictApiUrl => _predictApiUrl;
  String get chatApiUrl => _chatApiUrl;
  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;

  // Initialize Supabase from config.json
  Future<void> initialize() async {
    if (_initialized) return;

    String supabaseUrl = 'https://placeholder.supabase.co';
    String supabaseAnonKey = 'placeholder';
    _predictApiUrl = AppConstants.defaultPredictApiUrl;
    _chatApiUrl = AppConstants.defaultChatApiUrl;

    try {
      final configString = await rootBundle.loadString(AppConstants.configAssetPath);
      final Map<String, dynamic> config = json.decode(configString);
      supabaseUrl = config['supabase_url'] ?? supabaseUrl;
      supabaseAnonKey = config['supabase_anon_key'] ?? supabaseAnonKey;
      _predictApiUrl = config['predict_api_url'] ?? _predictApiUrl;
      _chatApiUrl = config['chat_api_url'] ?? _chatApiUrl;
    } catch (e) {
      // Configuration fallback if assets not loaded yet or file is missing
      print("[SupabaseService] Erreur lors du chargement de la config: $e");
    }

    if (!supabaseUrl.startsWith('https://placeholder')) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }
    
    _initialized = true;
  }

  // Auth: Register
  Future<AuthResponse> signUpEmail({required String email, required String password, required String username}) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<AuthResponse> signUpPhone({required String phone, required String password, required String username}) async {
    return await client.auth.signUp(
      phone: phone,
      password: password,
      data: {'username': username},
    );
  }

  // Auth: Login Email
  Future<AuthResponse> signInEmail({required String email, required String password}) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  // Auth: Login Phone
  Future<AuthResponse> signInPhone({required String phone, required String password}) async {
    return await client.auth.signInWithPassword(phone: phone, password: password);
  }

  // Auth: Google Sign-In
  Future<bool> signInWithGoogle() async {
    try {
      return await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.toString() : 'io.supabase.cacaoai://login-callback/',
      );
    } catch (e) {
      return false;
    }
  }

  // Auth: Facebook Sign-In
  Future<bool> signInWithFacebook() async {
    try {
      return await client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: kIsWeb ? Uri.base.toString() : 'io.supabase.cacaoai://login-callback/',
      );
    } catch (e) {
      return false;
    }
  }

  // Auth: Update Username
  Future<UserResponse> updateUsername(String newUsername) async {
    return await client.auth.updateUser(
      UserAttributes(data: {'username': newUsername}),
    );
  }

  // Auth: SignOut
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Auth: Reset Password
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // Auth: Reset Password (Phone OTP)
  Future<void> sendPhoneOtpReset(String phone) async {
    await client.auth.signInWithOtp(
      phone: phone,
      shouldCreateUser: false,
    );
  }

  // Auth: Verify OTP and update password
  Future<void> verifyAndResetPassword({
    required String contact,
    required String token,
    required String newPassword,
    required bool isEmail,
  }) async {
    if (isEmail) {
      await client.auth.verifyOTP(
        email: contact,
        token: token,
        type: OtpType.recovery,
      );
    } else {
      await client.auth.verifyOTP(
        phone: contact,
        token: token,
        type: OtpType.sms,
      );
    }
    await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Database: Fetch Sensor History
  Future<List<Map<String, dynamic>>> fetchSensorHistory(int plantationId) async {
    try {
      final response = await client
          .from('sensor_history')
          .select()
          .eq('plantation_id', plantationId)
          .order('timestamp', ascending: false)
          .limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('[SupabaseService] Error fetching history: $e');
      return [];
    }
  }

  // Database: Fetch AI Events (Alerts history)
  Future<List<Map<String, dynamic>>> fetchAIEvents(int plantationId) async {
    try {
      final response = await client
          .from('ai_events')
          .select()
          .eq('plantation_id', plantationId)
          .order('timestamp', ascending: false)
          .limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('[SupabaseService] Error fetching events: $e');
      return [];
    }
  }

  // Database: Fetch Agricultural Tips
  Future<List<Map<String, dynamic>>> fetchTips() async {
    try {
      final response = await client
          .from('agricultural_tips')
          .select()
          .order('date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('[SupabaseService] Error fetching tips: $e');
      // If table is missing or errors, return mock data
      return _getMockTips();
    }
  }

  // Mock tips fallback if DB not populated
  List<Map<String, dynamic>> _getMockTips() {
    final now = DateTime.now();
    return [
      {
        'id': 'tip_1',
        'title': 'Optimisation de l\'ombrage du cacaoyer',
        'content': 'Maintenir un ombrage à hauteur de 30-40% pour protéger les jeunes plants des rayons directs du soleil et réguler la température ambiante.',
        'category': 'Technique',
        'date': now.subtract(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'id': 'tip_2',
        'title': 'Prévention de la pourriture brune',
        'content': 'Éliminez régulièrement les cabosses momifiées ou infectées pour éviter la dispersion du champignon Phytophthora pendant les saisons pluvieuses.',
        'category': 'Maladies',
        'date': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': 'tip_3',
        'title': 'Analyse du pH du sol',
        'content': 'Le cacaoyer préfère un sol légèrement acide à neutre (pH optimal entre 5.5 et 6.5). Un pH inférieur à 5.0 limite l\'absorption du phosphore.',
        'category': 'Sol',
        'date': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];
  }
}
