import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../data/models/disease_report.dart';

class DiseaseProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  File? _compressedImage;
  bool _isProcessing = false;
  DiseaseReport? _report;
  String? _errorMessage;

  File? get selectedImage => _selectedImage;
  File? get compressedImage => _compressedImage;
  bool get isProcessing => _isProcessing;
  DiseaseReport? get report => _report;
  String? get errorMessage => _errorMessage;

  // Pick image from gallery or camera
  Future<bool> selectImage(ImageSource source) async {
    _errorMessage = null;
    _report = null;
    _selectedImage = null;
    _compressedImage = null;
    notifyListeners();

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (file == null) return false;

      _selectedImage = File(file.path);
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

  // Compress image to fit OWASP standards (under 2MB, scaled down)
  Future<void> _compressImage() async {
    if (_selectedImage == null) return;
    _isProcessing = true;
    notifyListeners();

    try {
      final bytes = await _selectedImage!.readAsBytes();
      img.Image? decoded = img.decodeImage(bytes);

      if (decoded == null) throw Exception("Erreur décodage image");

      // Resize if too large
      if (decoded.width > 800) {
        decoded = img.copyResize(decoded, width: 800);
      }

      // Compress JPEG
      final compressedBytes = img.encodeJpg(decoded, quality: 75);

      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      _compressedImage = compressedFile;
    } catch (e) {
      print("[DiseaseProvider] Image compression error: $e");
      // Fallback to original if compression fails
      _compressedImage = _selectedImage;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Simulate upload and detection (API will be connected later)
  Future<void> runDetection() async {
    if (_compressedImage == null) return;

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Return a random mock disease report
      final reports = _getMockReports();
      _report = reports[Random().nextInt(reports.length)];
    } catch (e) {
      _errorMessage = "Erreur de connexion au serveur d'analyse.";
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
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
      ),
    ];
  }
}
