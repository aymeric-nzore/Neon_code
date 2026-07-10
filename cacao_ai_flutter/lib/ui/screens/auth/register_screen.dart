import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../main_navigation_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  
  final _phoneController = TextEditingController();
  final _phonePasswordController = TextEditingController();

  bool _useEmail = true; // Email is the default form now
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _emailPasswordController.dispose();
    _phoneController.dispose();
    _phonePasswordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  Future<void> _handleEmailRegister() async {
    if (!_emailFormKey.currentState!.validate()) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signUp(
      _emailController.text.trim(),
      _emailPasswordController.text,
      _usernameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inscription réussie ! Veuillez vérifier vos e-mails."),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      _navigateToDashboard();
    }
  }

  Future<void> _handlePhoneRegister() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final String enteredPhone = _phoneController.text.trim();
    final String fullPhone = enteredPhone.startsWith('+') ? enteredPhone : '+225$enteredPhone';
    
    final success = await auth.signUpPhone(
      fullPhone,
      _phonePasswordController.text,
      _usernameController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inscription réussie !"),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      _navigateToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textLight, size: 22),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Inscription',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black.withOpacity(0.08),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Rejoindre la communauté Azur',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Merged inputs container (Airbnb style)
                  if (!_useEmail)
                    Form(
                      key: _phoneFormKey,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26, width: 1.0),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                              decoration: const InputDecoration(
                                labelText: 'Nom d\'utilisateur',
                                labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                hintText: 'Ex: Amadou',
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Entrez un nom d\'utilisateur';
                                return null;
                              },
                            ),
                            const Divider(height: 1, color: Colors.black26),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                              decoration: const InputDecoration(
                                labelText: 'Numéro de téléphone',
                                labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                hintText: 'Ex: +225 07 08 09 10 11',
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Entrez votre numéro';
                                return null;
                              },
                            ),
                            const Divider(height: 1, color: Colors.black26),
                            TextFormField(
                              controller: _phonePasswordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                labelStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                hintText: '••••••••',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                                if (val == null || val.length < 6) return 'Le mot de passe doit faire 6+ caractères';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Form(
                      key: _emailFormKey,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26, width: 1.0),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                              decoration: const InputDecoration(
                                labelText: 'Nom d\'utilisateur',
                                labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                hintText: 'Ex: Amadou',
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Entrez un nom d\'utilisateur';
                                return null;
                              },
                            ),
                            const Divider(height: 1, color: Colors.black26),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                              decoration: const InputDecoration(
                                labelText: 'Adresse e-mail',
                                labelStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                hintText: 'exemple@domaine.com',
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Entrez votre e-mail';
                                if (!val.contains('@')) return 'E-mail invalide';
                                return null;
                              },
                            ),
                            const Divider(height: 1, color: Colors.black26),
                            TextFormField(
                              controller: _emailPasswordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: AppTheme.textLight, fontSize: 15),
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                labelStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                                hintText: '••••••••',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                                if (val == null || val.length < 6) return 'Le mot de passe doit faire 6+ caractères';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),
                  Text(
                    _useEmail 
                      ? "Nous utiliserons votre e-mail pour sécuriser votre compte."
                      : "Nous vous appellerons ou enverrons un SMS pour confirmer votre numéro. Des tarifs de données peuvent s'appliquer.",
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  if (authProvider.errorMessage != null) ...[
                    Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: AppTheme.riskCritical, fontSize: 13, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Continue button
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            if (_useEmail) {
                              _handleEmailRegister();
                            } else {
                              _handlePhoneRegister();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Continuer',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Separator line (or)
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.black26, endIndent: 12)),
                      Text('ou', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                      Expanded(child: Divider(color: Colors.black26, indent: 12)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Alternative method switch button
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _useEmail = !_useEmail;
                        authProvider.clearErrors();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black87, width: 1.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppTheme.textLight,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Icon(
                              _useEmail ? Icons.phone_outlined : Icons.email_outlined,
                              size: 20,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                        Text(
                          _useEmail ? "Continuer avec le téléphone" : "Continuer avec l'e-mail",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: authProvider.isLoading ? null : () async {
                      final success = await authProvider.signInWithGoogle();
                      if (success && mounted) _navigateToDashboard();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.black87, width: 1.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppTheme.textLight,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                              width: 20,
                              height: 20,
                              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22),
                            ),
                          ),
                        ),
                        const Text(
                          "Continuer avec Google",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Go back to login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Vous avez déjà un compte ? ", style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
