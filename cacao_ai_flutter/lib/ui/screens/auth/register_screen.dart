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

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _emailConfirmPasswordController = TextEditingController();

  final _phoneController = TextEditingController();
  final _phonePasswordController = TextEditingController();
  final _phoneConfirmPasswordController = TextEditingController();

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
    _emailConfirmPasswordController.dispose();
    _phoneController.dispose();
    _phonePasswordController.dispose();
    _phoneConfirmPasswordController.dispose();
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
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inscription réussie ! Veuillez vérifier vos e-mails de confirmation."),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.of(context).pop(); // Back to Login
    }
  }

  Future<void> _handlePhoneRegister() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signUpPhone(
      _phoneController.text.trim(),
      _phonePasswordController.text,
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
      appBar: AppBar(title: const Text('Inscription')),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Rejoignez la communauté de producteurs Azur',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Tabs for Email / Phone signup
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
                      height: 370,
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
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailConfirmPasswordController,
                                  obscureText: _obscurePassword,
                                  decoration: const InputDecoration(
                                    labelText: 'Confirmer le mot de passe',
                                    hintText: '••••••••',
                                    prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted),
                                  ),
                                  validator: (val) {
                                    if (val != _emailPasswordController.text) return 'Les mots de passe ne correspondent pas';
                                    return null;
                                  },
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
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _phoneConfirmPasswordController,
                                  obscureText: _obscurePassword,
                                  decoration: const InputDecoration(
                                    labelText: 'Confirmer le mot de passe',
                                    hintText: '••••••••',
                                    prefixIcon: Icon(Icons.lock_outline_rounded, color: AppTheme.textMuted),
                                  ),
                                  validator: (val) {
                                    if (val != _phonePasswordController.text) return 'Les mots de passe ne correspondent pas';
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

                    ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () {
                              if (_tabController.index == 0) {
                                _handleEmailRegister();
                              } else {
                                _handlePhoneRegister();
                              }
                            },
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('S\'inscrire'),
                    ),
                    const SizedBox(height: 24),

                    // Social Logins
                    const Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.textMuted, endIndent: 8)),
                        Text('Ou s\'inscrire avec', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Vous avez déjà un compte ? ", style: TextStyle(color: AppTheme.textMuted)),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
