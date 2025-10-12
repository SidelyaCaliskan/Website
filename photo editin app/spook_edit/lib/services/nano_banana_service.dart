import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/nanobana_models.dart';

/// Service for interacting with fal.ai's Nano Banana API via proxy server
/// Documentation: https://fal.ai/models/fal-ai/nano-banana
class NanoBananaService {
  // Use localhost for iOS Simulator/Android Emulator
  // For Android Emulator, use 10.0.2.2 instead of localhost
  static const String _proxyHost = 'localhost';
  static const String _proxyPort = '3001';
  static const String _baseUrl = 'http://$_proxyHost:$_proxyPort/api/nanobana';
  static const String _editUrl = 'http://$_proxyHost:$_proxyPort/api/nanobana/edit';
  static const String _storageUrl = 'http://$_proxyHost:$_proxyPort/api/storage/upload';

  final String apiKey;

  NanoBananaService({required this.apiKey});

  /// Headers for API requests (proxy handles auth)
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  /// Generate an image from a text prompt (blocking/subscribe method)
  /// This will wait for the result and return it directly
  Future<NanoBananaResponse> generateImage({
    required String prompt,
    int numImages = 1,
    OutputFormat outputFormat = OutputFormat.jpeg,
    AspectRatio aspectRatio = AspectRatio.square,
    Function(NanoBananaQueueStatus)? onQueueUpdate,
  }) async {
    try {
      final request = NanoBananaRequest(
        prompt: prompt,
        numImages: numImages,
        outputFormat: outputFormat.value,
        aspectRatio: aspectRatio.value,
      );

      // Submit the request
      final submission = await _submitRequest(request);

      // Poll for status until complete
      while (true) {
        await Future.delayed(const Duration(seconds: 1));

        final status = await getStatus(submission.requestId);

        // Call the callback if provided
        if (onQueueUpdate != null) {
          onQueueUpdate(status);
        }

        if (status.isCompleted) {
          return await getResult(submission.requestId);
        }

        if (status.hasError) {
          throw Exception('Request failed: ${status.logs?.join(', ')}');
        }
      }
    } catch (e) {
      throw Exception('Failed to generate image: $e');
    }
  }

  /// Edit an image using a text prompt (blocking/subscribe method)
  /// Converts image to base64 data URI instead of uploading
  Future<NanoBananaResponse> editImage({
    required Uint8List imageData,
    required String prompt,
    int numImages = 1,
    OutputFormat outputFormat = OutputFormat.jpeg,
    AspectRatio? aspectRatio,
    Function(NanoBananaQueueStatus)? onQueueUpdate,
  }) async {
    try {
      print('🎨 Starting edit image request with prompt: $prompt');

      // Convert image to base64 data URI
      final base64Image = base64Encode(imageData);
      final dataUri = 'data:image/jpeg;base64,$base64Image';
      print('🎨 Image size: ${imageData.length} bytes, base64 length: ${base64Image.length}');

      final request = NanoBananaEditRequest(
        prompt: prompt,
        imageUrls: [dataUri],
        numImages: numImages,
        outputFormat: outputFormat.value,
        aspectRatio: aspectRatio?.value,
      );

      // Submit the request to the edit endpoint
      print('🎨 Submitting edit request...');
      final submission = await _submitEditRequest(request);
      print('🎨 Request submitted with ID: ${submission.requestId}');

      // Poll for status until complete
      while (true) {
        await Future.delayed(const Duration(seconds: 1));

        final status = await getEditStatus(submission.requestId);
        print('🎨 Status: ${status.status}, Queue position: ${status.queuePosition}');

        // Call the callback if provided
        if (onQueueUpdate != null) {
          onQueueUpdate(status);
        }

        if (status.isCompleted) {
          print('🎨 Request completed! Getting result...');
          return await getEditResult(submission.requestId);
        }

        if (status.hasError) {
          print('❌ Request failed with error: ${status.logs?.join(', ')}');
          throw Exception('Request failed: ${status.logs?.join(', ')}');
        }
      }
    } catch (e) {
      print('❌ Edit image error: $e');
      throw Exception('Failed to edit image: $e');
    }
  }

  /// Submit a request to the queue (non-blocking)
  /// Returns a request ID that can be used to check status and get results
  Future<NanoBananaQueueSubmission> submitRequest({
    required String prompt,
    int numImages = 1,
    OutputFormat outputFormat = OutputFormat.jpeg,
    AspectRatio aspectRatio = AspectRatio.square,
    String? webhookUrl,
  }) async {
    final request = NanoBananaRequest(
      prompt: prompt,
      numImages: numImages,
      outputFormat: outputFormat.value,
      aspectRatio: aspectRatio.value,
    );

    return await _submitRequest(request, webhookUrl: webhookUrl);
  }

  /// Internal method to submit request
  Future<NanoBananaQueueSubmission> _submitRequest(
    NanoBananaRequest request, {
    String? webhookUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        'input': request.toJson(),
      };

      if (webhookUrl != null) {
        body['webhook_url'] = webhookUrl;
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return NanoBananaQueueSubmission.fromJson(jsonResponse);
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit request: $e');
    }
  }

  /// Get the status of a queued request
  Future<NanoBananaQueueStatus> getStatus(String requestId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/requests/$requestId/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return NanoBananaQueueStatus.fromJson(jsonResponse);
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get status: $e');
    }
  }

  /// Get the result of a completed request
  Future<NanoBananaResponse> getResult(String requestId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/requests/$requestId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return NanoBananaResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get result: $e');
    }
  }

  /// Internal method to submit edit request
  Future<NanoBananaQueueSubmission> _submitEditRequest(
    NanoBananaEditRequest request, {
    String? webhookUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        ...request.toJson(),
      };

      if (webhookUrl != null) {
        body['webhook_url'] = webhookUrl;
      }

      final response = await http.post(
        Uri.parse(_editUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return NanoBananaQueueSubmission.fromJson(jsonResponse);
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit edit request: $e');
    }
  }

  /// Get the status of a queued edit request
  Future<NanoBananaQueueStatus> getEditStatus(String requestId) async {
    try {
      final response = await http.get(
        Uri.parse('$_editUrl/requests/$requestId/status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return NanoBananaQueueStatus.fromJson(jsonResponse);
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get edit status: $e');
    }
  }

  /// Get the result of a completed edit request
  Future<NanoBananaResponse> getEditResult(String requestId) async {
    try {
      final response = await http.get(
        Uri.parse('$_editUrl/requests/$requestId'),
        headers: _headers,
      );

      print('🔍 Edit result response status: ${response.statusCode}');
      print('🔍 Edit result response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('🔍 Parsed JSON response: $jsonResponse');

        final result = NanoBananaResponse.fromJson(jsonResponse);
        print('🔍 Created response with ${result.images.length} images');
        if (result.images.isNotEmpty) {
          print('🔍 First image URL: ${result.images.first.url}');
        }

        return result;
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting edit result: $e');
      throw Exception('Failed to get edit result: $e');
    }
  }

  /// Upload a file to fal.ai storage via proxy
  /// Returns the URL of the uploaded file
  Future<String> uploadFile(Uint8List fileData, String fileName) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_storageUrl));
      // Proxy handles auth, no need to send API key

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileData,
        filename: fileName,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['url'] as String;
      } else {
        throw Exception(
            'Upload Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Download an image from URL
  Future<Uint8List> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
            'Download Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to download image: $e');
    }
  }

  // ========== Halloween-specific helper methods ==========

  /// Apply Halloween filter to an image using AI
  Future<NanoBananaResponse> applyHalloweenFilter({
    required Uint8List imageData,
    required HalloweenFilter filter,
    int numImages = 1,
    AspectRatio? aspectRatio,
    Function(NanoBananaQueueStatus)? onQueueUpdate,
  }) async {
    final prompt = _getFilterPrompt(filter);
    return await editImage(
      imageData: imageData,
      prompt: prompt,
      numImages: numImages,
      aspectRatio: aspectRatio,
      onQueueUpdate: onQueueUpdate,
    );
  }

  /// Generate Halloween-themed background
  Future<NanoBananaResponse> generateHalloweenBackground({
    required HalloweenBackground background,
    int numImages = 1,
    AspectRatio aspectRatio = AspectRatio.landscape169,
    Function(NanoBananaQueueStatus)? onQueueUpdate,
  }) async {
    final prompt = _getBackgroundPrompt(background);
    return await generateImage(
      prompt: prompt,
      numImages: numImages,
      aspectRatio: aspectRatio,
      onQueueUpdate: onQueueUpdate,
    );
  }

  /// Generate custom Halloween image with specific prompt
  Future<NanoBananaResponse> generateCustomHalloweenImage({
    required String basePrompt,
    HalloweenStyle style = HalloweenStyle.spooky,
    int numImages = 1,
    AspectRatio aspectRatio = AspectRatio.square,
    Function(NanoBananaQueueStatus)? onQueueUpdate,
  }) async {
    final enhancedPrompt = '$basePrompt. ${_getStyleModifier(style)}';
    return await generateImage(
      prompt: enhancedPrompt,
      numImages: numImages,
      aspectRatio: aspectRatio,
      onQueueUpdate: onQueueUpdate,
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