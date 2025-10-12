import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../models/halloween_prompt.dart';
import '../../providers/editor_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/spooky_snackbar.dart';
import '../../widgets/animations/floating_bats.dart';
import '../../widgets/animations/pulsing_glow.dart';

/// Home screen - Gallery view and photo selection
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.photos.request();
    await Permission.camera.request();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
      );

      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          context.read<EditorProvider>().initializeImage(bytes);
          // Navigate to style carousel editor
          Navigator.of(context).pushNamed(AppConstants.styleGalleryRoute);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to pick image: $e');
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
      );

      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          context.read<EditorProvider>().initializeImage(bytes);
          // Navigate to style carousel editor
          Navigator.of(context).pushNamed(AppConstants.styleGalleryRoute);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to capture image: $e');
      }
    }
  }

  void _showError(String message) {
    SpookySnackbar.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: HalloweenGradients.spookyNight,
        ),
        child: Stack(
          children: [
            // Floating bats background animation
            const Positioned.fill(
              child: FloatingBatsBackground(
                batCount: 6,
                batColor: AppConstants.primaryOrange,
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PulsingGlow(
                glowColor: AppConstants.primaryOrange,
                minBlur: 5.0,
                maxBlur: 20.0,
                child: Text(
                  AppConstants.appName,
                  style: GoogleFonts.creepster(
                    fontSize: 38,
                    color: AppConstants.primaryOrange,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: AppConstants.primaryOrange.withValues(alpha: 0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hauntingly Beautiful Edits',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppConstants.lightPurple,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstants.primaryOrange.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.history),
                  color: AppConstants.primaryOrange,
                  iconSize: 26,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppConstants.historyRoute);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppConstants.primaryOrange.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  color: AppConstants.primaryOrange,
                  iconSize: 26,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppConstants.settingsRoute);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActions(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get Started',
          style: GoogleFonts.creepster(
            fontSize: 28,
            color: AppConstants.primaryOrange,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a photo to transform',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppConstants.ghostWhite.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 24),
        // Side-by-side buttons
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Pick a photo from your library',
                gradient: HalloweenGradients.pumpkinGlow,
                onTap: _pickImageFromGallery,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.camera_alt,
                title: 'Take a Photo',
                subtitle: 'Capture with your camera',
                gradient: HalloweenGradients.vampireBlood,
                onTap: _pickImageFromCamera,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.mediumAnimation,
        height: 165,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryOrange.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: Colors.white.withValues(alpha: 0.2),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
