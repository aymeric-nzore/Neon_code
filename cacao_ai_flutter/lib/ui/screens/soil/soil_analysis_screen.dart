import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';

class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  final _tempController = TextEditingController();
  final _humController = TextEditingController();
  final _rainController = TextEditingController();
  final _lightController = TextEditingController();
  final _soilHumController = TextEditingController();
  final _phController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    _tempController.text = provider.currentData.temperatureAir.toString();
    _humController.text = provider.currentData.humidityAir.toString();
    _rainController.text = provider.currentData.rainfall.toString();
    _lightController.text = provider.currentData.lightIntensity.toString();
    _soilHumController.text = provider.currentData.soilMoisture.toString();
    _phController.text = provider.currentData.soilPh.toString();
  }

  @override
  void dispose() {
    _tempController.dispose();
    _humController.dispose();
    _rainController.dispose();
    _lightController.dispose();
    _soilHumController.dispose();
    _phController.dispose();
    super.dispose();
  }

  void _showSimulationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune, color: AppTheme.primaryGreen),
                    SizedBox(width: 8),
                    Text(
                      'Simuler les valeurs des capteurs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSimulationInput('Température Air (°C)', _tempController),
                const SizedBox(height: 12),
                _buildSimulationInput('Humidité Air (%)', _humController),
                const SizedBox(height: 12),
                _buildSimulationInput('Précipitations (mm)', _rainController),
                const SizedBox(height: 12),
                _buildSimulationInput('Intensité Lumineuse (klux)', _lightController),
                const SizedBox(height: 12),
                _buildSimulationInput('Humidité Sol (%)', _soilHumController),
                const SizedBox(height: 12),
                _buildSimulationInput('pH Sol', _phController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final provider = Provider.of<DashboardProvider>(context, listen: false);
                    provider.updateSensorField(
                      temperatureAir: double.tryParse(_tempController.text),
                      humidityAir: double.tryParse(_humController.text),
                      rainfall: double.tryParse(_rainController.text),
                      lightIntensity: double.tryParse(_lightController.text),
                      soilMoisture: double.tryParse(_soilHumController.text),
                      soilPh: double.tryParse(_phController.text),
                    );
                    Navigator.pop(context);
                    provider.runAnalysis();
                  },
                  child: const Text('Lancer la prédiction'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimulationInput(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted),
        filled: true,
        fillColor: AppTheme.bgInput,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final data = provider.currentData;
    final prediction = provider.latestPrediction;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse du Sol'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showSimulationBottomSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text('Calcul de la prédiction LSTM...', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isWideScreen)
                          // Wide Screen 2-column layout
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column: Sensor gauges
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildGaugesHeader(provider),
                                    const SizedBox(height: 12),
                                    _buildSensorGaugesCard(data),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Right column: Chart & Recommendations
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (prediction != null) ...[
                                      const Text(
                                        'Évolution du risque prédit (LSTM)',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildChartCard(prediction),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Rapport Agronomique IA',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildAIRecommendationCard(prediction),
                                    ] else
                                      _buildEmptyStateCard(provider),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          // Standard Mobile 1-column layout
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildGaugesHeader(provider),
                              const SizedBox(height: 12),
                              _buildSensorGaugesCard(data),
                              const SizedBox(height: 24),
                              if (prediction != null) ...[
                                const Text(
                                  'Évolution du risque prédit (LSTM)',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                                ),
                                const SizedBox(height: 12),
                                _buildChartCard(prediction),
                                const SizedBox(height: 24),
                                const Text(
                                  'Rapport Agronomique IA',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                                ),
                                const SizedBox(height: 12),
                                _buildAIRecommendationCard(prediction),
                              ] else
                                _buildEmptyStateCard(provider),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGaugesHeader(DashboardProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Valeurs des Capteurs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
        ),
        TextButton.icon(
          onPressed: () => provider.runAnalysis(),
          icon: const Icon(Icons.refresh, size: 16, color: AppTheme.primaryGreen),
          label: const Text('Actualiser', style: TextStyle(color: AppTheme.primaryGreen)),
        ),
      ],
    );
  }

  Widget _buildSensorGaugesCard(dynamic data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          _buildMetricProgressBar('Humidité du sol', data.soilMoisture, '%', 0, 100, Colors.blue),
          const SizedBox(height: 18),
          _buildMetricProgressBar('Température Air', data.temperatureAir, '°C', 0, 50, Colors.red),
          const SizedBox(height: 18),
          _buildMetricProgressBar('pH du sol', data.soilPh, '', 0, 14, Colors.green),
          const SizedBox(height: 18),
          _buildMetricProgressBar('Humidité Air', data.humidityAir, '%', 0, 100, Colors.teal),
          const SizedBox(height: 18),
          _buildMetricProgressBar('Luminosité', data.lightIntensity, 'klux', 0, 200, Colors.amber),
          const SizedBox(height: 18),
          _buildMetricProgressBar('Précipitations', data.rainfall, 'mm', 0, 100, Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildChartCard(dynamic prediction) {
    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 24, right: 24, left: 12, bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  switch (val.toInt()) {
                    case 0:
                      return const Text('Auj.', style: TextStyle(color: AppTheme.textMuted, fontSize: 10));
                    case 1:
                      return const Text('7j', style: TextStyle(color: AppTheme.textMuted, fontSize: 10));
                    case 2:
                      return const Text('14j', style: TextStyle(color: AppTheme.textMuted, fontSize: 10));
                    case 3:
                      return const Text('21j', style: TextStyle(color: AppTheme.textMuted, fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  return Text('${(val * 100).toInt()}%', style: const TextStyle(color: AppTheme.textMuted, fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 3,
          minY: 0,
          maxY: 1.0,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, prediction.prediction.riskToday),
                FlSpot(1, prediction.prediction.risk7d),
                FlSpot(2, prediction.prediction.risk14d),
                FlSpot(3, prediction.prediction.risk21d),
              ],
              isCurved: true,
              color: AppTheme.primaryGreen,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryGreen.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIRecommendationCard(dynamic prediction) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  prediction.agent.aiReport.diagnostic,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 24),
          const Text(
            'Actions recommandées :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textLight),
          ),
          const SizedBox(height: 12),
          ...prediction.agent.aiReport.actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.analytics_outlined, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          const Text(
            'Aucune donnée d\'analyse disponible',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cliquez sur Prédire ou configurez des valeurs personnalisées.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => provider.runAnalysis(),
            child: const Text('Calculer la prédiction'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricProgressBar(
    String label,
    double value,
    String unit,
    double min,
    double max,
    Color color,
  ) {
    final double percentage = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text('${value.toStringAsFixed(1)} $unit', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
