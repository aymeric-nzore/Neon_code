import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _contactFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isEmailMode = true;
  bool _codeSent = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_contactFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_isEmailMode) {
      success = await auth.sendPasswordReset(_emailController.text.trim());
    } else {
      final String enteredPhone = _phoneController.text.trim();
      final String fullPhone = enteredPhone.startsWith('+') ? enteredPhone : '+225$enteredPhone';
      success = await auth.sendPhoneReset(fullPhone);
    }

    if (success && mounted) {
      setState(() {
        _codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEmailMode
              ? "Lien / Code de récupération envoyé par e-mail !"
              : "Code de récupération SMS envoyé !"),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  Future<void> _handleVerifyAndReset() async {
    if (!_otpFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String contactVal = _isEmailMode
        ? _emailController.text.trim()
        : (_phoneController.text.trim().startsWith('+')
            ? _phoneController.text.trim()
            : '+225${_phoneController.text.trim()}');

    final success = await auth.verifyAndResetPassword(
      contact: contactVal,
      token: _otpController.text.trim(),
      newPassword: _newPasswordController.text,
      isEmail: _isEmailMode,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Votre mot de passe a été réinitialisé avec succès !"),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.of(context).pop(); // Go back to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Background elegant gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A1E), Color(0xFF0F1E0F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Subtle glowing orb decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withOpacity(0.15),
              ),
            ),
          ),
          
          // Custom Back Button
          Positioned(
            top: 48,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Logo / Icon
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 40,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Récupération',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _codeSent
                            ? 'Saisissez le code OTP reçu et votre nouveau mot de passe.'
                            : 'Entrez vos coordonnées pour recevoir un code OTP.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      if (!_codeSent)
                        Form(
                          key: _contactFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Inputs Wrapper Card
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCard.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: _isEmailMode
                                    ? TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                                        decoration: const InputDecoration(
                                          labelText: 'Adresse e-mail',
                                          labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                          hintText: 'exemple@domaine.com',
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          border: InputBorder.none,
                                        ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) return 'Entrez votre e-mail';
                                          if (!val.contains('@')) return 'E-mail invalide';
                                          return null;
                                        },
                                      )
                                    : TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                                        decoration: const InputDecoration(
                                          labelText: 'Numéro de téléphone',
                                          labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                          hintText: 'Ex: 07 08 09 10 11',
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                          border: InputBorder.none,
                                        ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) return 'Entrez votre numéro';
                                          return null;
                                        },
                                      ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Switch Login Method Button
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white.withOpacity(0.15)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEmailMode = !_isEmailMode;
                                    authProvider.clearErrors();
                                  });
                                },
                                child: Text(_isEmailMode
                                    ? 'Continuer avec numéro de téléphone'
                                    : 'Continuer avec adresse e-mail'),
                              ),
                              const SizedBox(height: 24),
                              
                              if (authProvider.errorMessage != null) ...[
                                Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(color: AppTheme.riskCritical, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                              ],

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: authProvider.isLoading ? null : _handleSendCode,
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Envoyer le code OTP',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                              ),
                            ],
                          ),
                        )
                      else
                        Form(
                          key: _otpFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Inputs Wrapper Card for OTP and New Password
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.bgCard.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _otpController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                                      decoration: const InputDecoration(
                                        labelText: 'Code de récupération (OTP)',
                                        labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                        hintText: 'Saisissez le code reçu',
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Entrez le code OTP';
                                        return null;
                                      },
                                    ),
                                    const Divider(height: 1, color: Colors.white10),
                                    TextFormField(
                                      controller: _newPasswordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Nouveau mot de passe',
                                        labelStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                        hintText: 'Minimum 6 caractères',
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: AppTheme.textMuted,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Entrez un mot de passe';
                                        if (val.length < 6) return 'Le mot de passe doit faire 6 caractères min.';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              if (authProvider.errorMessage != null) ...[
                                Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(color: AppTheme.riskCritical, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                              ],

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: authProvider.isLoading ? null : _handleVerifyAndReset,
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Réinitialiser le mot de passe',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                              ),
                              const SizedBox(height: 16),
                              
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _codeSent = false;
                                    _otpController.clear();
                                    _newPasswordController.clear();
                                    authProvider.clearErrors();
                                  });
                                },
                                child: const Text(
                                  'Renvoyer un code / Modifier coordonnées',
                                  style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
