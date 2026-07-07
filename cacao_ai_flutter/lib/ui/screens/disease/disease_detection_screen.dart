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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Area
              if (provider.selectedImage == null) ...[
                // Empty state for image selection
                InkWell(
                  onTap: () => _showImageSourceActionSheet(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10, style: BorderStyle.values[0]), // dotted border representation
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
                ),
              ] else ...[
                // Image display
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 240,
                    color: AppTheme.bgCard,
                    child: Image.file(
                      provider.selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Compression stats & action
                if (provider.compressedImage != null && !provider.isProcessing && provider.report == null)
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
              ],
              const SizedBox(height: 24),

              // Action buttons & state
              if (provider.isProcessing) ...[
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryGreen),
                      SizedBox(height: 16),
                      Text('Analyse de l\'image en cours...', style: TextStyle(color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ] else if (provider.selectedImage != null && provider.report == null) ...[
                ElevatedButton.icon(
                  onPressed: () => provider.runDetection(),
                  icon: const Icon(Icons.psychology_outlined),
                  label: const Text('Lancer le diagnostic IA'),
                ),
              ],

              // Diagnostic Report Presentation
              if (provider.report != null) ...[
                const Text(
                  'Résultats du Diagnostic',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Disease Name & Confidence
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

                      // Description
                      Text(
                        provider.report!.description,
                        style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textMuted),
                      ),
                      const Divider(color: Colors.white12, height: 32),

                      // Tips / Treatments
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

                      // Prevention
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                OutlinedButton(
                  onPressed: () => provider.reset(),
                  child: const Text('Scanner une autre image'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
