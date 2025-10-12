import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/nano_banana_service.dart';
import '../../utils/app_constants.dart';

/// Widget for selecting Halloween filters
class FilterSelector extends StatelessWidget {
  final Function(HalloweenFilter) onFilterSelected;
  final HalloweenFilter? selectedFilter;

  const FilterSelector({
    super.key,
    required this.onFilterSelected,
    this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Halloween Filters',
            style: GoogleFonts.creepster(
              fontSize: 18,
              color: AppConstants.primaryOrange,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: HalloweenFilter.values.length,
            itemBuilder: (context, index) {
              final filter = HalloweenFilter.values[index];
              final isSelected = selectedFilter == filter;

              return _buildFilterOption(
                filter: filter,
                isSelected: isSelected,
                onTap: () => onFilterSelected(filter),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption({
    required HalloweenFilter filter,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isPremium = _isPremiumFilter(filter);
    final gradient = _getFilterGradient(filter);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130,
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryOrange
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryOrange.withValues(alpha: 0.6),
                    blurRadius: 20,
                    spreadRadius: 3,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Shimmer effect on hover
              if (isSelected)
                Positioned.fill(
                  child: Shimmer.fromColors(
                    baseColor: Colors.transparent,
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

              // Content
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getFilterIcon(filter),
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _getFilterName(filter),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Premium badge
              if (isPremium)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PRO',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Glass-morphism overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Tap ripple effect
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(18),
                    splashColor: AppConstants.primaryOrange.withValues(alpha: 0.3),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPremiumFilter(HalloweenFilter filter) {
    // Mark some filters as premium (example)
    return filter == HalloweenFilter.bloodMoon ||
        filter == HalloweenFilter.witchHour ||
        filter == HalloweenFilter.haunted;
  }

  String _getFilterName(HalloweenFilter filter) {
    switch (filter) {
      case HalloweenFilter.spookyNight:
        return 'Spooky\nNight';
      case HalloweenFilter.vampire:
        return 'Vampire';
      case HalloweenFilter.zombie:
        return 'Zombie';
      case HalloweenFilter.ghost:
        return 'Ghost';
      case HalloweenFilter.pumpkinGlow:
        return 'Pumpkin\nGlow';
      case HalloweenFilter.haunted:
        return 'Haunted';
      case HalloweenFilter.bloodMoon:
        return 'Blood\nMoon';
      case HalloweenFilter.witchHour:
        return 'Witch\nHour';
    }
  }

  IconData _getFilterIcon(HalloweenFilter filter) {
    switch (filter) {
      case HalloweenFilter.spookyNight:
        return Icons.nights_stay;
      case HalloweenFilter.vampire:
        return Icons.face;
      case HalloweenFilter.zombie:
        return Icons.person;
      case HalloweenFilter.ghost:
        return Icons.blur_on;
      case HalloweenFilter.pumpkinGlow:
        return Icons.wb_sunny;
      case HalloweenFilter.haunted:
        return Icons.photo_camera;
      case HalloweenFilter.bloodMoon:
        return Icons.brightness_2;
      case HalloweenFilter.witchHour:
        return Icons.auto_awesome;
    }
  }

  LinearGradient _getFilterGradient(HalloweenFilter filter) {
    switch (filter) {
      case HalloweenFilter.spookyNight:
        return const LinearGradient(
          colors: [Color(0xFF1a0033), Color(0xFF2E0854)],
        );
      case HalloweenFilter.vampire:
        return const LinearGradient(
          colors: [Color(0xFF1A0000), Color(0xFF8B0000)],
        );
      case HalloweenFilter.zombie:
        return const LinearGradient(
          colors: [Color(0xFF004D00), Color(0xFF228B22)],
        );
      case HalloweenFilter.ghost:
        return const LinearGradient(
          colors: [Color(0xFF4A4A4A), Color(0xFFB0B0B0)],
        );
      case HalloweenFilter.pumpkinGlow:
        return const LinearGradient(
          colors: [Color(0xFFFF4500), Color(0xFFFFB347)],
        );
      case HalloweenFilter.haunted:
        return const LinearGradient(
          colors: [Color(0xFF3D2817), Color(0xFF6B4423)],
        );
      case HalloweenFilter.bloodMoon:
        return const LinearGradient(
          colors: [Color(0xFF4A0000), Color(0xFFDC143C)],
        );
      case HalloweenFilter.witchHour:
        return const LinearGradient(
          colors: [Color(0xFF6A0DAD), Color(0xFF228B22)],
        );
    }
  }
}
