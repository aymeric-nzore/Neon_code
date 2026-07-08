import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../data/services/supabase_service.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Map<String, dynamic>> _sensorHistory = [];
  List<Map<String, dynamic>> _aiEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final plantationId = dashboardProvider.currentData.plantationId;

    final sensors = await _supabaseService.fetchSensorHistory(plantationId);
    final events = await _supabaseService.fetchAIEvents(plantationId);

    setState(() {
      _sensorHistory = sensors;
      _aiEvents = events;
      _isLoading = false;
    });
  }

  Color _getRiskColor(double val) {
    if (val >= 0.70) return AppTheme.riskCritical;
    if (val >= 0.60) return AppTheme.riskHigh;
    if (val >= 0.50) return AppTheme.riskMedium;
    return AppTheme.riskLow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.textLight,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Relevés Capteurs'),
            Tab(text: 'Rapports IA'),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
            : RefreshIndicator(
                onRefresh: _loadHistory,
                color: AppTheme.primaryGreen,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSensorHistoryList(),
                    _buildAIEventsList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSensorHistoryList() {
    if (_sensorHistory.isEmpty) {
      return _buildEmptyState('Aucun relevé de capteur enregistré.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sensorHistory.length,
      itemBuilder: (context, index) {
        final item = _sensorHistory[index];
        final DateTime date = item['timestamp'] != null 
            ? DateTime.parse(item['timestamp']).toLocal() 
            : DateTime.now();
        final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
        final double risk = (item['risk_today'] as num?)?.toDouble() ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(
                    'Temp: ${item['temperature_air']}°C | Hum: ${item['soil_moisture']}% | pH: ${item['soil_ph']}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getRiskColor(risk).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${(risk * 100).toInt()}%',
                    style: TextStyle(
                      color: _getRiskColor(risk),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIEventsList() {
    if (_aiEvents.isEmpty) {
      return _buildEmptyState('Aucun rapport IA enregistré.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _aiEvents.length,
      itemBuilder: (context, index) {
        final item = _aiEvents[index];
        final DateTime date = item['timestamp'] != null 
            ? DateTime.parse(item['timestamp']).toLocal() 
            : DateTime.now();
        final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
        
        final aiReport = item['ai_report'] as Map<String, dynamic>? ?? {};
        final diagnostic = aiReport['diagnostic'] ?? 'Analyse de plantation.';
        final riskLevel = aiReport['risk_level'] ?? 'Faible';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      riskLevel.toString().toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                diagnostic,
                style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: Colors.black.withOpacity(0.03)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppTheme.primaryGreen),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
