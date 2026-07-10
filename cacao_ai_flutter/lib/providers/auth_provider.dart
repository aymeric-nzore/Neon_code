import 'package:flutter/material.dart';
import '../data/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _supabaseService.currentUser != null;
  String get userEmail => _supabaseService.currentUser?.email ?? 'Producteur';
  String get userPhone => _supabaseService.currentUser?.phone ?? '';
  String get userName => _supabaseService.currentUser?.userMetadata?['username'] ??
                         _supabaseService.currentUser?.userMetadata?['full_name'] ??
                         _supabaseService.currentUser?.userMetadata?['name'] ??
                         'Producteur';

  // Sign In Email
  Future<bool> signInEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabaseService.signInEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _setLoading(false);
      return false;
    }
  }

  // Sign In Phone
  Future<bool> signInPhone(String phone, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabaseService.signInPhone(phone: phone, password: password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _setLoading(false);
      return false;
    }
  }

  // Sign Up Email
  Future<bool> signUp(String email, String password, String username) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabaseService.signUpEmail(email: email, password: password, username: username);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _setLoading(false);
      return false;
    }
  }

  // Sign Up Phone
  Future<bool> signUpPhone(String phone, String password, String username) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabaseService.signUpPhone(phone: phone, password: password, username: username);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _setLoading(false);
      return false;
    }
  }

  // SSO Login Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    final success = await _supabaseService.signInWithGoogle();
    if (!success) {
      _errorMessage = "Connexion Google annulée ou échouée.";
    }
    _setLoading(false);
    return success;
  }

  // SSO Login Facebook
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _errorMessage = null;
    final success = await _supabaseService.signInWithFacebook();
    if (!success) {
      _errorMessage = "Connexion Facebook annulée ou échouée.";
    }
    _setLoading(false);
    return success;
  }

  // Update Username
  Future<bool> updateUsername(String newUsername) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabaseService.updateUsername(newUsername);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _setLoading(false);
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabaseService.signOut();
    notifyListeners();
  }

  // Password Recovery
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabaseService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _setLoading(false);
      return false;
    }
  }

  // Phone Recovery
  Future<bool> sendPhoneReset(String phone) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabaseService.sendPhoneOtpReset(phone);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _setLoading(false);
      return false;
    }
  }

  // Verify OTP and Reset Password
  Future<bool> verifyAndResetPassword({
    required String contact,
    required String token,
    required String newPassword,
    required bool isEmail,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabaseService.verifyAndResetPassword(
        contact: contact,
        token: token,
        newPassword: newPassword,
        isEmail: isEmail,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseAuthError(e);
      _setLoading(false);
      return false;
    }
  }

  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String _parseAuthError(dynamic e) {
    final str = e.toString().toLowerCase();
    if (str.contains('invalid login credentials') || str.contains('invalid credentials')) {
      return "Identifiants de connexion invalides. Veuillez réessayer.";
    }
    if (str.contains('email not confirmed')) {
      return "Veuillez confirmer votre adresse e-mail d'abord.";
    }
    if (str.contains('user already exists')) {
      return "Un compte existe déjà avec cette adresse e-mail.";
    }
    return "Une erreur est survenue lors de l'authentification.";
  }
}
