import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for loading and managing sticker assets
class StickerService {
  static StickerService? _instance;
  static StickerService get instance {
    _instance ??= StickerService._();
    return _instance!;
  }

  StickerService._();

  List<StickerCategory>? _categories;
  bool _isLoaded = false;

  /// Load sticker categories from JSON
  Future<void> loadStickers() async {
    if (_isLoaded) return;

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/sticker_categories.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      _categories = jsonData
          .map((categoryJson) => StickerCategory.fromJson(categoryJson))
          .toList();

      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load stickers: $e');
    }
  }

  /// Get all sticker categories
  List<StickerCategory> getCategories() {
    if (!_isLoaded) {
      throw Exception('Stickers not loaded. Call loadStickers() first.');
    }
    return _categories ?? [];
  }

  /// Get stickers by category ID
  List<StickerItem> getStickersByCategory(String categoryId) {
    if (!_isLoaded) {
      throw Exception('Stickers not loaded. Call loadStickers() first.');
    }

    final category = _categories?.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => StickerCategory(
        id: '',
        name: '',
        icon: '',
        stickers: [],
      ),
    );

    return category?.stickers ?? [];
  }

  /// Get all stickers (flattened from all categories)
  List<StickerItem> getAllStickers() {
    if (!_isLoaded) {
      throw Exception('Stickers not loaded. Call loadStickers() first.');
    }

    final List<StickerItem> allStickers = [];
    for (final category in _categories ?? []) {
      allStickers.addAll(category.stickers);
    }
    return allStickers;
  }

  /// Search stickers by name
  List<StickerItem> searchStickers(String query) {
    if (!_isLoaded) {
      throw Exception('Stickers not loaded. Call loadStickers() first.');
    }

    final lowerQuery = query.toLowerCase();
    final List<StickerItem> results = [];

    for (final category in _categories ?? []) {
      for (final sticker in category.stickers) {
        if (sticker.name.toLowerCase().contains(lowerQuery)) {
          results.add(sticker);
        }
      }
    }

    return results;
  }
}

/// Sticker category model
class StickerCategory {
  final String id;
  final String name;
  final String icon;
  final List<StickerItem> stickers;

  StickerCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.stickers,
  });

  factory StickerCategory.fromJson(Map<String, dynamic> json) {
    return StickerCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      stickers: (json['stickers'] as List<dynamic>)
          .map((stickerJson) => StickerItem.fromJson(stickerJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'stickers': stickers.map((s) => s.toJson()).toList(),
    };
  }
}

/// Individual sticker item
class StickerItem {
  final String id;
  final String name;
  final String emoji;
  final String? assetPath;

  StickerItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.assetPath,
  });

  factory StickerItem.fromJson(Map<String, dynamic> json) {
    return StickerItem(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      assetPath: json['assetPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      if (assetPath != null) 'assetPath': assetPath,
    };
  }

  /// Check if this sticker uses emoji or asset
  bool get isEmoji => assetPath == null || assetPath!.isEmpty;
}
