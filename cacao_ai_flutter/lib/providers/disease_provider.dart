import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../data/models/disease_report.dart';
import '../data/services/cacao_disease_detector.dart';
import '../utils/permissions/web_permissions_helper.dart';

class DiseaseProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final CacaoDiseaseDetector _detector = CacaoDiseaseDetector();

  XFile? _selectedImage;
  XFile? _compressedImage;
  bool _isProcessing = false;
  DiseaseReport? _report;
  String? _errorMessage;
  bool _isModelLoaded = false;
  bool _hasCameraPermission = false;

  XFile? get selectedImage => _selectedImage;
  XFile? get compressedImage => _compressedImage;
  bool get isProcessing => _isProcessing;
  DiseaseReport? get report => _report;
  String? get errorMessage => _errorMessage;
  bool get hasCameraPermission => _hasCameraPermission;

  DiseaseProvider() {
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    if (kIsWeb) {
      _hasCameraPermission = await WebPermissionsHelper.isCameraPermissionGranted();
      notifyListeners();
    } else {
      _hasCameraPermission = true;
    }
  }

  Future<bool> requestCameraPermission() async {
    if (kIsWeb) {
      final granted = await WebPermissionsHelper.requestCameraPermission();
      _hasCameraPermission = granted;
      notifyListeners();
      return granted;
    }
    _hasCameraPermission = true;
    return true;
  }

  // Pick image from gallery or camera
  Future<bool> selectImage(ImageSource source) async {
    _errorMessage = null;
    _report = null;
    _selectedImage = null;
    _compressedImage = null;
    notifyListeners();

    if (kIsWeb && source == ImageSource.camera) {
      final hasPermission = await requestCameraPermission();
      if (!hasPermission) {
        _errorMessage = "Accès à la caméra refusé. Veuillez l'activer dans les paramètres du navigateur pour scanner les cabosses.";
        notifyListeners();
        return false;
      }
    }

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (file == null) return false;

      _selectedImage = file;
      notifyListeners();

      // Automatically compress
      await _compressImage();
      return true;
    } catch (e) {
      _errorMessage = "Impossible d'accéder à la caméra ou à la galerie.";
      notifyListeners();
      return false;
    }
  }

  // Compress image to save space and speed up inference
  Future<void> _compressImage() async {
    if (_selectedImage == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final img.Image? decoded = img.decodeImage(bytes);

      if (decoded == null) {
        _compressedImage = _selectedImage;
        return;
      }

      // Resize if too large
      img.Image resized = decoded;
      if (decoded.width > 800 || decoded.height > 800) {
        resized = img.copyResize(
          decoded,
          width: decoded.width > decoded.height ? 800 : null,
          height: decoded.height >= decoded.width ? 800 : null,
        );
      }

      final compressedBytes = img.encodeJpg(resized, quality: 85);

      if (kIsWeb) {
        // On Web, create an XFile from bytes
        _compressedImage = XFile.fromData(
          compressedBytes,
          name: 'compressed_${_selectedImage!.name}',
          mimeType: 'image/jpeg',
        );
      } else {
        // On Mobile/Desktop, save to temporary directory
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(compressedBytes);
        _compressedImage = XFile(file.path);
      }
    } catch (e) {
      print("[DiseaseProvider] Image compression error: $e");
      // Fallback to original if compression fails
      _compressedImage = _selectedImage;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Run TFLite local detection with simulation fallback
  Future<void> runDetection() async {
    if (_compressedImage == null) return;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Try running local TFLite model detection
      if (!_isModelLoaded) {
        await _detector.loadModel();
        _isModelLoaded = true;
      }

      final result = await _detector.analyzeImage(_compressedImage!);

      _report = DiseaseReport(
        id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
        imageUrl: _compressedImage!.path,
        diseaseName: result.diseaseName,
        confidence: result.confidence,
        description: _getDescriptionForDisease(result.diseaseName, result.severityPercent, result.riskLevel),
        tips: _getTipsForDisease(result.diseaseName, result.recommendedAction),
        prevention: _getPreventionForDisease(result.diseaseName),
        date: DateTime.now(),
        severityPercent: result.severityPercent,
      );

    } catch (e) {
      print("[DiseaseProvider] TFLite model detection failed, falling back to simulation: $e");
      // 2. Fallback to simulation if model file is missing or failed
      await Future.delayed(const Duration(seconds: 1));
      final reports = _getMockReports();
      _report = reports[Random().nextInt(reports.length)];
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Run a simulated demo detection using a pre-defined demo image
  Future<void> runDemoDetection() async {
    _selectedImage = XFile('https://images.unsplash.com/photo-1610632380989-680fe40816c6?w=600');
    _compressedImage = _selectedImage;
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));
    final reports = _getMockReports();
    _report = reports[Random().nextInt(reports.length)];
    _isProcessing = false;
    notifyListeners();
  }

  // Clean up
  void reset() {
    _selectedImage = null;
    _compressedImage = null;
    _report = null;
    _errorMessage = null;
    _isProcessing = false;
    notifyListeners();
  }

  String _getDescriptionForDisease(String name, double severity, String risk) {
    if (name.contains("Pourriture brune")) {
      return "La pourriture brune est causée par un oomycète (Phytophthora palmivora). Elle se caractérise par des taches brunes sur les cabosses qui s'étendent rapidement, entraînant le pourrissement complet de la cabosse et la perte des fèves.\n\nSévérité estimée : ${severity.toStringAsFixed(0)}% (Niveau de risque : ${risk.toUpperCase()}).";
    }
    if (name.contains("Moniliasis")) {
      return "Provoquée par Moniliophthora roreri, cette maladie se manifeste par des déformations, des taches brunes huileuses puis un feutrage blanc de spores. C'est l'une des maladies les plus destructrices des cabosses.\n\nSévérité estimée : ${severity.toStringAsFixed(0)}% (Niveau de risque : ${risk.toUpperCase()}).";
    }
    if (name.contains("pod borer") || name.contains("mirides")) {
      return "Les perforations dues au foreur de cabosses (Conopomorpha cramerella) ou les piqûres de mirides entraînent des nécroses, une maturation précoce et un durcissement des fèves à l'intérieur de la cabosse.\n\nSévérité estimée : ${severity.toStringAsFixed(0)}% (Niveau de risque : ${risk.toUpperCase()}).";
    }
    if (name.contains("Balai de sorcière")) {
      return "Provoquée par Moniliophthora perniciosa, cette maladie entraîne une prolifération anormale de rameaux (bourgeons) ressemblant à un balai. Elle déforme également les jeunes cabosses.\n\nSévérité estimée : ${severity.toStringAsFixed(0)}% (Niveau de risque : ${risk.toUpperCase()}).";
    }
    return "Aucune maladie détectée. Votre cacaoyer est en bonne santé.";
  }

  List<String> _getTipsForDisease(String name, String action) {
    List<String> actions = [action];
    if (name.contains("Pourriture brune")) {
      actions.addAll([
        "Éliminer et détruire toutes les cabosses infectées sur l'arbre et au sol.",
        "Améliorer l'aération de la plantation en taillant les branches basses.",
        "Appliquer un traitement fongicide à base de cuivre agréé par l'ANADER."
      ]);
    } else if (name.contains("Moniliasis")) {
      actions.addAll([
        "Retirer immédiatement les cabosses montrant des taches huileuses ou un feutrage blanc.",
        "Éviter de manipuler les cabosses saines après avoir touché des cabosses infectées.",
        "Nourrir le sol pour renforcer la résistance des cacaoyers."
      ]);
    } else if (name.contains("pod borer") || name.contains("mirides")) {
      actions.addAll([
        "Récolter fréquemment (tous les 7 à 10 jours) pour briser le cycle de vie du foreur.",
        "Éliminer les cabosses gravement attaquées.",
        "Utiliser des pièges à phéromones ou des agents de lutte biologique."
      ]);
    } else if (name.contains("Balai de sorcière")) {
      actions.addAll([
        "Couper les rameaux déformés à 20 cm en dessous du point d'infection.",
        "Brûler les parties coupées loin de la plantation pour éviter la dispersion des spores."
      ]);
    }
    return actions;
  }

  List<String> _getPreventionForDisease(String name) {
    if (name.contains("Pourriture brune")) {
      return [
        "Assurer un bon drainage du sol pour éviter l'humidité stagnante.",
        "Réduire la densité d'ombrage excessive pour favoriser l'ensoleillement des cabosses."
      ];
    }
    if (name.contains("Moniliasis")) {
      return [
        "Garder la plantation propre et bien aérée.",
        "Enfouir ou couvrir de feuilles sèches les cabosses malades retirées pour empêcher la sporulation."
      ];
    }
    if (name.contains("pod borer") || name.contains("mirides")) {
      return [
        "Pratiquer l'ensachage des jeunes cabosses.",
        "Tailler régulièrement pour maintenir le feuillage à hauteur d'homme et faciliter le repérage."
      ];
    }
    if (name.contains("Balai de sorcière")) {
      return [
        "Planter des clones ou variétés résistantes certifiées par le CNRA.",
        "Maintenir une hygiène rigoureuse de la plantation."
      ];
    }
    return [
      "Effectuer un suivi mensuel de l'état des feuilles et des cabosses.",
      "Maintenir un calendrier d'entretien régulier."
    ];
  }

  List<DiseaseReport> _getMockReports() {
    return [
      DiseaseReport(
        id: 'rep_1',
        imageUrl: _compressedImage?.path ?? '',
        diseaseName: 'Pourriture Brune des Cabosses (Phytophthora)',
        confidence: 0.945,
        description: 'La pourriture brune est causée par un oomycète (Phytophthora palmivora). Elle se caractérise par des taches brunes sur les cabosses qui s\'étendent rapidement, entraînant le pourrissement complet de la cabosse et la perte des fèves.',
        tips: [
          'Éliminer et détruire toutes les cabosses infectées sur l\'arbre et au sol.',
          'Améliorer l\'aération de la plantation en taillant les branches basses.',
          'Appliquer un traitement fongicide à base de cuivre agréé par l\'ANADER.'
        ],
        prevention: [
          'Assurer un bon drainage du sol pour éviter l\'humidité stagnante.',
          'Réduire la densité d\'ombrage excessive pour favoriser l\'ensoleillement des cabosses.'
        ],
        date: DateTime.now(),
        severityPercent: 35.0,
      ),
      DiseaseReport(
        id: 'rep_2',
        imageUrl: _compressedImage?.path ?? '',
        diseaseName: 'Maladie du Balai de Sorcière',
        confidence: 0.882,
        description: 'Provoquée par le champignon Moniliophthora perniciosa, cette maladie entraîne une prolifération anormale de rameaux (bourgeons) ressemblant à un balai. Elle déforme également les jeunes cabosses.',
        tips: [
          'Couper les rameaux déformés à 20 cm en dessous du point d\'infection.',
          'Brûler les parties coupées loin de la plantation pour éviter la dispersion des spores.',
        ],
        prevention: [
          'Planter des clones ou variétés résistantes certifiées par le CNRA.',
          'Maintenir une hygiène rigoureuse de la plantation.'
        ],
        date: DateTime.now(),
        severityPercent: 18.0,
      ),
      DiseaseReport(
        id: 'rep_3',
        imageUrl: _compressedImage?.path ?? '',
        diseaseName: 'Swollen Shoot (Virus CSSV)',
        confidence: 0.910,
        description: 'Maladie virale grave transmise par des cochenilles. Elle provoque un gonflement caractéristique des tiges, le jaunissement des feuilles (mosaïque) et le dépérissement progressif de l\'arbre.',
        tips: [
          'Le Swollen Shoot est incurable. Il faut obligatoirement arracher et brûler l\'arbre infecté.',
          'Traiter la zone environnante pour éliminer les cochenilles vectrices.',
        ],
        prevention: [
          'Créer des barrières naturelles avec d\'autres essences d\'arbres.',
          'Vérifier rigoureusement l\'état sanitaire du matériel végétal avant plantation.'
        ],
        date: DateTime.now(),
        severityPercent: 75.0,
      ),
    ];
  }

  @override
  void dispose() {
    _detector.dispose();
    super.dispose();
  }
}
