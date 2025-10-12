import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../../providers/editor_provider.dart';
import '../../services/nano_banana_service.dart';
import '../../services/local_image_filters.dart';
import '../../utils/app_constants.dart';
import '../../widgets/editor/filter_selector.dart';
import '../../widgets/editor/prompt_selector.dart';

/// Main photo editor screen
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  EditorTool _selectedTool = EditorTool.creativePrompts; // Start with prompts
  Size _canvasSize = const Size(300, 400); // Default size, will be updated

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: HalloweenGradients.spookyNight,
        ),
        child: SafeArea(
          child: Consumer<EditorProvider>(
            builder: (context, editor, _) {
              if (editor.currentImage == null) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  _buildTopBar(editor),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildImageViewer(editor.currentImage!),
                        if (editor.isProcessing) _buildLoadingOverlay(editor),
                      ],
                    ),
                  ),
                  _buildToolSelector(),
                  _buildToolPanel(editor),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(EditorProvider editor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A0033).withValues(alpha: 0.9),
            const Color(0xFF1A0033).withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
                  icon: const Icon(Icons.close),
                  color: AppConstants.primaryOrange,
                  iconSize: 24,
                  onPressed: () => _showExitDialog(),
                ),
              ),
              const SizedBox(width: 12),
              // Pill-shaped undo/redo container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppConstants.primaryOrange.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.undo,
                            color: editor.canUndo
                                ? AppConstants.primaryOrange
                                : AppConstants.ghostWhite.withValues(alpha: 0.3),
                          ),
                          onPressed: editor.canUndo ? () => editor.undo() : null,
                          tooltip: 'Undo',
                        ),
                        Container(
                          width: 1.5,
                          height: 24,
                          color: AppConstants.ghostWhite.withValues(alpha: 0.2),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.redo,
                            color: editor.canRedo
                                ? AppConstants.primaryOrange
                                : AppConstants.ghostWhite.withValues(alpha: 0.3),
                          ),
                          onPressed: editor.canRedo ? () => editor.redo() : null,
                          tooltip: 'Redo',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryOrange,
                      AppConstants.brightOrange,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryOrange.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.share),
                  color: Colors.white,
                  iconSize: 22,
                  onPressed: () => _shareImage(editor),
                  tooltip: 'Share',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryOrange,
                      AppConstants.brightOrange,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryOrange.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.save_alt),
                  color: Colors.white,
                  iconSize: 22,
                  onPressed: () => _saveImage(editor),
                  tooltip: 'Save',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(Uint8List imageData) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PhotoView(
          imageProvider: MemoryImage(imageData),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          initialScale: PhotoViewComputedScale.contained,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(EditorProvider editor) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppConstants.primaryOrange,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              editor.statusMessage,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppConstants.ghostWhite,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            icon: Icons.filter_vintage,
            label: 'Filters',
            tool: EditorTool.filters,
          ),
          _buildToolButton(
            icon: Icons.auto_awesome,
            label: 'Creative',
            tool: EditorTool.creativePrompts,
          ),
          _buildToolButton(
            icon: Icons.tune,
            label: 'Adjust',
            tool: EditorTool.adjust,
          ),
          _buildToolButton(
            icon: Icons.landscape,
            label: 'Background',
            tool: EditorTool.background,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required EditorTool tool,
  }) {
    final isSelected = _selectedTool == tool;
    final gradient = _getToolGradient(tool);

    return GestureDetector(
      onTap: () => setState(() => _selectedTool = tool),
      child: AnimatedContainer(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
        transform: isSelected
            ? Matrix4.translationValues(0, -10, 0)
            : Matrix4.identity(),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isSelected ? gradient : null,
                color: isSelected ? null : AppConstants.primaryPurple.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppConstants.primaryOrange.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isSelected
                    ? AppConstants.primaryOrange
                    : AppConstants.ghostWhite.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getToolGradient(EditorTool tool) {
    switch (tool) {
      case EditorTool.filters:
        return const LinearGradient(
          colors: [AppConstants.mediumPurple, AppConstants.lightPurple],
        );
      case EditorTool.creativePrompts:
        return const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        );
      case EditorTool.adjust:
        return const LinearGradient(
          colors: [AppConstants.primaryOrange, AppConstants.brightOrange],
        );
      case EditorTool.background:
        return const LinearGradient(
          colors: [AppConstants.witchGreen, AppConstants.zombieGreen],
        );
    }
  }

  Widget _buildToolPanel(EditorProvider editor) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A0033).withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryOrange.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _buildToolContent(editor),
    );
  }

  Widget _buildToolContent(EditorProvider editor) {
    switch (_selectedTool) {
      case EditorTool.filters:
        return _buildFiltersPanel(editor);
      case EditorTool.creativePrompts:
        return _buildCreativePromptsPanel(editor);
      case EditorTool.adjust:
        return _buildAdjustPanel(editor);
      case EditorTool.background:
        return _buildBackgroundPanel(editor);
    }
  }

  Widget _buildFiltersPanel(EditorProvider editor) {
    return FilterSelector(
      onFilterSelected: (filter) => editor.applyFilter(filter),
      selectedFilter: editor.appliedFilter,
    );
  }

  Widget _buildCreativePromptsPanel(EditorProvider editor) {
    return PromptSelector(
      onPromptSelected: (prompt) => editor.applyHalloweenPrompt(prompt),
      selectedPrompt: null,
    );
  }

  Widget _buildAdjustPanel(EditorProvider editor) {
    final hasAdjustments = editor.brightness != 0 ||
        editor.contrast != 0 ||
        editor.saturation != 0 ||
        editor.spookiness != 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Quick presets
          _buildQuickPresets(editor),
          const SizedBox(height: 16),
          Divider(color: AppConstants.ghostWhite.withValues(alpha: 0.2)),
          const SizedBox(height: 8),

          // Sliders
          _buildSlider(
            label: 'Brightness',
            value: editor.brightness,
            onChanged: (v) => editor.updateBrightness(v),
          ),
          _buildSlider(
            label: 'Contrast',
            value: editor.contrast,
            onChanged: (v) => editor.updateContrast(v),
          ),
          _buildSlider(
            label: 'Saturation',
            value: editor.saturation,
            onChanged: (v) => editor.updateSaturation(v),
          ),
          _buildSlider(
            label: 'Spookiness',
            value: editor.spookiness,
            onChanged: (v) => editor.updateSpookiness(v),
          ),

          // Apply/Reset buttons
          if (hasAdjustments) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => editor.resetAdjustments(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppConstants.bloodRed.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.poppins(
                        color: AppConstants.bloodRed,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => editor.applyAdjustments(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryOrange,
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickPresets(EditorProvider editor) {
    final presets = [
      FilterPreset.orangeGlow,
      FilterPreset.purpleMystic,
      FilterPreset.vintage,
      FilterPreset.grayscale,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppConstants.ghostWhite.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: presets.map((preset) {
            return GestureDetector(
              onTap: () => editor.applyLocalPreset(preset),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryPurple.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppConstants.primaryOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        preset.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset.name,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: AppConstants.ghostWhite.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppConstants.ghostWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: value,
          min: -100,
          max: 100,
          divisions: 200,
          label: value.toStringAsFixed(0),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBackgroundPanel(EditorProvider editor) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      children: HalloweenBackground.values.map((bg) {
        return _buildBackgroundOption(bg, () => editor.replaceBackground(bg));
      }).toList(),
    );
  }

  Widget _buildBackgroundOption(
    HalloweenBackground background,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppConstants.primaryPurple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.primaryOrange.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            _getBackgroundName(background),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppConstants.ghostWhite,
            ),
          ),
        ),
      ),
    );
  }

  String _getBackgroundName(HalloweenBackground bg) {
    switch (bg) {
      case HalloweenBackground.hauntedHouse:
        return 'Haunted\nHouse';
      case HalloweenBackground.cemetery:
        return 'Cemetery';
      case HalloweenBackground.darkForest:
        return 'Dark\nForest';
      case HalloweenBackground.fullMoon:
        return 'Full\nMoon';
      case HalloweenBackground.abandonedMansion:
        return 'Abandoned\nMansion';
      case HalloweenBackground.pumpkinPatch:
        return 'Pumpkin\nPatch';
    }
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 80,
            color: AppConstants.ghostWhite.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No image loaded',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppConstants.ghostWhite.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(EditorProvider editor) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Preparing image...',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            backgroundColor: AppConstants.primaryPurple,
            duration: const Duration(seconds: 10),
          ),
        );
      }

      // Get final composited image
      final imageData = await editor.getCompositedImage(_canvasSize);

      final result = await ImageGallerySaver.saveImage(
        imageData,
        quality: AppConstants.jpegQuality,
        name: 'SpookEdit_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        // Clear the loading message
        ScaffoldMessenger.of(context).clearSnackBars();

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image saved to gallery!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppConstants.witchGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save image: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.bloodRed,
          ),
        );
      }
    }
  }

  Future<void> _shareImage(EditorProvider editor) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Preparing image...',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
            backgroundColor: AppConstants.primaryPurple,
            duration: const Duration(seconds: 10),
          ),
        );
      }

      // Get final composited image
      final imageData = await editor.getCompositedImage(_canvasSize);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      await Share.shareXFiles(
        [
          XFile.fromData(
            imageData,
            name: 'SpookEdit_${DateTime.now().millisecondsSinceEpoch}.jpg',
            mimeType: 'image/jpeg',
          ),
        ],
        text: 'Created with SpookEdit - Halloween Photo Editor',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to share image: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppConstants.bloodRed,
          ),
        );
      }
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit Editor?',
          style: GoogleFonts.creepster(
            color: AppConstants.primaryOrange,
          ),
        ),
        content: Text(
          'Any unsaved changes will be lost.',
          style: GoogleFonts.poppins(
            color: AppConstants.ghostWhite,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppConstants.ghostWhite,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Exit',
              style: GoogleFonts.poppins(
                color: AppConstants.bloodRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Editor tool types
enum EditorTool {
  filters,
  creativePrompts,
  adjust,
  background,
}
