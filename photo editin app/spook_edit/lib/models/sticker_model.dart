import 'package:flutter/material.dart';

/// Model for stickers that can be placed on images
class StickerModel {
  final String id;
  final String assetPath; // For image assets
  final String? emoji; // For emoji-based stickers
  final StickerCategory category;
  Offset position;
  double scale;
  double rotation;
  bool isFlipped;

  StickerModel({
    required this.id,
    required this.assetPath,
    this.emoji,
    required this.category,
    this.position = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.isFlipped = false,
  });

  /// Check if this sticker uses emoji or asset
  bool get isEmoji => emoji != null && emoji!.isNotEmpty;

  StickerModel copyWith({
    String? id,
    String? assetPath,
    String? emoji,
    StickerCategory? category,
    Offset? position,
    double? scale,
    double? rotation,
    bool? isFlipped,
  }) {
    return StickerModel(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetPath': assetPath,
      if (emoji != null) 'emoji': emoji,
      'category': category.toString(),
      'position': {'dx': position.dx, 'dy': position.dy},
      'scale': scale,
      'rotation': rotation,
      'isFlipped': isFlipped,
    };
  }

  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      id: json['id'],
      assetPath: json['assetPath'],
      emoji: json['emoji'] as String?,
      category: StickerCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      position: Offset(json['position']['dx'], json['position']['dy']),
      scale: json['scale'],
      rotation: json['rotation'],
      isFlipped: json['isFlipped'],
    );
  }
}

/// Categories for organizing stickers
enum StickerCategory {
  creatures, // Ghosts, bats, spiders, witches
  pumpkins, // Carved faces, expressions
  textBubbles, // "BOO!", "TRICK OR TREAT"
  props, // Witch hats, vampire teeth, masks
  effects, // Blood drops, spider webs, fog
}

extension StickerCategoryExtension on StickerCategory {
  String get displayName {
    switch (this) {
      case StickerCategory.creatures:
        return 'Creatures';
      case StickerCategory.pumpkins:
        return 'Pumpkins';
      case StickerCategory.textBubbles:
        return 'Text Bubbles';
      case StickerCategory.props:
        return 'Props';
      case StickerCategory.effects:
        return 'Effects';
    }
  }

  IconData get icon {
    switch (this) {
      case StickerCategory.creatures:
        return Icons.pets;
      case StickerCategory.pumpkins:
        return Icons.emoji_nature;
      case StickerCategory.textBubbles:
        return Icons.chat_bubble;
      case StickerCategory.props:
        return Icons.construction;
      case StickerCategory.effects:
        return Icons.auto_awesome;
    }
  }
}
