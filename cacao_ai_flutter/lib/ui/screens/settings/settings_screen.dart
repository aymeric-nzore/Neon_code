import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  String _selectedLanguage = 'Français';

  final List<String> _languages = ['Français', 'English', 'Baoulé', 'Dioula'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String email = authProvider.userEmail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Card Section
            _buildSectionHeader('Profil'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: Colors.black.withOpacity(0.03)),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                    radius: 28,
                    child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authProvider.userEmail.contains('@') ? authProvider.userEmail : authProvider.userPhone,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferences
            _buildSectionHeader('Préférences'),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: Colors.black.withOpacity(0.03)),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  // Language Selection
                  ListTile(
                    leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
                    title: const Text('Langue de l\'application'),
                    subtitle: Text(_selectedLanguage, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                  const Divider(color: Colors.black12, height: 1),
                  // Push Notifications toggle
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryGreen),
                    title: const Text('Notifications Push'),
                    subtitle: const Text('Alertes de risques immédiats', style: TextStyle(fontSize: 12)),
                    value: _pushNotifications,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (bool value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                  const Divider(color: Colors.black12, height: 1),
                  // Email notifications toggle
                  SwitchListTile(
                    secondary: const Icon(Icons.mail_outline, color: AppTheme.primaryGreen),
                    title: const Text('Rapports par E-mail'),
                    subtitle: const Text('Synthèse hebdomadaire', style: TextStyle(fontSize: 12)),
                    value: _emailNotifications,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (bool value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security & Privacy
            _buildSectionHeader('Sécurité & Informations'),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: Colors.black.withOpacity(0.03)),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                    title: const Text('Politique de confidentialité'),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                    onTap: () {
                      _showInfoDialog(
                        'Politique de Confidentialité',
                        'Vos données de capteurs et d\'analyses sont chiffrées de bout en bout. Nous ne transmettons vos informations à aucun organisme tiers sans votre consentement explicite.',
                      );
                    },
                  ),
                  const Divider(color: Colors.black12, height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: AppTheme.primaryGreen),
                    title: const Text('Aide & Support'),
                    subtitle: const Text('Signaler un problème ou poser une question', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                    onTap: _showHelpBottomSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                await authProvider.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Se déconnecter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.riskCritical,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              activeColor: AppTheme.primaryGreen,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedLanguage = val;
                  });
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text(title),
        content: Text(content, style: const TextStyle(height: 1.4, fontSize: 13, color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: AppTheme.primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showHelpBottomSheet() {
    final _formKey = GlobalKey<FormState>();
    final _messageController = TextEditingController();
    String _selectedCategory = 'Difficulté dans l\'application';
    bool _isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.bgDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Aide & Assistance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Une question ou un problème ? Envoyez-nous un message.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Catégorie',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: AppTheme.bgCard,
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTheme.bgCard,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          'Difficulté dans l\'application',
                          'Problème d\'authentification',
                          'Données météo incorrectes',
                          'Analyse IA / Maladie',
                          'Autre',
                        ].map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              _selectedCategory = val;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Votre message',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.bgCard,
                        hintText: 'Décrivez précisément votre problème...',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Veuillez saisir votre message';
                        }
                        if (val.trim().length < 10) {
                          return 'Votre message doit faire au moins 10 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSending
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              setModalState(() {
                                _isSending = true;
                              });

                              try {
                                final client = Supabase.instance.client;
                                await client.from('support_tickets').insert({
                                  'user_id': client.auth.currentUser?.id,
                                  'email': client.auth.currentUser?.email ?? 'anonymous',
                                  'phone': client.auth.currentUser?.phone ?? '',
                                  'category': _selectedCategory,
                                  'message': _messageController.text.trim(),
                                  'created_at': DateTime.now().toIso8601String(),
                                });
                              } catch (e) {
                                print('[SettingsScreen] Support ticket local log: $e');
                              }

                              setModalState(() {
                                _isSending = false;
                              });

                              Navigator.pop(context);

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppTheme.bgCard,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded, color: AppTheme.primaryGreen),
                                      SizedBox(width: 10),
                                      Text('Message Envoyé', style: TextStyle(color: Colors.white, fontSize: 18)),
                                    ],
                                  ),
                                  content: const Text(
                                    'Votre message a bien été transmis. Notre équipe vous répondra rapidement.',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Fermer', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                            },
                      child: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Envoyer le message',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
