import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                          email.split('@').first.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
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
                    leading: const Icon(Icons.info_outline, color: AppTheme.primaryGreen),
                    title: const Text('À propos de Azur'),
                    subtitle: const Text('Version 1.0.0', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                    onTap: () {
                      _showInfoDialog(
                        'À Propos de Azur',
                        'Azur est une application d\'aide à la décision agronomique conçue pour aider les producteurs de cacao en Côte d\'Ivoire à anticiper les maladies grâce à l\'intelligence artificielle (FastAPI + PyTorch LSTM).',
                      );
                    },
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
}
