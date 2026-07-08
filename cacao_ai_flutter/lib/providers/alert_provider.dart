import 'package:flutter/material.dart';
import '../data/models/agricultural_alert.dart';

class AlertProvider extends ChangeNotifier {
  final List<AgriculturalAlert> _alerts = [];

  AlertProvider() {
    // Populate with initial demo alerts for agricultural realism
    _alerts.addAll([
      AgriculturalAlert(
        id: '1',
        title: 'Risque élevé de pourriture brune',
        description: 'Les conditions d\'humidité actuelles (supérieures à 85%) et les températures douces sont optimales pour la propagation de Phytophthora palmivora.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        level: 'CRITICAL',
        action: 'Inspectez les cabosses au bas des arbres et améliorez l\'aération en désherbant.',
        isRead: false,
      ),
      AgriculturalAlert(
        id: '2',
        title: 'Humidité du sol excessive',
        description: 'L\'humidité du sol dépasse 80%, ce qui favorise l\'asphyxie racinaire et le développement de champignons telluriques.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        level: 'WARNING',
        action: 'Vérifiez les canaux de drainage et suspendez tout apport d\'eau ou irrigation.',
        isRead: false,
      ),
      AgriculturalAlert(
        id: '3',
        title: 'Rappel : Traitement préventif',
        description: 'C\'est le moment idéal pour appliquer un fongicide à base de cuivre si les pluies s\'estompent.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        level: 'INFO',
        action: 'Consultez les recommandations de traitement dans la section Conseils.',
        isRead: true,
      ),
    ]);
  }

  List<AgriculturalAlert> get alerts => List.unmodifiable(_alerts);

  int get unreadCount => _alerts.where((a) => !a.isRead).length;

  void markAsRead(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var alert in _alerts) {
      alert.isRead = true;
    }
    notifyListeners();
  }

  void addAlert(AgriculturalAlert alert) {
    // Avoid duplicates by title/level on the same day
    final isDuplicate = _alerts.any((a) =>
        a.title == alert.title &&
        a.level == alert.level &&
        a.timestamp.day == alert.timestamp.day &&
        a.timestamp.month == alert.timestamp.month);
    if (!isDuplicate) {
      _alerts.insert(0, alert);
      notifyListeners();
    }
  }

  // Generate alerts based on sensor data and prediction results
  void generateAlertsFromData(double riskToday, double soilMoisture, double rainfall) {
    if (riskToday >= 0.70) {
      addAlert(AgriculturalAlert(
        id: 'risk_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Risque élevé de pourriture brune',
        description: 'Le modèle LSTM a détecté une probabilité de maladie de ${(riskToday * 100).toStringAsFixed(0)}%.',
        timestamp: DateTime.now(),
        level: 'CRITICAL',
        action: 'Inspectez les parcelles à risque et récoltez immédiatement les cabosses infectées.',
      ));
    }
    if (soilMoisture > 75.0) {
      addAlert(AgriculturalAlert(
        id: 'soil_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Surcharge hydrique du sol',
        description: 'Le capteur d\'humidité du sol indique un taux de ${soilMoisture.toStringAsFixed(1)}%.',
        timestamp: DateTime.now(),
        level: 'WARNING',
        action: 'Vérifiez le drainage de la parcelle pour éviter le pourrissement des racines.',
      ));
    }
    if (rainfall > 40.0) {
      addAlert(AgriculturalAlert(
        id: 'rain_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Pluies diluviennes détectées',
        description: 'Les précipitations récentes ont atteint ${rainfall.toStringAsFixed(1)} mm.',
        timestamp: DateTime.now(),
        level: 'WARNING',
        action: 'Évitez les applications de traitements foliaires qui seraient lessivés.',
      ));
    }
  }
}
