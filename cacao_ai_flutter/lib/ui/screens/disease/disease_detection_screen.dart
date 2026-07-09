import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/disease_provider.dart';
import '../../theme/app_theme.dart';

class DiseaseDetectionScreen extends StatelessWidget {
  const DiseaseDetectionScreen({Key? key}) : super(key: key);

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final provider = Provider.of<DiseaseProvider>(context, listen: false);
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  provider.selectImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  provider.selectImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiseaseProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détection de Maladie'),
        actions: [
          if (provider.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.riskCritical),
              onPressed: () => provider.reset(),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: isWideScreen
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Image scanner interface
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildImagePreviewArea(context, provider),
                              const SizedBox(height: 20),
                              _buildStatusAndAction(context, provider),
                            ],
                          ),
                        ),
                        const SizedBox(width: 28),

                        // Right Column: Diagnostic Results
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (provider.report != null) ...[
                                const Text(
                                  'Résultats du Diagnostic',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                                ),
                                const SizedBox(height: 12),
                                _buildReportCard(provider),
                              ] else ...[
                                _buildInstructionCard(provider),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildImagePreviewArea(context, provider),
                        const SizedBox(height: 20),
                        _buildStatusAndAction(context, provider),
                        const SizedBox(height: 24),
                        if (provider.report != null) ...[
                          const Text(
                            'Résultats du Diagnostic',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                          ),
                          const SizedBox(height: 12),
                          _buildReportCard(provider),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewArea(BuildContext context, DiseaseProvider provider) {
    if (provider.selectedImage == null) {
      return InkWell(
        onTap: () => _showImageSourceActionSheet(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
            boxShadow: AppTheme.softShadow,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 64, color: AppTheme.primaryGreen),
              SizedBox(height: 16),
              Text(
                'Prendre ou importer une photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textLight),
              ),
              SizedBox(height: 8),
              Text(
                'Scan de feuille ou cabosse infectée',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 240,
        color: AppTheme.bgCard,
        child: Image.file(
          provider.selectedImage!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusAndAction(BuildContext context, DiseaseProvider provider) {
    if (provider.selectedImage == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (provider.compressedImage != null && !provider.isProcessing && provider.report == null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 18),
                SizedBox(width: 8),
                Text(
                  'Image optimisée et prête à analyser',
                  style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (provider.isProcessing) ...[
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text('Analyse en cours...', style: TextStyle(color: AppTheme.textMuted)),
              ],
            ),
          ),
        ] else if (provider.report == null) ...[
          ElevatedButton.icon(
            onPressed: () => provider.runDetection(),
            icon: const Icon(Icons.psychology_outlined),
            label: const Text('Lancer le diagnostic IA'),
          ),
        ],
      ],
    );
  }

  Widget _buildReportCard(DiseaseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  provider.report!.diseaseName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(provider.report!.confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            provider.report!.description,
            style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textMuted),
          ),
          if (provider.report!.severityPercent != null && provider.report!.severityPercent! > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sévérité estimée :',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                ),
                Text(
                  '${provider.report!.severityPercent!.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: provider.report!.severityPercent! / 100,
                color: Colors.orange,
                backgroundColor: Colors.orange.withOpacity(0.15),
                minHeight: 8,
              ),
            ),
          ],
          const Divider(color: Colors.black12, height: 32),
          const Text(
            'Traitement recommandé :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textLight),
          ),
          const SizedBox(height: 8),
          ...provider.report!.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right, color: AppTheme.primaryGreen),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mesures préventives :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textLight),
          ),
          const SizedBox(height: 8),
          ...provider.report!.prevention.map(
            (prev) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.purple, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prev,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => provider.reset(),
            child: const Text('Scanner une autre image'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(DiseaseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: AppTheme.softShadow,
      ),
      child: const Column(
        children: [
          Icon(Icons.psychology_outlined, size: 48, color: AppTheme.primaryGreen),
          SizedBox(height: 16),
          Text(
            'Prêt pour le diagnostic IA',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Prenez en photo une feuille présentant des symptômes (taches, flétrissement, déformation) ou importez-la de votre galerie pour lancer le modèle d\'analyse.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
