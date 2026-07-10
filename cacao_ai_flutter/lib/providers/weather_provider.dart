import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/weather_data.dart';
import '../data/repositories/weather_repository.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repository = WeatherRepository();

  bool _isLoading = false;
  String? _errorMessage;
  WeatherData? _weatherData;
  LocationPermission _locationPermission = LocationPermission.unableToDetermine;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WeatherData? get weatherData => _weatherData;
  LocationPermission get locationPermission => _locationPermission;

  WeatherProvider() {
    initLocationAndWeather();
  }

  Future<void> initLocationAndWeather() async {
    if (kIsWeb) {
      try {
        final permission = await Geolocator.checkPermission();
        _locationPermission = permission;
        notifyListeners();
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          await fetchWeatherWithCurrentLocation();
        } else {
          // Fallback to default (San Pedro) without pop-up on start
          await fetchWeather(latitude: 4.75, longitude: -6.64);
        }
      } catch (_) {
        await fetchWeather(latitude: 4.75, longitude: -6.64);
      }
    } else {
      await fetchWeatherWithCurrentLocation();
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      if (!kIsWeb) {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return null;
        }
      }

      permission = await Geolocator.checkPermission();
      _locationPermission = permission;
      notifyListeners();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        _locationPermission = permission;
        notifyListeners();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
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

  Future<void> fetchWeatherWithCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _determinePosition();
      if (position != null) {
        await fetchWeather(latitude: position.latitude, longitude: position.longitude);
      } else {
        // Fallback to default coordinates (San Pedro)
        await fetchWeather(latitude: 4.75, longitude: -6.64);
      }
    } catch (e) {
      await fetchWeather(latitude: 4.75, longitude: -6.64);
    }
  }
}
