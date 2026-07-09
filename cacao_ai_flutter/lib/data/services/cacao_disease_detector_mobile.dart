import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'cacao_disease_detector.dart';
import 'cacao_disease_detector_stub.dart';

CacaoPlatformDetector getPlatformDetector() => MobileCacaoDiseaseDetector();

class MobileCacaoDiseaseDetector implements CacaoPlatformDetector {
  Interpreter? _interpreter;

  static const List<String> _classNames = [
    "black_pod",
    "healthy",
    "moniliasis",
    "pod_borer",
    "witches_broom",
  ];

  static const int _inputSize = 224;

  @override
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/cacao_model.tflite',
    );
  }

  @override
  Future<DiseaseResult> analyzeImage(XFile imageFile) async {
    if (_interpreter == null) {
      throw Exception("Modèle non chargé — appelle loadModel() d'abord");
    }

    final rawBytes = await imageFile.readAsBytes();
    img.Image? decoded = img.decodeImage(rawBytes);
    if (decoded == null) throw Exception("Impossible de lire l'image");

    final resized = img.copyResize(
      decoded,
      width: _inputSize,
      height: _inputSize,
    );

    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ),
    );

    final output = List.filled(
      1 * _classNames.length,
      0.0,
    ).reshape([1, _classNames.length]);

    _interpreter!.run(input, output);

    final List<double> probabilities = List<double>.from(output[0]);

    int maxIndex = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }
    final predictedClass = _classNames[maxIndex];

    if (predictedClass == "healthy") {
      return DiseaseResult(
        diseaseName: "Sain",
        confidence: maxProb,
        severityPercent: 0,
        riskLevel: "surveillance",
        recommendedAction:
            "Aucune maladie détectée. Continuez la surveillance régulière.",
      );
    }

    final severity = _estimateSeverity(resized, predictedClass);
    final riskLevel = _riskLevelFromSeverity(severity);
    final action = _actionFromRiskLevel(riskLevel);

    return DiseaseResult(
      diseaseName: _displayName(predictedClass),
      confidence: maxProb,
      severityPercent: severity,
      riskLevel: riskLevel,
      recommendedAction: action,
    );
  }

  double _estimateSeverity(img.Image image, String diseaseClass) {
    int matchingPixels = 0;
    final totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        if (_isLesionColor(r, g, b, diseaseClass)) {
          matchingPixels++;
        }
      }
    }

    final percent = (matchingPixels / totalPixels) * 100;
    return percent.clamp(5, 100);
  }

  bool _isLesionColor(int r, int g, int b, String diseaseClass) {
    switch (diseaseClass) {
      case "black_pod":
        return r < 90 && g < 80 && b < 80;
      case "moniliasis":
        return r > 150 && g > 130 && b < 100;
      case "pod_borer":
        return r > 100 && r < 170 && g < 100 && b < 90;
      case "witches_broom":
        return r > 90 && r < 160 && g > 80 && g < 150 && b > 60 && b < 130;
      default:
        return false;
    }
  }

  String _riskLevelFromSeverity(double severity) {
    if (severity < 20) return "surveillance";
    if (severity < 50) return "vigilance";
    return "urgence";
  }

  String _displayName(String classKey) {
    const names = {
      "black_pod": "Pourriture brune (Black pod)",
      "moniliasis": "Moniliasis (peau jaune)",
      "pod_borer": "Dégâts de mirides / pod borer",
      "witches_broom": "Balai de sorcière",
    };
    return names[classKey] ?? classKey;
  }

  String _actionFromRiskLevel(String riskLevel) {
    switch (riskLevel) {
      case "surveillance":
        return "Lésion précoce détectée. Surveillez cette cabosse, aucune action urgente pour l'instant.";
      case "vigilance":
        return "Progression modérée. Retirez la cabosse infectée et traitez préventivement les cabosses voisines.";
      case "urgence":
        return "Infection avancée. Retirez et détruisez la cabosse immédiatement pour éviter la propagation. Contactez votre agent de coopérative.";
      default:
        return "";
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
  }
}
