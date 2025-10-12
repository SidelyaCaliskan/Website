import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_constants.dart';
import '../../widgets/animations/pulsing_glow.dart';

/// History Screen - View all past transformations
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Placeholder for saved transformations
  // In a real app, this would load from local storage or database
  final List<TransformationItem> _transformations = [];

  @override
  Widget build(BuildContext context) {
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
                child: _transformations.isEmpty
                    ? _buildEmptyState()
                    : _buildHistoryGrid(),
              ),
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
            icon: const Icon(Icons.arrow_back),
            color: AppConstants.primaryOrange,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              children: [
                PulsingGlow(
                  glowColor: AppConstants.primaryOrange,
                  child: Text(
                    'Your Transformations',
                    style: GoogleFonts.creepster(
                      fontSize: 28,
                      color: AppConstants.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  '${_transformations.length} spooky creations',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppConstants.ghostWhite.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.primaryOrange.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 80,
                color: AppConstants.primaryOrange.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Transformations Yet',
              style: GoogleFonts.creepster(
                fontSize: 28,
                color: AppConstants.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Start creating spooky transformations!\nThey will appear here once saved.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppConstants.ghostWhite.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppConstants.homeRoute);
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(
                  'Create First',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _transformations.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(_transformations[index]);
      },
    );
  }

  Widget _buildHistoryCard(TransformationItem item) {
    return GestureDetector(
      onTap: () {
        // Show full image or details
        _showTransformationDetails(item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.primaryPurple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppConstants.primaryOrange.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryOrange.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Placeholder image
              Container(
                color: AppConstants.primaryPurple.withOpacity(0.5),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: AppConstants.ghostWhite,
                  ),
                ),
              ),
              // Info overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.styleName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.date,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Menu button
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                    iconSize: 20,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _showOptionsMenu(item);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransformationDetails(TransformationItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A0033),
                Color(0xFF0D0015),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppConstants.primaryOrange.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.styleName,
                style: GoogleFonts.creepster(
                  fontSize: 24,
                  color: AppConstants.primaryOrange,
                ),
              ),
              const SizedBox(height: 16),
              // Image placeholder
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppConstants.primaryPurple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: AppConstants.ghostWhite,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.date,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppConstants.ghostWhite.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(TransformationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0033),
              Color(0xFF0D0015),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppConstants.ghostWhite.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: AppConstants.primaryOrange),
                title: Text(
                  'Share',
                  style: GoogleFonts.poppins(color: AppConstants.ghostWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Share logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: AppConstants.primaryOrange),
                title: Text(
                  'Re-download',
                  style: GoogleFonts.poppins(color: AppConstants.ghostWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Download logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppConstants.bloodRed),
                title: Text(
                  'Delete',
                  style: GoogleFonts.poppins(color: AppConstants.ghostWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(item);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(TransformationItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0033),
        title: Text(
          'Delete Transformation?',
          style: GoogleFonts.creepster(
            color: AppConstants.primaryOrange,
          ),
        ),
        content: Text(
          'This action cannot be undone.',
          style: GoogleFonts.poppins(
            color: AppConstants.ghostWhite,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppConstants.ghostWhite,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _transformations.remove(item);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.bloodRed,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Model for a saved transformation
class TransformationItem {
  final String id;
  final String styleName;
  final String date;
  final String? imagePath;

  TransformationItem({
    required this.id,
    required this.styleName,
    required this.date,
    this.imagePath,
  });
}
