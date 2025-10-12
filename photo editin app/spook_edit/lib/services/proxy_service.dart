import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nanobana_models.dart';

/// Service for interacting with the proxy server that secures the API key
class ProxyService {
  // Proxy server URL
  // Local: 'http://localhost:3001'
  // Production: Deploy to Vercel and update this URL
  static const String baseUrl = 'http://localhost:3001';

  /// Generate an image from a text prompt via proxy
  Future<NanoBananaResponse> generateImage({
    required String prompt,
    int numImages = 1,
    String outputFormat = 'jpeg',
    String aspectRatio = '1:1',
    Function(Map<String, dynamic>)? onQueueUpdate,
  }) async {
    try {
      final request = {
        'prompt': prompt,
        'num_images': numImages,
        'output_format': outputFormat,
        'aspect_ratio': aspectRatio,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/nanobana'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return NanoBananaResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Proxy Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate image via proxy: $e');
    }
  }

  /// Check proxy server health
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========== Halloween-specific helper methods ==========

  /// Apply Halloween filter to an image using AI
  Future<NanoBananaResponse> applyHalloweenFilter({
    required HalloweenFilter filter,
    int numImages = 1,
    String aspectRatio = '1:1',
  }) async {
    final prompt = _getFilterPrompt(filter);
    return await generateImage(
      prompt: prompt,
      numImages: numImages,
      aspectRatio: aspectRatio,
    );
  }

  /// Generate Halloween-themed background
  Future<NanoBananaResponse> generateHalloweenBackground({
    required HalloweenBackground background,
    int numImages = 1,
    String aspectRatio = '16:9',
  }) async {
    final prompt = _getBackgroundPrompt(background);
    return await generateImage(
      prompt: prompt,
      numImages: numImages,
      aspectRatio: aspectRatio,
    );
  }

  /// Generate custom Halloween image with specific prompt
  Future<NanoBananaResponse> generateCustomHalloweenImage({
    required String basePrompt,
    HalloweenStyle style = HalloweenStyle.spooky,
    int numImages = 1,
    String aspectRatio = '1:1',
  }) async {
    final enhancedPrompt = '$basePrompt. ${_getStyleModifier(style)}';
    return await generateImage(
      prompt: enhancedPrompt,
      numImages: numImages,
      aspectRatio: aspectRatio,
    );
  }

  /// Get filter prompt based on Halloween filter type
  String _getFilterPrompt(HalloweenFilter filter) {
    switch (filter) {
      case HalloweenFilter.spookyNight:
        return 'A spooky night scene with dark blue and purple tones, increased contrast, eerie moonlight, haunting and mysterious atmosphere';
      case HalloweenFilter.vampire:
        return 'A vampire-themed scene with pale skin tones, red glowing eyes, enhanced shadows, and menacing vampire atmosphere, gothic style';
      case HalloweenFilter.zombie:
        return 'A zombie-themed horror scene with green tint, decay texture, torn clothing, undead appearance, gritty horror atmosphere';
      case HalloweenFilter.ghost:
        return 'A ghostly ethereal scene with transparency effects, blurred edges, floating appearance, white/blue ethereal glow, supernatural atmosphere';
      case HalloweenFilter.pumpkinGlow:
        return 'A warm Halloween scene with pumpkin glow, orange tones, warm lighting, cozy autumn atmosphere, pumpkin-inspired color grading';
      case HalloweenFilter.haunted:
        return 'A haunted vintage photograph with sepia tone, grain, scratches, aged paper texture, eerie faded quality like an old cursed photo';
      case HalloweenFilter.bloodMoon:
        return 'A blood moon atmosphere with deep red filter, ominous crimson lighting, dark shadows, sinister red moon vibes';
      case HalloweenFilter.witchHour:
        return 'A witch hour scene with purple and green split-toning, mystical fog, magical aura, enchanted forest vibes, supernatural purple-green scheme';
    }
  }

  /// Get background prompt for Halloween backgrounds
  String _getBackgroundPrompt(HalloweenBackground background) {
    switch (background) {
      case HalloweenBackground.hauntedHouse:
        return 'A spooky haunted mansion at night, dark gothic architecture, broken windows, overgrown vines, eerie atmosphere, full moon';
      case HalloweenBackground.cemetery:
        return 'A foggy cemetery at dusk, old tombstones, dead trees, misty atmosphere, iron gates, eerie moonlight filtering through fog';
      case HalloweenBackground.darkForest:
        return 'A dark mysterious forest, twisted trees, fog, dim moonlight filtering through branches, ominous shadows, spooky woodland';
      case HalloweenBackground.fullMoon:
        return 'A dramatic full moon night sky, large glowing moon, stars, dark clouds, bats flying in silhouette, mysterious night atmosphere';
      case HalloweenBackground.abandonedMansion:
        return 'An abandoned Victorian mansion interior, cobwebs, dusty furniture, peeling wallpaper, chandelier, gothic architecture, haunted atmosphere';
      case HalloweenBackground.pumpkinPatch:
        return 'A twilight pumpkin patch, orange pumpkins scattered around, autumn hay bales, scarecrow, corn stalks, purple-orange sunset sky';
    }
  }

  /// Get style modifier for custom prompts
  String _getStyleModifier(HalloweenStyle style) {
    switch (style) {
      case HalloweenStyle.spooky:
        return 'Spooky, eerie, haunting atmosphere with dark shadows and mysterious vibes';
      case HalloweenStyle.cute:
        return 'Cute and friendly Halloween style, cartoonish, playful, family-friendly';
      case HalloweenStyle.horror:
        return 'Horror style, terrifying, dark, disturbing, nightmare-inducing, scary';
      case HalloweenStyle.vintage:
        return 'Vintage Halloween style, retro, classic, nostalgic, old-fashioned aesthetic';
      case HalloweenStyle.gothic:
        return 'Gothic style, Victorian architecture, dark romantic, elegant and mysterious';
    }
  }
}

/// Halloween filter options
enum HalloweenFilter {
  spookyNight,
  vampire,
  zombie,
  ghost,
  pumpkinGlow,
  haunted,
  bloodMoon,
  witchHour,
}

/// Halloween background options
enum HalloweenBackground {
  hauntedHouse,
  cemetery,
  darkForest,
  fullMoon,
  abandonedMansion,
  pumpkinPatch,
}

/// Halloween style modifiers
enum HalloweenStyle {
  spooky,
  cute,
  horror,
  vintage,
  gothic,
}
