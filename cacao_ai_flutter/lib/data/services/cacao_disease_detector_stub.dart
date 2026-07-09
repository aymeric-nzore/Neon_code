import 'package:image_picker/image_picker.dart';
import 'cacao_disease_detector.dart';

CacaoPlatformDetector getPlatformDetector() => throw UnsupportedError('Platform not supported');

abstract class CacaoPlatformDetector {
  Future<void> loadModel();
  Future<DiseaseResult> analyzeImage(XFile imageFile);
  void dispose();
}
