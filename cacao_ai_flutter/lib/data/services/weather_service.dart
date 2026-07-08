import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  final String _apiUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> fetchWeather(double latitude, double longitude) async {
    final url = Uri.parse(
        '$_apiUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'] ?? {};
        final daily = data['daily'] ?? {};

        final double temp = (current['temperature_2m'] as num?)?.toDouble() ?? 28.0;
        final double hum = (current['relative_humidity_2m'] as num?)?.toDouble() ?? 80.0;
        final double rain = (current['precipitation'] as num?)?.toDouble() ?? 0.0;
        final double wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;

        // Construct 5-day daily forecast
        final List<DailyForecast> forecasts = [];
        final List<dynamic> dates = daily['time'] ?? [];
        final List<dynamic> tMax = daily['temperature_2m_max'] ?? [];
        final List<dynamic> tMin = daily['temperature_2m_min'] ?? [];
        final List<dynamic> rProb = daily['precipitation_probability_max'] ?? [];

        for (int i = 0; i < dates.length && i < 5; i++) {
          final date = DateTime.parse(dates[i]);
          final maxT = (tMax[i] as num?)?.toDouble() ?? 30.0;
          final minT = (tMin[i] as num?)?.toDouble() ?? 22.0;
          final prob = (rProb[i] as num?)?.toDouble() ?? 40.0;

          String desc = 'Ensoleillé';
          String icon = 'sunny';
          if (prob > 75) {
            desc = 'Orageux';
            icon = 'thunder';
          } else if (prob > 50) {
            desc = 'Pluie';
            icon = 'rain';
          } else if (prob > 20) {
            desc = 'Nuageux';
            icon = 'cloudy';
          }

          forecasts.add(DailyForecast(
            date: date,
            tempMin: minT,
            tempMax: maxT,
            rainProb: prob,
            description: desc,
            iconCode: icon,
          ));
        }

        // Generate smart agricultural impact analysis based on values
        String impact;
        if (hum > 80.0 && (rProb.isNotEmpty && (rProb[0] as num) > 60)) {
          impact = 'Les conditions de forte humidité ($hum%) combinées avec des risques de pluie favorisent fortement l\'incubation et la dissémination des spores de la pourriture brune du cacao. Il est fortement recommandé d\'aérer la plantation, d\'éliminer les gourmands et de suspendre temporairement les pulvérisations pour éviter le lessivage.';
        } else if (hum > 75.0) {
          impact = 'Climat humide propice au développement fongique. Inspectez régulièrement les cabosses les plus basses et préparez les traitements dès que le ciel se dégage.';
        } else {
          impact = 'Conditions météorologiques optimales et ensoleillées. Idéal pour réaliser le désherbage, la taille sanitaire des caféiers/cacaoyers, ou appliquer les traitements cupriques préventifs.';
        }

        String currentDesc = 'Clair';
        if (rain > 2.0) {
          currentDesc = 'Averses de pluie';
        } else if (hum > 85.0) {
          currentDesc = 'Brumeux / Humide';
        } else if (wind > 20.0) {
          currentDesc = 'Venteux';
        }

        return WeatherData(
          temperatureCurrent: temp,
          humidityCurrent: hum,
          rainProbabilityCurrent: rProb.isNotEmpty ? (rProb[0] as num).toDouble() : 50.0,
          windSpeedCurrent: wind,
          descriptionCurrent: currentDesc,
          dailyForecasts: forecasts,
          agriculturalImpact: impact,
        );
      } else {
        return WeatherData.fromMock();
      }
    } catch (_) {
      return WeatherData.fromMock();
    }
  }
}
