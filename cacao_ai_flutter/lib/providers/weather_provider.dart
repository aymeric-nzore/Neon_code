import 'package:flutter/material.dart';
import '../data/models/weather_data.dart';
import '../data/repositories/weather_repository.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repository = WeatherRepository();

  bool _isLoading = false;
  String? _errorMessage;
  WeatherData? _weatherData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WeatherData? get weatherData => _weatherData;

  WeatherProvider() {
    // Automatically load weather for San Pedro, Côte d'Ivoire (default plantation coordinates)
    fetchWeather();
  }

  Future<void> fetchWeather({double latitude = 4.75, double longitude = -6.64}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.getPlantationWeather(latitude: latitude, longitude: longitude);
      _weatherData = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Impossible de charger les données météo.';
      _isLoading = false;
      notifyListeners();
    }
  }
}
