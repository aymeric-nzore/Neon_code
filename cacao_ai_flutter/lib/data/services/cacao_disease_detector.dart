import 'package:image_picker/image_picker.dart';
import 'cacao_disease_detector_stub.dart'
  if (dart.library.html) 'cacao_disease_detector_web.dart'
  if (dart.library.io) 'cacao_disease_detector_mobile.dart';

/// Résultat d'une analyse de cabosse/feuille de cacaoyer
class DiseaseResult {
  final String diseaseName;
  final double confidence; // 0.0 à 1.0 — certitude du diagnostic
  final double severityPercent; // 0 à 100 — % de la zone atteinte
  final String riskLevel; // "surveillance" | "vigilance" | "urgence"
  final String recommendedAction;

  DiseaseResult({
    required this.diseaseName,
    required this.confidence,
    required this.severityPercent,
    required this.riskLevel,
    required this.recommendedAction,
  });
}

class CacaoDiseaseDetector {
  final _platformDetector = getPlatformDetector();

  Future<void> loadModel() => _platformDetector.loadModel();
  Future<DiseaseResult> analyzeImage(XFile imageFile) => _platformDetector.analyzeImage(imageFile);
  void dispose() => _platformDetector.dispose();
}
