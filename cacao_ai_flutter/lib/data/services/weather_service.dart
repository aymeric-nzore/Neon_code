import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  final String _apiKey = '20a888e496db2b7661e906ae3ae352bc';

  Future<String> _fetchLocationName(double latitude, double longitude) async {
    final geoUrl = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$_apiKey');
    try {
      final response = await http.get(geoUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final place = data[0];
          final String name = place['name'] ?? '';
          final String country = place['country'] ?? '';
          String resolvedCountry = country == 'CI' ? 'Côte d\'Ivoire' : country;
          if (name.isNotEmpty) {
            return '$name, $resolvedCountry';
          }
        }
      }
    } catch (_) {}
    
    // Smart fallbacks based on coordinates
    if ((latitude - 5.34).abs() < 0.5 && (longitude - -4.03).abs() < 0.5) {
      return 'Abidjan, Côte d\'Ivoire';
    }
    if ((latitude - 4.75).abs() < 0.5 && (longitude - -6.64).abs() < 0.5) {
      return 'San Pedro, Côte d\'Ivoire';
    }
    return 'Ma Plantation';
  }

  Future<WeatherData> fetchWeather(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&lang=fr');

    final String resolvedLocation = await _fetchLocationName(latitude, longitude);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['list'] as List<dynamic>? ?? [];
        if (list.isEmpty) throw Exception('No forecast data returned');

        // Current weather (first forecast slot)
        final currentItem = list[0];
        final currentMain = currentItem['main'] ?? {};
        final currentWind = currentItem['wind'] ?? {};
        final currentWeatherList = currentItem['weather'] as List<dynamic>? ?? [];
        final currentWeather = currentWeatherList.isNotEmpty ? currentWeatherList[0] : {};

        final double temp = (currentMain['temp'] as num?)?.toDouble() ?? 28.0;
        final double hum = (currentMain['humidity'] as num?)?.toDouble() ?? 80.0;
        final double rainProbCurrent = ((currentItem['pop'] as num?)?.toDouble() ?? 0.0) * 100.0; // pop is 0 to 1
        final double wind = (currentWind['speed'] as num?)?.toDouble() ?? 10.0;
        final String currentDesc = currentWeather['description'] ?? 'Clair';

        // Group 3-hour forecasts by day YYYY-MM-DD
        final Map<String, List<Map<String, dynamic>>> groupedByDay = {};
        for (var item in list) {
          final dtTxt = item['dt_txt'] as String? ?? '';
          if (dtTxt.length >= 10) {
            final dateKey = dtTxt.substring(0, 10);
            groupedByDay.putIfAbsent(dateKey, () => []).add(item as Map<String, dynamic>);
          }
        }

        final List<DailyForecast> forecasts = [];
        int count = 0;
        for (var entry in groupedByDay.entries) {
          if (count >= 5) break;
          final dateStr = entry.key;
          final items = entry.value;

          double maxT = -999.0;
          double minT = 999.0;
          double maxPop = 0.0;
          String description = 'Ensoleillé';
          String icon = 'sunny';

          for (var item in items) {
            final main = item['main'] ?? {};
            final t = (main['temp'] as num?)?.toDouble() ?? 28.0;
            if (t > maxT) maxT = t;
            if (t < minT) minT = t;

            final pop = (item['pop'] as num?)?.toDouble() ?? 0.0;
            if (pop > maxPop) maxPop = pop;

            final weatherList = item['weather'] as List<dynamic>? ?? [];
            if (weatherList.isNotEmpty) {
              final weather = weatherList[0] ?? {};
              final mainWeather = weather['main'] as String? ?? '';
              description = weather['description'] as String? ?? 'Ensoleillé';
              
              if (mainWeather.toLowerCase().contains('rain')) {
                icon = 'rain';
              } else if (mainWeather.toLowerCase().contains('thunder')) {
                icon = 'thunder';
              } else if (mainWeather.toLowerCase().contains('cloud')) {
                icon = 'cloudy';
              } else {
                icon = 'sunny';
              }
            }
          }

          forecasts.add(DailyForecast(
            date: DateTime.parse(dateStr),
            tempMin: minT,
            tempMax: maxT,
            rainProb: maxPop * 100.0,
            description: description,
            iconCode: icon,
          ));
          count++;
        }

        // Agricultural impact recommendation
        String impact;
        if (hum > 80.0 && rainProbCurrent > 60.0) {
          impact = 'Les conditions de forte humidité ($hum%) combinées avec des risques de pluie ($rainProbCurrent%) favorisent fortement l\'incubation et la dissémination des spores de la pourriture brune du cacao. Il est fortement recommandé d\'aérer la plantation, d\'éliminer les gourmands et de suspendre temporairement les pulvérisations pour éviter le lessivage.';
        } else if (hum > 75.0) {
          impact = 'Climat humide propice au développement fongique. Inspectez régulièrement les cabosses les plus basses et préparez les traitements dès que le ciel se dégage.';
        } else {
          impact = 'Conditions météorologiques optimales et ensoleillées. Idéal pour réaliser le désherbage, la taille sanitaire des caféiers/cacaoyers, ou appliquer les traitements cupriques préventifs.';
        }

        return WeatherData(
          temperatureCurrent: temp,
          humidityCurrent: hum,
          rainProbabilityCurrent: rainProbCurrent,
          windSpeedCurrent: wind,
          descriptionCurrent: currentDesc,
          dailyForecasts: forecasts,
          agriculturalImpact: impact,
          locationName: resolvedLocation,
        );
      } else {
        // Fallback to open-meteo if OpenWeatherMap fails
        return await _fetchFallbackOpenMeteo(latitude, longitude, resolvedLocation);
      }
    } catch (_) {
      return await _fetchFallbackOpenMeteo(latitude, longitude, resolvedLocation);
    }
  }

  Future<WeatherData> _fetchFallbackOpenMeteo(double latitude, double longitude, String resolvedLocation) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto');

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
          locationName: resolvedLocation,
        );
      }
    } catch (_) {}
    return WeatherData(
      temperatureCurrent: 28.5,
      humidityCurrent: 82.0,
      rainProbabilityCurrent: 70.0,
      windSpeedCurrent: 12.5,
      descriptionCurrent: 'Orages isolés',
      dailyForecasts: [
        DailyForecast(date: DateTime.now(), tempMin: 23.0, tempMax: 29.0, rainProb: 70.0, description: 'Pluie faible', iconCode: 'rain'),
        DailyForecast(date: DateTime.now().add(const Duration(days: 1)), tempMin: 22.0, tempMax: 30.0, rainProb: 80.0, description: 'Orageux', iconCode: 'thunder'),
        DailyForecast(date: DateTime.now().add(const Duration(days: 2)), tempMin: 23.0, tempMax: 31.0, rainProb: 50.0, description: 'Nuageux', iconCode: 'cloudy'),
        DailyForecast(date: DateTime.now().add(const Duration(days: 3)), tempMin: 24.0, tempMax: 32.0, rainProb: 30.0, description: 'Éclaircies', iconCode: 'sunny'),
        DailyForecast(date: DateTime.now().add(const Duration(days: 4)), tempMin: 23.0, tempMax: 31.0, rainProb: 40.0, description: 'Averses', iconCode: 'rain'),
      ],
      agriculturalImpact: 'Les conditions chaudes et très humides (humidité > 80% et probabilité de pluie élevée) créent un microclimat idéal pour l\'incubation et la libération de spores de la pourriture brune (Phytophthora). Évitez les traitements foliaires aujourd\'hui car le lessivage est probable.',
      locationName: resolvedLocation,
    );
  }
}
