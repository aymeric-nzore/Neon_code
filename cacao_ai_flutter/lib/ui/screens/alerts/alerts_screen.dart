import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/alert_provider.dart';
import '../../../data/models/agricultural_alert.dart';
import '../../theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alertProvider = Provider.of<AlertProvider>(context);
    final alerts = alertProvider.alerts;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Centre d\'Alertes'),
        actions: [
          if (alertProvider.unreadCount > 0)
            TextButton.icon(
              onPressed: () => alertProvider.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 18, color: AppTheme.primaryGreen),
              label: const Text(
                'Tout marquer lu',
                style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: alerts.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      // Simuler un rafraîchissement
                      await Future.delayed(const Duration(milliseconds: 600));
                    },
                    color: AppTheme.primaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return _buildAlertCard(context, alert, alertProvider);
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_off_outlined, size: 48, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune alerte active',
              style: TextStyle(color: AppTheme.textLight, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Votre plantation se porte bien. Les alertes agronomiques de risque s\'afficheront ici.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AgriculturalAlert alert, AlertProvider provider) {
    final dateStr = DateFormat('dd MMM, HH:mm').format(alert.timestamp);
    
    // Choose colors/icons based on alert level
    Color badgeColor;
    IconData icon;
    switch (alert.level.toUpperCase()) {
      case 'CRITICAL':
        badgeColor = AppTheme.riskCritical;
        icon = Icons.gpp_bad;
        break;
      case 'WARNING':
        badgeColor = AppTheme.primaryOrange;
        icon = Icons.warning_amber_rounded;
        break;
      case 'INFO':
      default:
        badgeColor = AppTheme.primaryGreen;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: alert.isRead ? Colors.black.withOpacity(0.02) : badgeColor.withOpacity(0.3),
          width: alert.isRead ? 1.0 : 1.5,
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            onExpansionChanged: (expanded) {
              if (expanded && !alert.isRead) {
                provider.markAsRead(alert.id);
              }
            },
            leading: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: badgeColor, size: 24),
                ),
                if (!alert.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.bold,
                      color: AppTheme.textLight,
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                alert.level,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            childrenPadding: const EdgeInsets.all(16),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                alert.description,
                style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textLight),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield, color: badgeColor, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Action recommandée :',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert.action,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
