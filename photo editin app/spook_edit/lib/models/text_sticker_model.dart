import 'package:flutter/material.dart';

/// Model for text stickers with custom styling
class TextStickerModel {
  final String id;
  final String text;
  final String fontFamily;
  final double fontSize;
  final Color textColor;
  final FontWeight fontWeight;
  final TextAlign textAlign;

  // Text effects
  final bool hasShadow;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;

  final bool hasOutline;
  final Color outlineColor;
  final double outlineWidth;

  final bool hasGradient;
  final List<Color> gradientColors;

  // Transform properties
  Offset position;
  double scale;
  double rotation;

  TextStickerModel({
    required this.id,
    required this.text,
    this.fontFamily = 'Roboto',
    this.fontSize = 48.0,
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.bold,
    this.textAlign = TextAlign.center,
    this.hasShadow = true,
    this.shadowColor = Colors.black,
    this.shadowBlur = 4.0,
    this.shadowOffset = const Offset(2, 2),
    this.hasOutline = false,
    this.outlineColor = Colors.black,
    this.outlineWidth = 2.0,
    this.hasGradient = false,
    this.gradientColors = const [Colors.white, Colors.white],
    this.position = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  TextStickerModel copyWith({
    String? id,
    String? text,
    String? fontFamily,
    double? fontSize,
    Color? textColor,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    bool? hasShadow,
    Color? shadowColor,
    double? shadowBlur,
    Offset? shadowOffset,
    bool? hasOutline,
    Color? outlineColor,
    double? outlineWidth,
    bool? hasGradient,
    List<Color>? gradientColors,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return TextStickerModel(
      id: id ?? this.id,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
      hasShadow: hasShadow ?? this.hasShadow,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      hasOutline: hasOutline ?? this.hasOutline,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      hasGradient: hasGradient ?? this.hasGradient,
      gradientColors: gradientColors ?? this.gradientColors,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'textColor': textColor.value,
      'fontWeight': fontWeight.index,
      'textAlign': textAlign.index,
      'hasShadow': hasShadow,
      'shadowColor': shadowColor.value,
      'shadowBlur': shadowBlur,
      'shadowOffset': {'dx': shadowOffset.dx, 'dy': shadowOffset.dy},
      'hasOutline': hasOutline,
      'outlineColor': outlineColor.value,
      'outlineWidth': outlineWidth,
      'hasGradient': hasGradient,
      'gradientColors': gradientColors.map((c) => c.value).toList(),
      'position': {'dx': position.dx, 'dy': position.dy},
      'scale': scale,
      'rotation': rotation,
    };
  }

  factory TextStickerModel.fromJson(Map<String, dynamic> json) {
    return TextStickerModel(
      id: json['id'],
      text: json['text'],
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize'],
      textColor: Color(json['textColor']),
      fontWeight: FontWeight.values[json['fontWeight']],
      textAlign: TextAlign.values[json['textAlign']],
      hasShadow: json['hasShadow'],
      shadowColor: Color(json['shadowColor']),
      shadowBlur: json['shadowBlur'],
      shadowOffset: Offset(json['shadowOffset']['dx'], json['shadowOffset']['dy']),
      hasOutline: json['hasOutline'],
      outlineColor: Color(json['outlineColor']),
      outlineWidth: json['outlineWidth'],
      hasGradient: json['hasGradient'],
      gradientColors: (json['gradientColors'] as List).map((c) => Color(c)).toList(),
      position: Offset(json['position']['dx'], json['position']['dy']),
      scale: json['scale'],
      rotation: json['rotation'],
    );
  }
}

/// Predefined text styles for quick selection
enum TextStickerPreset {
  classic,
  neon,
  horror,
  halloween,
  spooky,
  cute,
  retro,
  modern,
}

extension TextStickerPresetExtension on TextStickerPreset {
  String get displayName {
    switch (this) {
      case TextStickerPreset.classic:
        return 'Classic';
      case TextStickerPreset.neon:
        return 'Neon';
      case TextStickerPreset.horror:
        return 'Horror';
      case TextStickerPreset.halloween:
        return 'Halloween';
      case TextStickerPreset.spooky:
        return 'Spooky';
      case TextStickerPreset.cute:
        return 'Cute';
      case TextStickerPreset.retro:
        return 'Retro';
      case TextStickerPreset.modern:
        return 'Modern';
    }
  }

  TextStickerModel createSticker(String id, String text) {
    switch (this) {
      case TextStickerPreset.classic:
        return TextStickerModel(
          id: id,
          text: text,
          fontFamily: 'Roboto',
          fontSize: 48,
          textColor: Colors.white,
          fontWeight: FontWeight.bold,
          hasShadow: true,
          shadowColor: Colors.black,
          shadowBlur: 4,
          hasOutline: true,
          outlineColor: Colors.black,
          outlineWidth: 2,
        );
      case TextStickerPreset.neon:
        return TextStickerModel(
          id: id,
          text: text,
          fontFamily: 'Roboto',
          fontSize: 52,
          textColor: const Color(0xFFFF00FF),
          fontWeight: FontWeight.w900,
          hasShadow: true,
          shadowColor: const Color(0xFFFF00FF),
          shadowBlur: 20,
          hasOutline: true,
          outlineColor: Colors.white,
          outlineWidth: 1,
        );
      case TextStickerPreset.horror:
        return TextStickerModel(
          id: id,
          text: text,
          fontFamily: 'Roboto',
          fontSize: 56,
          textColor: const Color(0xFF8B0000),
          fontWeight: FontWeight.w900,
          hasShadow: true,
          shadowColor: Colors.black,
          shadowBlur: 8,
          hasOutline: true,
          outlineColor: Colors.black,
          outlineWidth: 3,
        );
      case TextStickerPreset.halloween:
        return TextStickerModel(
          id: id,
          text: text,
          fontFamily: 'Roboto',
          fontSize: 50,
          textColor: const Color(0xFFFF6600),
          fontWeight: FontWeight.bold,
          hasShadow: true,
          shadowColor: Colors.black,
          shadowBlur: 6,
          hasOutline: true,
          outlineColor: Colors.purple,
          outlineWidth: 2,
        );
      case TextStickerPreset.spooky:
        return TextStickerModel(
          id: id,
          text: text,
          fontFamily: 'Roboto',
          fontSize: 48,
          textColor: const Color(0xFF9933FF),
          fontWeight: FontWeight.bold,
          hasShadow: true,
          shadowColor: Colors.black.withValues(alpha: 0.8),
          shadowBlur: 10,
          hasOutline: false,
        );
      case TextStickerPreset.cute:
        return TextStickerModel(
          id: id,
          text: text,
          fontFamily: 'Roboto',
          fontSize: 44,
          textColor: const Color(0xFFFFB6C1),
          fontWeight: FontWeight.w800,
          hasShadow: true,
          shadowColor: Colors.white,
          shadowBlur: 8,
          hasOutline: true,
          outlineColor: Colors.white,
          outlineWidth: 2,
        );
      case TextStickerPreset.retro:
        return TextStickerModel(
          id: id,
          text: text,
          fontFamily: 'Roboto',
          fontSize: 46,
          textColor: const Color(0xFFFFD700),
          fontWeight: FontWeight.bold,
          hasShadow: true,
          shadowColor: const Color(0xFF8B4513),
          shadowBlur: 4,
          shadowOffset: const Offset(3, 3),
          hasOutline: true,
          outlineColor: const Color(0xFF8B4513),
          outlineWidth: 2,
        );
      case TextStickerPreset.modern:
        return TextStickerModel(
          id: id,
          text: text,
          fontFamily: 'Roboto',
          fontSize: 50,
          textColor: Colors.black,
          fontWeight: FontWeight.w600,
          hasShadow: false,
          hasOutline: false,
        );
    }
  }

  Color get previewColor {
    switch (this) {
      case TextStickerPreset.classic:
        return Colors.white;
      case TextStickerPreset.neon:
        return const Color(0xFFFF00FF);
      case TextStickerPreset.horror:
        return const Color(0xFF8B0000);
      case TextStickerPreset.halloween:
        return const Color(0xFFFF6600);
      case TextStickerPreset.spooky:
        return const Color(0xFF9933FF);
      case TextStickerPreset.cute:
        return const Color(0xFFFFB6C1);
      case TextStickerPreset.retro:
        return const Color(0xFFFFD700);
      case TextStickerPreset.modern:
        return Colors.black;
    }
  }
}
