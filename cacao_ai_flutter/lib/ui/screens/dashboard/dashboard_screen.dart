import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/alert_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../theme/app_theme.dart';
import '../soil/soil_analysis_screen.dart';
import '../chat/chatbot_screen.dart';
import '../disease/disease_detection_screen.dart';
import '../tips/tips_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../main_navigation_screen.dart';
import '../alerts/alerts_screen.dart';
import '../weather/plantation_weather_screen.dart';

import '../../components/mascot_tutorial_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static bool _tutorialShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tutorialShown) {
        _tutorialShown = true;
        MascotTutorialDialog.show(context);
      }
      Provider.of<DashboardProvider>(context, listen: false).fetchLatestFromDatabase().then((_) {
        if (mounted) {
          final dp = Provider.of<DashboardProvider>(context, listen: false);
          final double riskToday = dp.latestPrediction?.prediction.riskToday ?? 0.0;
          final double soilMoisture = dp.currentData.soilMoisture;
          final double rainfall = dp.currentData.rainfall;
          Provider.of<AlertProvider>(context, listen: false).generateAlertsFromData(riskToday, soilMoisture, rainfall);
        }
      });
      Provider.of<WeatherProvider>(context, listen: false).fetchWeather();
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
    final weatherProvider = Provider.of<WeatherProvider>(context);

    final String username = authProvider.userName;
    final String lastSync = dashboardProvider.lastSyncTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(dashboardProvider.lastSyncTime!)
        : 'Jamais';

    final double riskToday = dashboardProvider.latestPrediction?.prediction.riskToday ?? 0.0;
    final String riskLevel = dashboardProvider.latestPrediction?.agent.alert.level ?? 'SAFE';
    final Color riskColor = _getRiskColor(riskLevel);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 720;
    
    int crossAxisCount = 2;
    if (screenWidth > 1000) {
      crossAxisCount = 5;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    }

    if (dashboardProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.bgDark,
        appBar: AppBar(title: const Text('AZUR')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryGreen),
              SizedBox(height: 16),
              Text('Synchro des données de la plantation...', style: TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('AZUR'),
        actions: [
          // Notification Bell with Badge
          Consumer<AlertProvider>(
            builder: (context, alertProv, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Alertes',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlertsScreen()),
                      );
                    },
                  ),
                  if (alertProv.unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${alertProv.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Paramètres',
            onPressed: () {
              final nav = MainNavigationScreen.of(context);
              if (nav != null) {
                nav.setIndex(4);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await dashboardProvider.fetchLatestFromDatabase();
            await weatherProvider.fetchWeather();
            if (mounted) {
              final double rToday = dashboardProvider.latestPrediction?.prediction.riskToday ?? 0.0;
              final double sMoisture = dashboardProvider.currentData.soilMoisture;
              final double rFall = dashboardProvider.currentData.rainfall;
              Provider.of<AlertProvider>(context, listen: false).generateAlertsFromData(rToday, sMoisture, rFall);
            }
          },
          color: AppTheme.primaryGreen,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User info & sync state
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
                    const SizedBox(height: 24),

                    // Health Score Card (SaaS Agricultural Dashboard)
                    _buildHealthScoreCard(riskToday),
                    const SizedBox(height: 20),

                    // Weather & Risk Section (Adaptive Layout)
                    isLargeScreen 
                      ? Row(
                          children: [
                            Expanded(child: _buildWeatherCard(weatherProvider)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildRiskCard(riskColor, riskLevel)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildWeatherCard(weatherProvider),
                            const SizedBox(height: 16),
                            _buildRiskCard(riskColor, riskLevel),
                          ],
                        ),
                    const SizedBox(height: 32),

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
                          onTap: () {
                            final nav = MainNavigationScreen.of(context);
                            if (nav != null) {
                              nav.setIndex(1);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SoilAnalysisScreen()));
                            }
                          },
                        ),
                        _buildShortcutCard(
                          context,
                          title: 'Détection maladie',
                          subtitle: 'Scan photo IA',
                          icon: Icons.camera_alt_outlined,
                          color: AppTheme.primaryOrange,
                          onTap: () {
                            final nav = MainNavigationScreen.of(context);
                            if (nav != null) {
                              nav.setIndex(3);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const DiseaseDetectionScreen()));
                            }
                          },
                        ),
                        _buildShortcutCard(
                          context,
                          title: 'Conseils agricoles',
                          subtitle: 'Astuces du jour',
                          icon: Icons.lightbulb_outline,
                          color: AppTheme.primaryYellow,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsScreen())),
                        ),
                        _buildShortcutCard(
                          context,
                          title: 'Chatbot IA',
                          subtitle: 'Conseiller AgriIA',
                          icon: Icons.chat_bubble_outline,
                          color: AppTheme.primaryBlue,
                          onTap: () {
                            final nav = MainNavigationScreen.of(context);
                            if (nav != null) {
                              nav.setIndex(2);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
                            }
                          },
                        ),
                        _buildShortcutCard(
                          context,
                          title: 'Historique',
                          subtitle: 'Données & scans',
                          icon: Icons.history,
                          color: AppTheme.primaryOrange,
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
      ),
    );
  }

  Widget _buildHealthScoreCard(double riskToday) {
    final int score = ((1.0 - riskToday) * 100).round();
    Color scoreColor;
    String statusText;
    String desc;

    if (score >= 80) {
      scoreColor = AppTheme.primaryGreen;
      statusText = 'Excellent';
      desc = 'Les conditions de culture sont optimales et le risque de maladie est minime.';
    } else if (score >= 55) {
      scoreColor = AppTheme.primaryOrange;
      statusText = 'Attention / Modéré';
      desc = 'Des facteurs d\'humidité ou de pluie modérés exigent une surveillance accrue.';
    } else {
      scoreColor = AppTheme.riskCritical;
      statusText = 'Critique';
      desc = 'Risque très élevé de pourriture brune détecté. Intervenez rapidement.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          // Circular progress indicator for score
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 72,
                width: 72,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.black.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Text(
                '$score%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Santé de la Plantation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: scoreColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(WeatherProvider weatherProv) {
    final weather = weatherProv.weatherData;
    final String tempStr = weather != null ? '${weather.temperatureCurrent.toStringAsFixed(0)}°C' : '29°C';
    final String humStr = weather != null ? 'Humidité : ${weather.humidityCurrent.toStringAsFixed(0)}%' : 'Humidité du sol optimale - 82%';
    final String descStr = weather != null ? weather.descriptionCurrent : 'Ensoleillé';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlantationWeatherScreen()),
        );
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(18),
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  weather != null && weather.rainProbabilityCurrent > 50
                      ? Icons.thunderstorm_rounded
                      : Icons.wb_sunny_rounded,
                  color: AppTheme.accentGold,
                  size: 32,
                ),
                Text(
                  tempStr,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weather?.locationName ?? 'San Pedro, Côte d\'Ivoire',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textLight),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, size: 10, color: AppTheme.textMuted),
                  ],
                ),
                Text(
                  '$descStr • $humStr',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(Color riskColor, String riskLevel) {
    return InkWell(
      onTap: () {
        final nav = MainNavigationScreen.of(context);
        if (nav != null) {
          nav.setIndex(1);
        }
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(18),
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.shield_rounded, color: riskColor, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Risque de Pourriture',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textLight),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.open_in_new, size: 10, color: AppTheme.textMuted),
                  ],
                ),
                Text('Calculé via modèles prédictifs LSTM', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
