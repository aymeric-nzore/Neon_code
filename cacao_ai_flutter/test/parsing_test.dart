import 'package:flutter_test/flutter_test.dart';
import '../lib/data/models/sensor_data.dart';
import '../lib/data/models/prediction_result.dart';

void main() {
  group('Tests des modèles de données Cacao AI', () {
    test('SensorData doit se sérialiser correctement en JSON Map', () {
      final now = DateTime.now();
      final data = SensorData(
        plantationId: 42,
        timestamp: now,
        temperatureAir: 29.5,
        humidityAir: 85.0,
        rainfall: 20.0,
        lightIntensity: 150.0,
        soilMoisture: 75.0,
        soilPh: 6.2,
      );

      final map = data.toMap();

      expect(map['plantation_id'], 42);
      expect(map['temperature_air'], 29.5);
      expect(map['humidity_air'], 85.0);
      expect(map['rainfall'], 20.0);
      expect(map['light_intensity'], 150.0);
      expect(map['soil_moisture'], 75.0);
      expect(map['soil_ph'], 6.2);
    });

    test('PredictionResult doit parser correctement depuis une map JSON', () {
      final mockResponse = {
        'status': 'success',
        'prediction': {
          'risk_today': 0.15,
          'risk_7d': 0.30,
          'risk_14d': 0.45,
          'risk_21d': 0.60
        },
        'agent': {
          'trend': 'increasing_risk',
          'alert': {
            'level': 'HIGH',
            'message': 'Le risque devrait augmenter dans les 7 prochains jours.'
          },
          'ai_report': {
            'diagnostic': 'Début de stress hydrique constaté',
            'risk_level': 'medium',
            'analysis': {
              'temperature': 'Température élevée',
              'humidity': 'Humidité normale',
              'soil': 'Sol acide'
            },
            'actions': [
              'Arrosage matinal recommandé',
              'Ajouter du paillage organique'
            ],
            'alert': {
              'active': true,
              'message': 'Surveillance accrue requise'
            }
          }
        }
      };

      final result = PredictionResult.fromMap(mockResponse);

      expect(result.status, 'success');
      expect(result.prediction.riskToday, 0.15);
      expect(result.prediction.risk7d, 0.30);
      expect(result.prediction.risk14d, 0.45);
      expect(result.prediction.risk21d, 0.60);
      expect(result.agent.trend, 'increasing_risk');
      expect(result.agent.alert.level, 'HIGH');
      expect(result.agent.aiReport.diagnostic, 'Début de stress hydrique constaté');
      expect(result.agent.aiReport.actions.length, 2);
      expect(result.agent.aiReport.actions[0], 'Arrosage matinal recommandé');
      expect(result.agent.aiReport.reportAlert.active, true);
    });
  });
}
