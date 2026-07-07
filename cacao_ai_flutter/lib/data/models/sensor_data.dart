import 'dart:convert';

class SensorData {
  final int plantationId;
  final DateTime timestamp;
  final double temperatureAir;
  final double humidityAir;
  final double rainfall;
  final double lightIntensity;
  final double soilMoisture;
  final double soilPh;

  SensorData({
    required this.plantationId,
    required this.timestamp,
    required this.temperatureAir,
    required this.humidityAir,
    required this.rainfall,
    required this.lightIntensity,
    required this.soilMoisture,
    required this.soilPh,
  });

  Map<String, dynamic> toMap() {
    return {
      'plantation_id': plantationId,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'temperature_air': temperatureAir,
      'humidity_air': humidityAir,
      'rainfall': rainfall,
      'light_intensity': lightIntensity,
      'soil_moisture': soilMoisture,
      'soil_ph': soilPh,
    };
  }

  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      plantationId: map['plantation_id']?.toInt() ?? 0,
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']).toLocal() 
          : DateTime.now(),
      temperatureAir: (map['temperature_air'] as num?)?.toDouble() ?? 0.0,
      humidityAir: (map['humidity_air'] as num?)?.toDouble() ?? 0.0,
      rainfall: (map['rainfall'] as num?)?.toDouble() ?? 0.0,
      lightIntensity: (map['light_intensity'] as num?)?.toDouble() ?? 0.0,
      soilMoisture: (map['soil_moisture'] as num?)?.toDouble() ?? 0.0,
      soilPh: (map['soil_ph'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory SensorData.fromJson(String source) => SensorData.fromMap(json.decode(source));
}
