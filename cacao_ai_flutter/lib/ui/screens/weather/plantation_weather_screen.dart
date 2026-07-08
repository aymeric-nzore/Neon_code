import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/weather_provider.dart';
import '../../../data/models/weather_data.dart';
import '../../theme/app_theme.dart';

class PlantationWeatherScreen extends StatelessWidget {
  const PlantationWeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Météo de la Plantation'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: weatherProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
                : weatherProvider.errorMessage != null
                    ? _buildErrorState(weatherProvider)
                    : _buildWeatherBody(context, weatherProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(WeatherProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppTheme.riskCritical),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Erreur lors du chargement de la météo.',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchWeather(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherBody(BuildContext context, WeatherProvider provider) {
    final weather = provider.weatherData;
    if (weather == null) return const SizedBox.shrink();

    final bool isRainy = weather.rainProbabilityCurrent > 50;

    return RefreshIndicator(
      onRefresh: () => provider.fetchWeather(),
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Weather Summary Card
            _buildCurrentWeatherCard(weather, isRainy),
            const SizedBox(height: 20),

            // Smart Ag Analysis Card
            _buildAgriculturalAnalysisCard(weather, isRainy),
            const SizedBox(height: 24),

            // 5-Day Forecast Title
            const Text(
              'Prévisions sur 5 jours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
            ),
            const SizedBox(height: 12),

            // Forecast List
            ...weather.dailyForecasts.map((f) => _buildForecastItem(f)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(WeatherData weather, bool isRainy) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isRainy ? AppTheme.goldGradient : AppTheme.greenGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'San Pedro, Côte d\'Ivoire',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.descriptionCurrent,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Icon(
                isRainy ? Icons.thunderstorm : Icons.wb_sunny_rounded,
                color: Colors.white,
                size: 48,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${weather.temperatureCurrent.toStringAsFixed(1)}°C',
                style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildCurrentDetailItem(Icons.water_drop, 'Humidité', '${weather.humidityCurrent.toStringAsFixed(0)}%'),
                  const SizedBox(height: 6),
                  _buildCurrentDetailItem(Icons.umbrella, 'Pluie', '${weather.rainProbabilityCurrent.toStringAsFixed(0)}%'),
                  const SizedBox(height: 6),
                  _buildCurrentDetailItem(Icons.air, 'Vent', '${weather.windSpeedCurrent.toStringAsFixed(1)} km/h'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDetailItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAgriculturalAnalysisCard(WeatherData weather, bool isRainy) {
    final Color color = isRainy ? AppTheme.primaryOrange : AppTheme.primaryGreen;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                'Analyse Agronomique IA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            weather.agriculturalImpact,
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(DailyForecast forecast) {
    final dayName = DateFormat('EEEE', 'fr').format(forecast.date);
    final capitalizedDay = dayName[0].toUpperCase() + dayName.substring(1);
    
    IconData icon;
    Color iconColor;
    switch (forecast.iconCode) {
      case 'thunder':
        icon = Icons.thunderstorm;
        iconColor = AppTheme.primaryOrange;
        break;
      case 'rain':
        icon = Icons.umbrella;
        iconColor = Colors.blue;
        break;
      case 'cloudy':
        icon = Icons.cloud;
        iconColor = Colors.grey;
        break;
      case 'sunny':
      default:
        icon = Icons.wb_sunny;
        iconColor = AppTheme.accentGold;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizedDay,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textLight),
                ),
                const SizedBox(height: 4),
                Text(
                  forecast.description,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.umbrella, size: 14, color: Colors.blue.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  '${forecast.rainProb.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '${forecast.tempMax.toStringAsFixed(0)}°',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textLight),
              ),
              const SizedBox(width: 8),
              Text(
                '${forecast.tempMin.toStringAsFixed(0)}°',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}
