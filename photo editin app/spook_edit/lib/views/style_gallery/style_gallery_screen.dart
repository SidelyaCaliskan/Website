import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/halloween_prompt.dart';
import '../../providers/editor_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/animations/pulsing_glow.dart';

/// Style Carousel Editor - Single-screen photo editing with horizontal style carousel
class StyleGalleryScreen extends StatefulWidget {
  const StyleGalleryScreen({super.key});

  @override
  State<StyleGalleryScreen> createState() => _StyleGalleryScreenState();
}

class _StyleGalleryScreenState extends State<StyleGalleryScreen> {
  String _selectedCategory = 'All';
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentStyleIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<HalloweenPrompt> get _filteredPrompts {
    var prompts = HalloweenPromptsRepository.getAllPrompts();

    // Filter by category
    if (_selectedCategory != 'All') {
      prompts = prompts.where((p) => p.category == _selectedCategory).toList();
    }

    return prompts;
  }

  List<String> get _categories {
    return ['All', ...HalloweenPromptsRepository.getCategories()];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final hasImage = provider.currentImage != null;

    if (!hasImage) {
      // Redirect back if no image
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            _buildHeader(context),

            // Large photo preview
            Expanded(
              flex: 3,
              child: _buildPhotoPreview(provider),
            ),

            // Category tabs
            _buildCategoryTabs(),

            // Horizontal carousel of styles
            _buildStyleCarousel(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppConstants.primaryOrange,
            iconSize: 28,
            onPressed: () => Navigator.of(context).pop(),
          ),
          PulsingGlow(
            glowColor: AppConstants.primaryOrange,
            child: Text(
              AppConstants.appName,
              style: GoogleFonts.creepster(
                fontSize: 24,
                color: AppConstants.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            color: AppConstants.primaryOrange,
            iconSize: 28,
            onPressed: () {
              // Save/Continue action
              final prompts = _filteredPrompts;
              if (prompts.isNotEmpty && _currentStyleIndex < prompts.length) {
                _applyStyle(prompts[_currentStyleIndex]);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(EditorProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.memory(
          provider.currentImage!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildStyleCarousel() {
    final prompts = _filteredPrompts;

    if (prompts.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No styles in this category',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppConstants.ghostWhite.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentStyleIndex = index;
          });
        },
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          final isCenter = index == _currentStyleIndex;

          return AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: isCenter ? 1.0 : 0.85,
            child: _buildCarouselStyleCard(prompt, isCenter),
          );
        },
      ),
    );
  }

  Widget _buildCarouselStyleCard(HalloweenPrompt prompt, bool isCenter) {
    return GestureDetector(
      onTap: () {
        if (isCenter) {
          _applyStyle(prompt);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryPurple.withValues(alpha: 0.6),
              AppConstants.primaryPurple.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCenter
                ? AppConstants.primaryOrange
                : AppConstants.primaryOrange.withValues(alpha: 0.3),
            width: isCenter ? 3 : 2,
          ),
          boxShadow: isCenter
              ? [
                  BoxShadow(
                    color: AppConstants.primaryOrange.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: HalloweenGradients.pumpkinGlow,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      prompt.title,
                      style: GoogleFonts.creepster(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        prompt.category,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppConstants.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCenter) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tap to apply',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppConstants.ghostWhite.withValues(alpha: 0.8),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: AppConstants.primaryPurple.withValues(alpha: 0.3),
              selectedColor: AppConstants.primaryOrange,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppConstants.primaryOrange
                      : AppConstants.primaryOrange.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _applyStyle(HalloweenPrompt prompt) {
    // Navigate to processing screen with selected style
    Navigator.of(context).pushNamed(
      AppConstants.processingRoute,
      arguments: prompt,
    );
  }
}
