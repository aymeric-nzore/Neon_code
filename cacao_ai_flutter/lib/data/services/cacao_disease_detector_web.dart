import 'package:image_picker/image_picker.dart';
import 'cacao_disease_detector.dart';
import 'cacao_disease_detector_stub.dart';

CacaoPlatformDetector getPlatformDetector() => WebCacaoDiseaseDetector();

class WebCacaoDiseaseDetector implements CacaoPlatformDetector {
  @override
  Future<void> loadModel() async {
    print('[CacaoDiseaseDetector] Running on web. TFLite disabled.');
  }

  @override
  Future<DiseaseResult> analyzeImage(XFile imageFile) async {
    throw UnsupportedError('TFLite inference is not supported on web. Falling back to simulation.');
  }

  @override
  void dispose() {}
}
