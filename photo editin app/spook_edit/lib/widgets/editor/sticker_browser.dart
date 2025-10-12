import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/sticker_service.dart';
import '../../utils/app_constants.dart';

/// Widget for browsing and selecting stickers
class StickerBrowser extends StatefulWidget {
  final Function(StickerItem) onStickerSelected;

  const StickerBrowser({
    super.key,
    required this.onStickerSelected,
  });

  @override
  State<StickerBrowser> createState() => _StickerBrowserState();
}

class _StickerBrowserState extends State<StickerBrowser>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<StickerCategory> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    try {
      await StickerService.instance.loadStickers();
      final categories = StickerService.instance.getCategories();

      if (mounted) {
        setState(() {
          _categories = categories;
          _tabController = TabController(
            length: _categories.length,
            vsync: this,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (!_isLoading && _error == null) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_error != null) {
      return _buildError();
    }

    if (_categories.isEmpty) {
      return _buildEmpty();
    }

    return Column(
      children: [
        _buildCategoryTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _categories.map((category) {
              return _buildStickerGrid(category);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppConstants.primaryPurple.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppConstants.primaryOrange,
        indicatorWeight: 3,
        labelColor: AppConstants.primaryOrange,
        unselectedLabelColor: AppConstants.ghostWhite.withOpacity(0.5),
        tabs: _categories.map((category) {
          return Tab(
            child: Row(
              children: [
                Text(
                  category.icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStickerGrid(StickerCategory category) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: category.stickers.length,
      itemBuilder: (context, index) {
        final sticker = category.stickers[index];
        return _buildStickerItem(sticker);
      },
    );
  }

  Widget _buildStickerItem(StickerItem sticker) {
    return GestureDetector(
      onTap: () => widget.onStickerSelected(sticker),
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.primaryPurple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.primaryOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: sticker.isEmoji
              ? Text(
                  sticker.emoji,
                  style: const TextStyle(fontSize: 36),
                )
              : Image.asset(
                  sticker.assetPath!,
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to emoji if asset not found
                    return Text(
                      sticker.emoji,
                      style: const TextStyle(fontSize: 36),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryOrange),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppConstants.bloodRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load stickers',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppConstants.ghostWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppConstants.ghostWhite.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox,
            size: 64,
            color: AppConstants.ghostWhite,
          ),
          const SizedBox(height: 16),
          Text(
            'No stickers available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppConstants.ghostWhite.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
