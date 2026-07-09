class DiseaseReport {
  final String id;
  final String imageUrl;
  final String diseaseName;
  final double confidence;
  final String description;
  final List<String> tips;
  final List<String> prevention;
  final DateTime date;
  final double? severityPercent;

  DiseaseReport({
    required this.id,
    required this.imageUrl,
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.tips,
    required this.prevention,
    required this.date,
    this.severityPercent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageUrl,
      'disease_name': diseaseName,
      'confidence': confidence,
      'description': description,
      'tips': tips,
      'prevention': prevention,
      'date': date.toIso8601String(),
      'severity_percent': severityPercent,
    };
  }

  factory DiseaseReport.fromMap(Map<String, dynamic> map) {
    return DiseaseReport(
      id: map['id'] ?? '',
      imageUrl: map['image_url'] ?? '',
      diseaseName: map['disease_name'] ?? 'Inconnue',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? 'Aucune description fournie.',
      tips: List<String>.from(map['tips'] ?? []),
      prevention: List<String>.from(map['prevention'] ?? []),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      severityPercent: (map['severity_percent'] as num?)?.toDouble(),
    );
  }
}
