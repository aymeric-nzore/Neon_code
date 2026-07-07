class PredictionResult {
  final String status;
  final RiskScores prediction;
  final AgentReport agent;

  PredictionResult({
    required this.status,
    required this.prediction,
    required this.agent,
  });

  factory PredictionResult.fromMap(Map<String, dynamic> map) {
    return PredictionResult(
      status: map['status'] ?? 'unknown',
      prediction: RiskScores.fromMap(map['prediction'] ?? {}),
      agent: AgentReport.fromMap(map['agent'] ?? {}),
    );
  }
}

class RiskScores {
  final double riskToday;
  final double risk7d;
  final double risk14d;
  final double risk21d;

  RiskScores({
    required this.riskToday,
    required this.risk7d,
    required this.risk14d,
    required this.risk21d,
  });

  factory RiskScores.fromMap(Map<String, dynamic> map) {
    return RiskScores(
      riskToday: (map['risk_today'] as num?)?.toDouble() ?? 0.0,
      risk7d: (map['risk_7d'] as num?)?.toDouble() ?? 0.0,
      risk14d: (map['risk_14d'] as num?)?.toDouble() ?? 0.0,
      risk21d: (map['risk_21d'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AgentReport {
  final String trend;
  final AlertInfo alert;
  final AIReportDetails aiReport;

  AgentReport({
    required this.trend,
    required this.alert,
    required this.aiReport,
  });

  factory AgentReport.fromMap(Map<String, dynamic> map) {
    return AgentReport(
      trend: map['trend'] ?? 'stable',
      alert: AlertInfo.fromMap(map['alert'] ?? {}),
      aiReport: AIReportDetails.fromMap(map['ai_report'] ?? {}),
    );
  }
}

class AlertInfo {
  final String level;
  final String message;

  AlertInfo({
    required this.level,
    required this.message,
  });

  factory AlertInfo.fromMap(Map<String, dynamic> map) {
    return AlertInfo(
      level: map['level'] ?? 'SAFE',
      message: map['message'] ?? 'Aucun alerte détectée.',
    );
  }
}

class AIReportDetails {
  final String diagnostic;
  final String riskLevel;
  final Map<String, String> analysis;
  final List<String> actions;
  final ReportAlertDetails reportAlert;

  AIReportDetails({
    required this.diagnostic,
    required this.riskLevel,
    required this.analysis,
    required this.actions,
    required this.reportAlert,
  });

  factory AIReportDetails.fromMap(Map<String, dynamic> map) {
    final analysisMap = map['analysis'] as Map<String, dynamic>? ?? {};
    final stringAnalysis = analysisMap.map((key, value) => MapEntry(key, value?.toString() ?? ''));

    final actionsList = map['actions'] as List<dynamic>? ?? [];
    final stringActions = actionsList.map((e) => e?.toString() ?? '').toList();

    return AIReportDetails(
      diagnostic: map['diagnostic'] ?? 'Aucun diagnostic disponible.',
      riskLevel: map['risk_level'] ?? 'low',
      analysis: stringAnalysis,
      actions: stringActions,
      reportAlert: ReportAlertDetails.fromMap(map['alert'] ?? {}),
    );
  }
}

class ReportAlertDetails {
  final bool active;
  final String message;

  ReportAlertDetails({
    required this.active,
    required this.message,
  });

  factory ReportAlertDetails.fromMap(Map<String, dynamic> map) {
    return ReportAlertDetails(
      active: map['active'] ?? false,
      message: map['message'] ?? '',
    );
  }
}
