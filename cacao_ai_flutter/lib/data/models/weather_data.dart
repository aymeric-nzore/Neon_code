class WeatherData {
  final double temperatureCurrent;
  final double humidityCurrent;
  final double rainProbabilityCurrent;
  final double windSpeedCurrent;
  final String descriptionCurrent;
  final List<DailyForecast> dailyForecasts;
  final String agriculturalImpact;
  final String locationName; // Resolved name of the location

  WeatherData({
    required this.temperatureCurrent,
    required this.humidityCurrent,
    required this.rainProbabilityCurrent,
    required this.windSpeedCurrent,
    required this.descriptionCurrent,
    required this.dailyForecasts,
    required this.agriculturalImpact,
    required this.locationName,
  });

  factory WeatherData.fromMock() {
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
      locationName: 'San Pedro, Côte d\'Ivoire',
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double rainProb;
  final String description;
  final String iconCode;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.rainProb,
    required this.description,
    required this.iconCode,
  });
}
