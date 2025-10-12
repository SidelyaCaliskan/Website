import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import '../models/sticker_model.dart';

/// Service for compositing stickers onto images
class ImageCompositionService {
  /// Composite stickers onto base image
  /// Returns the final image as Uint8List in JPEG format
  static Future<Uint8List> composeImageWithStickers({
    required Uint8List baseImageBytes,
    required List<StickerModel> stickers,
    required Size canvasSize,
  }) async {
    if (stickers.isEmpty) {
      // No stickers, return original image
      return baseImageBytes;
    }

    // Decode base image
    final baseImage = img.decodeImage(baseImageBytes);
    if (baseImage == null) {
      throw Exception('Failed to decode base image');
    }

    // Create a copy to work with
    final compositeImage = img.Image.from(baseImage);

    // Calculate scale factor between canvas and actual image
    final scaleX = compositeImage.width / canvasSize.width;
    final scaleY = compositeImage.height / canvasSize.height;

    // Render each sticker
    for (final sticker in stickers) {
      try {
        // Get sticker image
        final stickerImage = await _getStickerImage(sticker);
        if (stickerImage == null) continue;

        // Apply transformations and composite
        await _compositeSticker(
          baseImage: compositeImage,
          stickerImage: stickerImage,
          sticker: sticker,
          scaleX: scaleX,
          scaleY: scaleY,
        );
      } catch (e) {
        debugPrint('Error compositing sticker ${sticker.id}: $e');
        // Continue with other stickers
      }
    }

    // Encode to JPEG
    final encodedImage = img.encodeJpg(compositeImage, quality: 95);
    return Uint8List.fromList(encodedImage);
  }

  /// Get sticker image (either from emoji or asset)
  static Future<img.Image?> _getStickerImage(StickerModel sticker) async {
    if (sticker.isEmoji) {
      // Convert emoji to image
      return await _emojiToImage(sticker.emoji!);
    } else if (sticker.assetPath.isNotEmpty) {
      // Load from asset
      try {
        final byteData = await rootBundle.load(sticker.assetPath);
        final bytes = byteData.buffer.asUint8List();
        return img.decodeImage(bytes);
      } catch (e) {
        // If asset not found, try emoji fallback
        if (sticker.emoji != null) {
          return await _emojiToImage(sticker.emoji!);
        }
        return null;
      }
    }
    return null;
  }

  /// Convert emoji text to image
  static Future<img.Image?> _emojiToImage(String emoji) async {
    try {
      // Create a text painter for the emoji
      final textPainter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: const TextStyle(
            fontSize: 100,
            fontFamily: 'NotoColorEmoji', // Default emoji font
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Create a canvas to draw the emoji
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw white background for better visibility
      final paint = Paint()..color = Colors.transparent;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, textPainter.width, textPainter.height),
        paint,
      );

      // Draw the emoji
      textPainter.paint(canvas, Offset.zero);

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        textPainter.width.ceil(),
        textPainter.height.ceil(),
      );

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      return img.decodeImage(bytes);
    } catch (e) {
      debugPrint('Error converting emoji to image: $e');
      return null;
    }
  }

  /// Composite a sticker onto the base image with transformations
  static Future<void> _compositeSticker({
    required img.Image baseImage,
    required img.Image stickerImage,
    required StickerModel sticker,
    required double scaleX,
    required double scaleY,
  }) async {
    // Apply sticker scale
    final targetWidth = (100 * sticker.scale * scaleX).round();
    final targetHeight = (100 * sticker.scale * scaleY).round();

    if (targetWidth <= 0 || targetHeight <= 0) return;

    // Resize sticker
    final resizedSticker = img.copyResize(
      stickerImage,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.average,
    );

    // Apply rotation if needed
    img.Image rotatedSticker = resizedSticker;
    if (sticker.rotation != 0) {
      final degrees = (sticker.rotation * 180 / 3.14159265359).round();
      rotatedSticker = img.copyRotate(
        resizedSticker,
        angle: degrees,
      );
    }

    // Apply flip if needed
    if (sticker.isFlipped) {
      rotatedSticker = img.flipHorizontal(rotatedSticker);
    }

    // Calculate position on the actual image
    final x = (sticker.position.dx * scaleX).round();
    final y = (sticker.position.dy * scaleY).round();

    // Composite the sticker onto the base image
    img.compositeImage(
      baseImage,
      rotatedSticker,
      dstX: x,
      dstY: y,
      blend: img.BlendMode.alpha,
    );
  }

  /// Alternative method using Flutter's Canvas for higher quality
  /// This is more accurate for emoji rendering but slower
  static Future<Uint8List> composeImageWithStickersCanvas({
    required Uint8List baseImageBytes,
    required List<StickerModel> stickers,
    required Size canvasSize,
  }) async {
    if (stickers.isEmpty) {
      return baseImageBytes;
    }

    // Decode base image to get dimensions
    final baseImage = img.decodeImage(baseImageBytes);
    if (baseImage == null) {
      throw Exception('Failed to decode base image');
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw base image
    final codec = await ui.instantiateImageCodec(baseImageBytes);
    final frame = await codec.getNextFrame();
    final baseUiImage = frame.image;

    canvas.drawImage(baseUiImage, Offset.zero, Paint());

    // Calculate scale factors
    final scaleX = baseImage.width / canvasSize.width;
    final scaleY = baseImage.height / canvasSize.height;

    // Draw each sticker
    for (final sticker in stickers) {
      await _drawStickerOnCanvas(
        canvas: canvas,
        sticker: sticker,
        scaleX: scaleX,
        scaleY: scaleY,
      );
    }

    // Convert canvas to image
    final picture = recorder.endRecording();
    final finalImage = await picture.toImage(
      baseImage.width,
      baseImage.height,
    );

    final byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw Exception('Failed to convert canvas to image');
    }

    // Convert PNG to JPEG for smaller file size
    final pngBytes = byteData.buffer.asUint8List();
    final decodedImage = img.decodePng(pngBytes);
    if (decodedImage == null) {
      return pngBytes; // Return PNG if conversion fails
    }

    final jpegBytes = img.encodeJpg(decodedImage, quality: 95);
    return Uint8List.fromList(jpegBytes);
  }

  /// Draw a sticker on Flutter canvas
  static Future<void> _drawStickerOnCanvas({
    required Canvas canvas,
    required StickerModel sticker,
    required double scaleX,
    required double scaleY,
  }) async {
    // Calculate actual position and size
    final x = sticker.position.dx * scaleX;
    final y = sticker.position.dy * scaleY;
    final size = 100.0 * sticker.scale;
    final scaledSize = size * scaleX;

    canvas.save();

    // Move to sticker position
    canvas.translate(x + scaledSize / 2, y + scaledSize / 2);

    // Apply rotation
    canvas.rotate(sticker.rotation);

    // Apply flip
    if (sticker.isFlipped) {
      canvas.scale(-1.0, 1.0);
    }

    // Draw sticker (emoji)
    if (sticker.isEmoji) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: sticker.emoji!,
          style: TextStyle(
            fontSize: scaledSize * 0.72, // Adjust size to match visual size
            fontFamily: 'NotoColorEmoji',
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
    } else if (sticker.assetPath.isNotEmpty) {
      try {
        final byteData = await rootBundle.load(sticker.assetPath);
        final bytes = byteData.buffer.asUint8List();
        final codec = await ui.instantiateImageCodec(
          bytes,
          targetWidth: scaledSize.round(),
        );
        final frame = await codec.getNextFrame();
        final image = frame.image;

        canvas.drawImage(
          image,
          Offset(-scaledSize / 2, -scaledSize / 2),
          Paint(),
        );
      } catch (e) {
        debugPrint('Error loading sticker asset: $e');
      }
    }

    canvas.restore();
  }
}
