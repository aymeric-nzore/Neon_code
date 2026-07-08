import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:lottie/lottie.dart';
import '../../theme/app_theme.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  
  final _phoneController = TextEditingController();
  final _phonePasswordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _handleEmailLogin() async {
    if (!_emailFormKey.currentState!.validate()) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInEmail(
      _emailController.text.trim(),
      _emailPasswordController.text,
    );

    if (success && mounted) {
      _navigateToDashboard();
    }
  }

  Future<void> _handlePhoneLogin() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInPhone(
      _phoneController.text.trim(),
      _phonePasswordController.text,
    );

    if (success && mounted) {
      _navigateToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), AppTheme.bgDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      // Header Logo (Animated sprout)
                      Center(
                        child: SizedBox(
                          height: 100,
                          child: Lottie.network(
                            'https://assets3.lottiefiles.com/packages/lf20_mbe9mgyb.json',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.eco,
                                size: 64,
                                color: AppTheme.primaryGreen,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'AZUR',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Agriculture intelligente & prédictive',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Tabs for Email / Phone login
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: AppTheme.primaryGreen,
                          labelColor: AppTheme.textLight,
                          unselectedLabelColor: AppTheme.textMuted,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorPadding: const EdgeInsets.all(4),
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            color: AppTheme.bgInput,
                          ),
                          tabs: const [
                            Tab(text: 'E-mail', icon: Icon(Icons.email_outlined, size: 20)),
                            Tab(text: 'Téléphone', icon: Icon(Icons.phone_outlined, size: 20)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tab View Content
                      SizedBox(
                        height: 310,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Email Form
                            Form(
                              key: _emailFormKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      labelText: 'Adresse e-mail',
                                      hintText: 'exemple@domaine.com',
                                      prefixIcon: Icon(Icons.mail_outline_rounded, color: AppTheme.textMuted),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Entrez votre e-mail';
                                      if (!val.contains('@')) return 'E-mail invalide';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailPasswordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Mot de passe',
                                      hintText: '••••••••',
                                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: AppTheme.textMuted,
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
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                                      },
                                      child: const Text('Mot de passe oublié ?', style: TextStyle(color: AppTheme.primaryGreen)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Phone Form
                            Form(
                              key: _phoneFormKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Numéro de téléphone',
                                      hintText: '+225...',
                                      prefixIcon: Icon(Icons.phone_android_rounded, color: AppTheme.textMuted),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Entrez votre numéro';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phonePasswordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'Mot de passe',
                                      hintText: '••••••••',
                                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: AppTheme.textMuted,
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
                          ],
                        ),
                      ),

                      if (authProvider.errorMessage != null) ...[
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: AppTheme.riskCritical, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Main Login Button
                      ElevatedButton(
                        onPressed: authProvider.isLoading 
                            ? null 
                            : () {
                                if (_tabController.index == 0) {
                                  _handleEmailLogin();
                                } else {
                                  _handlePhoneLogin();
                                }
                              },
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Se connecter'),
                      ),
                      const SizedBox(height: 24),

                      // Social Logins (Google / Facebook)
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.textMuted, endIndent: 8)),
                          Text('Ou continuer avec', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          Expanded(child: Divider(color: AppTheme.textMuted, indent: 8)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: authProvider.isLoading ? null : () async {
                                final success = await authProvider.signInWithGoogle();
                                if (success && mounted) _navigateToDashboard();
                              },
                              icon: const Icon(Icons.g_mobiledata, size: 24),
                              label: const Text('Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: authProvider.isLoading ? null : () async {
                                final success = await authProvider.signInWithFacebook();
                                if (success && mounted) _navigateToDashboard();
                              },
                              icon: const Icon(Icons.facebook, size: 20),
                              label: const Text('Facebook'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Registration Redirection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Nouveau producteur ? ", style: TextStyle(color: AppTheme.textMuted)),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                            },
                            child: const Text(
                              "Créer un compte",
                              style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: TextButton.icon(
                          onPressed: _navigateToDashboard,
                          icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryGreen),
                          label: const Text(
                            "Accéder en mode Démo (sans authentification)",
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
        ),
      ),
    );
  }
}
