import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Service for applying local image filters without API
class LocalImageFilters {
  /// Apply brightness adjustment (-100 to 100)
  static Future<Uint8List> applyBrightness(
    Uint8List imageBytes,
    double brightness,
  ) async {
    if (brightness == 0) return imageBytes;

    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Normalize brightness from -100..100 to -255..255
    final amount = (brightness * 2.55).round();

    final adjusted = img.adjustColor(
      image,
      brightness: amount.toDouble(),
    );

    final encoded = img.encodeJpg(adjusted, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply contrast adjustment (-100 to 100)
  static Future<Uint8List> applyContrast(
    Uint8List imageBytes,
    double contrast,
  ) async {
    if (contrast == 0) return imageBytes;

    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Normalize contrast from -100..100 to 0..2
    // 0 = no contrast, 1 = normal, 2 = max contrast
    final amount = 1 + (contrast / 100);

    final adjusted = img.adjustColor(
      image,
      contrast: amount,
    );

    final encoded = img.encodeJpg(adjusted, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply saturation adjustment (-100 to 100)
  static Future<Uint8List> applySaturation(
    Uint8List imageBytes,
    double saturation,
  ) async {
    if (saturation == 0) return imageBytes;

    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Normalize saturation from -100..100 to 0..2
    final amount = 1 + (saturation / 100);

    final adjusted = img.adjustColor(
      image,
      saturation: amount,
    );

    final encoded = img.encodeJpg(adjusted, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply all adjustments at once (more efficient)
  static Future<Uint8List> applyAllAdjustments(
    Uint8List imageBytes, {
    double brightness = 0,
    double contrast = 0,
    double saturation = 0,
  }) async {
    // If no adjustments, return original
    if (brightness == 0 && contrast == 0 && saturation == 0) {
      return imageBytes;
    }

    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Apply all adjustments in one pass
    final adjusted = img.adjustColor(
      image,
      brightness: (brightness * 2.55),
      contrast: 1 + (contrast / 100),
      saturation: 1 + (saturation / 100),
    );

    final encoded = img.encodeJpg(adjusted, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply Halloween "spookiness" filter
  /// Combines contrast, saturation, and color tinting
  static Future<Uint8List> applySpookiness(
    Uint8List imageBytes,
    double spookiness,
  ) async {
    if (spookiness == 0) return imageBytes;

    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Normalize spookiness from -100..100 to 0..1
    final amount = spookiness / 100;

    img.Image adjusted = image;

    if (amount > 0) {
      // Increase spookiness: darker, more contrast, purple/orange tint
      adjusted = img.adjustColor(
        adjusted,
        brightness: -amount * 30, // Darken
        contrast: 1 + (amount * 0.3), // More contrast
        saturation: 1 - (amount * 0.2), // Slightly desaturate
      );

      // Add purple/orange Halloween tint
      adjusted = _applyColorTint(
        adjusted,
        red: (amount * 20).round(),
        green: -(amount * 10).round(),
        blue: (amount * 30).round(),
      );
    } else {
      // Decrease spookiness: brighter, less contrast
      adjusted = img.adjustColor(
        adjusted,
        brightness: -amount * 40, // Brighten (negative of negative)
        contrast: 1 + (amount * 0.2), // Less contrast
        saturation: 1 - (amount * 0.1), // Slightly more saturated
      );
    }

    final encoded = img.encodeJpg(adjusted, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply grayscale filter
  static Future<Uint8List> applyGrayscale(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    final grayscale = img.grayscale(image);
    final encoded = img.encodeJpg(grayscale, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply sepia filter (vintage Halloween look)
  static Future<Uint8List> applySepia(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    final sepia = img.sepia(image);
    final encoded = img.encodeJpg(sepia, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply vignette effect (darker edges)
  static Future<Uint8List> applyVignette(
    Uint8List imageBytes,
    double amount,
  ) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    final vignette = img.vignette(image, amount: amount);
    final encoded = img.encodeJpg(vignette, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply color tint to image
  static img.Image _applyColorTint(
    img.Image image, {
    int red = 0,
    int green = 0,
    int blue = 0,
  }) {
    for (var pixel in image) {
      final r = (pixel.r + red).clamp(0, 255).toInt();
      final g = (pixel.g + green).clamp(0, 255).toInt();
      final b = (pixel.b + blue).clamp(0, 255).toInt();
      pixel
        ..r = r
        ..g = g
        ..b = b;
    }
    return image;
  }

  /// Apply Halloween orange glow effect
  static Future<Uint8List> applyOrangeGlow(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Increase reds and reduce blues for orange glow
    final glowing = _applyColorTint(
      image,
      red: 30,
      green: 10,
      blue: -20,
    );

    // Add slight brightness and contrast
    final adjusted = img.adjustColor(
      glowing,
      brightness: 10,
      contrast: 1.1,
    );

    final encoded = img.encodeJpg(adjusted, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply purple mystical effect
  static Future<Uint8List> applyPurpleMystic(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Increase blues and reds, reduce greens
    final mystical = _applyColorTint(
      image,
      red: 20,
      green: -30,
      blue: 40,
    );

    // Increase saturation and contrast
    final adjusted = img.adjustColor(
      mystical,
      saturation: 1.2,
      contrast: 1.15,
    );

    final encoded = img.encodeJpg(adjusted, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Apply vintage filter (sepia + vignette)
  static Future<Uint8List> applyVintage(Uint8List imageBytes) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image');

    // Apply sepia
    final sepia = img.sepia(image);

    // Add vignette
    final vintage = img.vignette(sepia, amount: 0.5);

    // Reduce contrast slightly
    final adjusted = img.adjustColor(
      vintage,
      contrast: 0.9,
    );

    final encoded = img.encodeJpg(adjusted, quality: 95);
    return Uint8List.fromList(encoded);
  }

  /// Quick preset filters
  static Future<Uint8List> applyPreset(
    Uint8List imageBytes,
    FilterPreset preset,
  ) async {
    switch (preset) {
      case FilterPreset.none:
        return imageBytes;

      case FilterPreset.orangeGlow:
        return await applyOrangeGlow(imageBytes);

      case FilterPreset.purpleMystic:
        return await applyPurpleMystic(imageBytes);

      case FilterPreset.vintage:
        return await applyVintage(imageBytes);

      case FilterPreset.grayscale:
        return await applyGrayscale(imageBytes);

      case FilterPreset.sepia:
        return await applySepia(imageBytes);

      case FilterPreset.highContrast:
        return await applyContrast(imageBytes, 50);

      case FilterPreset.vibrant:
        return await applySaturation(imageBytes, 40);
    }
  }
}

/// Preset filter options
enum FilterPreset {
  none,
  orangeGlow,
  purpleMystic,
  vintage,
  grayscale,
  sepia,
  highContrast,
  vibrant,
}

extension FilterPresetExtension on FilterPreset {
  String get name {
    switch (this) {
      case FilterPreset.none:
        return 'Original';
      case FilterPreset.orangeGlow:
        return 'Orange Glow';
      case FilterPreset.purpleMystic:
        return 'Purple Mystic';
      case FilterPreset.vintage:
        return 'Vintage';
      case FilterPreset.grayscale:
        return 'Grayscale';
      case FilterPreset.sepia:
        return 'Sepia';
      case FilterPreset.highContrast:
        return 'High Contrast';
      case FilterPreset.vibrant:
        return 'Vibrant';
    }
  }

  String get emoji {
    switch (this) {
      case FilterPreset.none:
        return '📷';
      case FilterPreset.orangeGlow:
        return '🎃';
      case FilterPreset.purpleMystic:
        return '🔮';
      case FilterPreset.vintage:
        return '📜';
      case FilterPreset.grayscale:
        return '⚫';
      case FilterPreset.sepia:
        return '🕰️';
      case FilterPreset.highContrast:
        return '⚡';
      case FilterPreset.vibrant:
        return '🌈';
    }
  }
}
