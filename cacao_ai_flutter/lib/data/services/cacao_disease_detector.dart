import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

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
  Interpreter? _interpreter;

  // ⚠️ Ordre confirmé après entraînement réel du 08/07 (5 classes, ordre
  // alphabétique donné par image_dataset_from_directory). Si tu ré-entraînes
  // avec des classes différentes, vérifie class_names.json sur ton Drive
  // et mets à jour cette liste EXACTEMENT dans le même ordre.
  static const List<String> _classNames = [
    "black_pod",
    "healthy",
    "moniliasis",
    "pod_borer",
    "witches_broom",
  ];

  static const int _inputSize = 224;

  /// Charge le modèle TFLite depuis les assets. À appeler une seule fois,
  /// idéalement dans initState() de l'écran principal ou au démarrage de l'app.
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/cacao_model.tflite',
    );
  }

  /// Analyse une photo et retourne le diagnostic complet
  Future<DiseaseResult> analyzeImage(XFile imageFile) async {
    if (_interpreter == null) {
      throw Exception("Modèle non chargé — appelle loadModel() d'abord");
    }

    // 1. Préparation de l'image (resize + normalisation)
    final rawBytes = await imageFile.readAsBytes();
    img.Image? decoded = img.decodeImage(rawBytes);
    if (decoded == null) throw Exception("Impossible de lire l'image");

    final resized = img.copyResize(
      decoded,
      width: _inputSize,
      height: _inputSize,
    );

    // Tenseur d'entrée [1, 224, 224, 3] normalisé 0-1
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

    // 2. Inférence
    final output = List.filled(
      1 * _classNames.length,
      0.0,
    ).reshape([1, _classNames.length]);

    _interpreter!.run(input, output);

    final List<double> probabilities = List<double>.from(output[0]);

    // 3. Classe prédite = probabilité max
    int maxIndex = 0;
    double maxProb = probabilities[0];
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }
    final predictedClass = _classNames[maxIndex];

    // 4. Cas "healthy" : pas de sévérité à calculer
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

    // 5. Estimation de sévérité par analyse de couleur (heuristique v1, cf README)
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

  /// Heuristique de sévérité : % de pixels correspondant à la signature
  /// couleur typique de la maladie détectée. Approche v1 volontairement simple
  /// pour un MVP — à remplacer par un modèle de segmentation entraîné en v2
  /// (le dataset moniliasis a déjà des labels m1/m2/m3 utilisables pour ça).
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
    // Plafonne à 100, plancher à 5% dès qu'une maladie est détectée par le
    // classifieur (évite d'afficher 0% alors que le diagnostic est confiant).
    return percent.clamp(5, 100);
  }

  bool _isLesionColor(int r, int g, int b, String diseaseClass) {
    switch (diseaseClass) {
      case "black_pod":
        // Zones noires/brun foncé
        return r < 90 && g < 80 && b < 80;
      case "moniliasis":
        // Taches jaunes/huileuses caractéristiques
        return r > 150 && g > 130 && b < 100;
      case "pod_borer":
        // Perforations brunâtres/nécrose
        return r > 100 && r < 170 && g < 100 && b < 90;
      case "witches_broom":
        // Tissu sec brun-grisâtre des balais de sorcière
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

  void dispose() {
    _interpreter?.close();
  }
}
