import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';
import '../soil/soil_analysis_screen.dart';
import '../chat/chatbot_screen.dart';
import '../disease/disease_detection_screen.dart';
import '../tips/tips_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchLatestFromDatabase();
    });
  }

  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return AppTheme.riskCritical;
      case 'HIGH':
        return AppTheme.riskHigh;
      case 'WARNING':
        return AppTheme.riskMedium;
      case 'INFO':
        return Colors.blue;
      case 'SAFE':
      default:
        return AppTheme.riskLow;
    }
  }

  String _getRiskText(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return 'CRITIQUE';
      case 'HIGH':
        return 'ÉLEVÉ';
      case 'WARNING':
        return 'MODÉRÉ';
      case 'INFO':
        return 'FAIBLE';
      case 'SAFE':
      default:
        return 'AUCUN RISQUE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    final String username = authProvider.userEmail.split('@').first;
    final String lastSync = dashboardProvider.lastSyncTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(dashboardProvider.lastSyncTime!)
        : 'Jamais';

    final String riskLevel = dashboardProvider.latestPrediction?.agent.alert.level ?? 'SAFE';
    final Color riskColor = _getRiskColor(riskLevel);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 720;
    
    // Dynamic Grid columns based on screen width
    int crossAxisCount = 2;
    if (screenWidth > 960) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('CACAO AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User info & sync state
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour, $username !',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.sync, size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Dernière synchro : $lastSync',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                        radius: 26,
                        child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Weather & Risk Section (Adaptive Layout)
                  isLargeScreen 
                    ? Row(
                        children: [
                          Expanded(child: _buildWeatherCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildRiskCard(riskColor, riskLevel)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildWeatherCard(),
                          const SizedBox(height: 16),
                          _buildRiskCard(riskColor, riskLevel),
                        ],
                      ),
                  const SizedBox(height: 36),

                  const Text(
                    'Fonctionnalités',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 16),

                  // Features Grid Shortcuts (Dynamic Column Count)
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isLargeScreen ? 1.25 : 1.1,
                    children: [
                      _buildShortcutCard(
                        context,
                        title: 'Analyse du sol',
                        subtitle: 'Humidité & pH',
                        icon: Icons.analytics_outlined,
                        color: AppTheme.primaryGreen,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilAnalysisScreen())),
                      ),
                      _buildShortcutCard(
                        context,
                        title: 'Détection maladie',
                        subtitle: 'Scan photo IA',
                        icon: Icons.camera_alt_outlined,
                        color: Colors.purple,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseDetectionScreen())),
                      ),
                      _buildShortcutCard(
                        context,
                        title: 'Conseils agricoles',
                        subtitle: 'Astuces du jour',
                        icon: Icons.lightbulb_outline,
                        color: Colors.amber,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsScreen())),
                      ),
                      _buildShortcutCard(
                        context,
                        title: 'Chatbot IA',
                        subtitle: 'Conseiller AgriIA',
                        icon: Icons.chat_bubble_outline,
                        color: Colors.blue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
                      ),
                      _buildShortcutCard(
                        context,
                        title: 'Historique',
                        subtitle: 'Données & scans',
                        icon: Icons.history,
                        color: Colors.orange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
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

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
              Text('29°C', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('San Pedro, Côte d\'Ivoire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Humidité du sol optimale - 82%', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(Color riskColor, String riskLevel) {
    return Container(
      padding: const EdgeInsets.all(18),
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.shield_outlined, color: riskColor, size: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getRiskText(riskLevel),
                  style: TextStyle(
                    color: riskColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Niveau de Risque Global', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Calculé via modèles prédictifs LSTM', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
