import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/main_navigation_screen.dart';

class MascotTutorialDialog extends StatefulWidget {
  const MascotTutorialDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MascotTutorialDialog(),
    );
  }

  @override
  State<MascotTutorialDialog> createState() => _MascotTutorialDialogState();
}

class _MascotTutorialDialogState extends State<MascotTutorialDialog> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Bienvenue sur Azur !',
      'description': 'Bonjour ! Je suis Azo, ton guide éléphant personnel. Suis-moi pour faire le tour des fonctionnalités de ton outil d\'aide à la décision agronomique !',
      'image': 'assets/images/elephant_mascot.png',
      'tabIndex': 0,
    },
    {
      'title': 'Analyse du Sol & Risque',
      'description': 'Ici dans l\'onglet "Sol", tu peux suivre l\'humidité du sol, l\'acidité pH, et l\'évolution du risque de pourriture brune générée par notre modèle LSTM.',
      'image': 'assets/images/elephant_pose_analyze.png',
      'tabIndex': 1,
    },
    {
      'title': 'Conseiller Virtuel AgriIA',
      'description': 'Besoin d\'un conseil de traitement ou d\'irrigation ? Clique sur mon bouton central surélevé pour poser toutes tes questions à AgriIA.',
      'image': 'assets/images/elephant_pose_chat.png',
      'tabIndex': 2,
    },
    {
      'title': 'Diagnostic Photo par IA',
      'description': 'Dans l\'onglet "Santé", prends en photo les cabosses ou feuilles suspectes de tes cacaoyers pour identifier immédiatement s\'ils ont contracté la maladie.',
      'image': 'assets/images/elephant_pose_scan.png',
      'tabIndex': 3,
    },
    {
      'title': 'Configuration de Plantation',
      'description': 'Enfin, dans l\'onglet "Profil", configure les paramètres de ta plantation, gère ton compte ou active le mode Démo à tout moment !',
      'image': 'assets/images/elephant_pose_success.png',
      'tabIndex': 4,
    },
  ];

  void _navigateToStep(int stepIndex) {
    setState(() {
      _currentStep = stepIndex;
    });
    // Programmatically switch navigation tab to display the target screen
    final nav = MainNavigationScreen.of(context);
    if (nav != null) {
      nav.setIndex(_steps[stepIndex]['tabIndex'] as int);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Dialog(
      backgroundColor: AppTheme.bgCard,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mascot Pose Header
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(step['image'] as String),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentStep ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentStep ? AppTheme.primaryGreen : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              step['title'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              step['description'] as String,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Navigation Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () => _navigateToStep(_currentStep - 1),
                    child: const Text(
                      'Précédent',
                      style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      // Skip tutorial and return to dashboard
                      final nav = MainNavigationScreen.of(context);
                      nav?.setIndex(0);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Passer',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < _steps.length - 1) {
                      _navigateToStep(_currentStep + 1);
                    } else {
                      // Finish tutorial and return to dashboard
                      final nav = MainNavigationScreen.of(context);
                      nav?.setIndex(0);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentStep == _steps.length - 1 ? 'C\'est parti !' : 'Suivant',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
