import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../providers/editor_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/spooky_snackbar.dart';
import '../../widgets/animations/pulsing_glow.dart';

/// Result Screen - Display and interact with transformed photo
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  bool _showingOriginal = false;
  bool _isFullScreen = false;
  double _intensityValue = 1.0;

  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    if (_isFullScreen) {
      return _buildFullScreenView(provider);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: HalloweenGradients.spookyNight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildImageDisplay(provider),
              ),
              _buildControls(provider),
              _buildActionButtons(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            color: AppConstants.primaryOrange,
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppConstants.homeRoute,
                (route) => false,
              );
            },
          ),
          Expanded(
            child: PulsingGlow(
              glowColor: AppConstants.primaryOrange,
              child: Text(
                'Transformation Complete!',
                style: GoogleFonts.creepster(
                  fontSize: 24,
                  color: AppConstants.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildImageDisplay(EditorProvider provider) {
    final displayImage = _showingOriginal
        ? provider.originalImage
        : provider.currentImage;

    if (displayImage == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isFullScreen = true;
        });
      },
      onLongPress: () {
        setState(() {
          _showingOriginal = true;
        });
      },
      onLongPressEnd: (_) {
        setState(() {
          _showingOriginal = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryOrange.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                displayImage,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
            // Comparison indicator
            if (_showingOriginal)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Original',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            // Fullscreen hint
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fullscreen,
                  color: AppConstants.ghostWhite.withValues(alpha: 0.8),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(EditorProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Compare button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showingOriginal = !_showingOriginal;
                    });
                  },
                  icon: Icon(
                    _showingOriginal
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                  ),
                  label: Text(
                    _showingOriginal ? 'Show Result' : 'Compare Original',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryOrange,
                    side: BorderSide(
                      color: AppConstants.primaryOrange.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hold image to preview original',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppConstants.ghostWhite.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EditorProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstants.darkPurple.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Main action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.save_alt,
                  label: 'Save',
                  gradient: HalloweenGradients.pumpkinGlow,
                  onTap: () => _saveImage(provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  gradient: HalloweenGradients.witchPotion,
                  onTap: () => _shareImage(provider),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Secondary actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppConstants.styleGalleryRoute,
                    );
                  },
                  icon: const Icon(Icons.auto_awesome, size: 20),
                  label: Text(
                    'Try Another Style',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryOrange,
                    side: BorderSide(
                      color: AppConstants.primaryOrange.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppConstants.homeRoute,
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.add_photo_alternate, size: 20),
                  label: Text(
                    'New Photo',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.ghostWhite,
                    side: BorderSide(
                      color: AppConstants.ghostWhite.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryOrange.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenView(EditorProvider provider) {
    final displayImage = _showingOriginal
        ? provider.originalImage
        : provider.currentImage;

    if (displayImage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: MemoryImage(displayImage),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        _isFullScreen = false;
                      });
                    },
                  ),
                  if (provider.originalImage != null)
                    IconButton(
                      icon: Icon(
                        _showingOriginal
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          _showingOriginal = !_showingOriginal;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(EditorProvider provider) async {
    if (provider.currentImage == null) return;

    try {
      final result = await ImageGallerySaver.saveImage(
        provider.currentImage!,
        quality: AppConstants.jpegQuality,
        name: 'spookedit_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        if (result['isSuccess'] == true) {
          SpookySnackbar.showSuccess(
            context,
            'Saved to gallery! 🎃',
          );
        } else {
          SpookySnackbar.showError(
            context,
            'Failed to save image',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SpookySnackbar.showError(
          context,
          'Error saving image: $e',
        );
      }
    }
  }

  Future<void> _shareImage(EditorProvider provider) async {
    if (provider.currentImage == null) return;

    try {
      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/spookedit_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(provider.currentImage!);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my spooky transformation! 🎃 #SpookEdit',
      );
    } catch (e) {
      if (mounted) {
        SpookySnackbar.showError(
          context,
          'Error sharing image: $e',
        );
      }
    }
  }
}
