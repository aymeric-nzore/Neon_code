import 'package:flutter/material.dart';
import '../data/models/sensor_data.dart';
import '../data/models/prediction_result.dart';
import '../data/services/backend_api_service.dart';
import '../data/services/supabase_service.dart';
import '../../core/constants/app_constants.dart';

class DashboardProvider extends ChangeNotifier {
  final BackendApiService _apiService = BackendApiService();
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  PredictionResult? _latestPrediction;

  // Current sensor data
  SensorData _currentData = SensorData(
    plantationId: AppConstants.defaultPlantationId,
    timestamp: DateTime.now(),
    temperatureAir: 28.5,
    humidityAir: 82.0,
    rainfall: 15.0,
    lightIntensity: 110.0,
    soilMoisture: 65.0,
    soilPh: 5.8,
  );

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  PredictionResult? get latestPrediction => _latestPrediction;
  SensorData get currentData => _currentData;

  // Set individual sensor data fields
  void updateSensorField({
    double? temperatureAir,
    double? humidityAir,
    double? rainfall,
    double? lightIntensity,
    double? soilMoisture,
    double? soilPh,
  }) {
    _currentData = SensorData(
      plantationId: _currentData.plantationId,
      timestamp: DateTime.now(),
      temperatureAir: temperatureAir ?? _currentData.temperatureAir,
      humidityAir: humidityAir ?? _currentData.humidityAir,
      rainfall: rainfall ?? _currentData.rainfall,
      lightIntensity: lightIntensity ?? _currentData.lightIntensity,
      soilMoisture: soilMoisture ?? _currentData.soilMoisture,
      soilPh: soilPh ?? _currentData.soilPh,
    );
    notifyListeners();
  }

  // Trigger analysis and LSTM prediction
  Future<bool> runAnalysis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.predict(_currentData);
      _latestPrediction = result;
      _lastSyncTime = DateTime.now();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Impossible de récupérer la prédiction. Vérifiez que le serveur FastAPI est actif.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch last recorded prediction from Supabase
  Future<void> fetchLatestFromDatabase() async {
    final history = await _supabaseService.fetchSensorHistory(_currentData.plantationId);
    if (history.isNotEmpty) {
      final latestRecord = history.first;
      _currentData = SensorData.fromMap(latestRecord);
      
      // Attempt to load AI events as well
      final events = await _supabaseService.fetchAIEvents(_currentData.plantationId);
      if (events.isNotEmpty) {
        final latestEvent = events.first;
        // Construct a PredictionResult mapping from database values
        _latestPrediction = PredictionResult(
          status: 'success',
          prediction: RiskScores(
            riskToday: (latestEvent['risk_today'] as num?)?.toDouble() ?? 0.0,
            risk7d: (latestEvent['risk_7d'] as num?)?.toDouble() ?? 0.0,
            risk14d: (latestEvent['risk_14d'] as num?)?.toDouble() ?? 0.0,
            risk21d: (latestEvent['risk_21d'] as num?)?.toDouble() ?? 0.0,
          ),
          agent: AgentReport(
            trend: 'stable', // fallback
            alert: AlertInfo(
              level: latestEvent['risk_today'] >= 0.70 ? 'CRITICAL' : 'SAFE',
              message: 'Données récupérées de Supabase.',
            ),
            aiReport: AIReportDetails.fromMap(latestEvent['ai_report'] ?? {}),
          ),
        );
        _lastSyncTime = latestEvent['timestamp'] != null 
            ? DateTime.parse(latestEvent['timestamp']).toLocal() 
            : DateTime.now();
      }
      notifyListeners();
    }
  }
}
