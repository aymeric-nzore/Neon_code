import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherRepository {
  final WeatherService _weatherService = WeatherService();

  Future<WeatherData> getPlantationWeather({double latitude = 4.75, double longitude = -6.64}) async {
    return await _weatherService.fetchWeather(latitude, longitude);
  }
}
