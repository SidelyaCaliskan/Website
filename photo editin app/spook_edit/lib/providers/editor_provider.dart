import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/edit_history.dart';
import '../models/halloween_prompt.dart';
import '../models/sticker_model.dart';
import '../models/text_sticker_model.dart';
import '../services/nano_banana_service.dart';
import '../services/local_image_filters.dart';
import '../services/image_composition_service.dart';
import '../utils/app_constants.dart';

/// Provider for managing the photo editor state
class EditorProvider with ChangeNotifier {
  // Services
  late NanoBananaService _nanoBananaService;

  // Disposed state
  bool _disposed = false;
  bool _notificationScheduled = false;

  // Current editing state
  Uint8List? _currentImage;
  Uint8List? _originalImage;
  final EditHistory _editHistory = EditHistory(maxHistorySize: AppConstants.maxUndoStack);

  // Adjustments
  double _brightness = 0;
  double _contrast = 0;
  double _saturation = 0;
  double _spookiness = 0;

  // Loading states
  bool _isProcessing = false;
  String _statusMessage = '';

  // Applied filter
  HalloweenFilter? _appliedFilter;

  // Selected prompt (for style-first workflow)
  HalloweenPrompt? _selectedPrompt;

  // Stickers
  final List<StickerModel> _stickers = [];
  String? _selectedStickerId;

  // Text stickers
  final List<TextStickerModel> _textStickers = [];
  String? _selectedTextStickerId;

  EditorProvider() {
    _nanoBananaService = NanoBananaService(apiKey: AppConstants.falApiKey);
  }

  // Getters
  Uint8List? get currentImage => _currentImage;
  Uint8List? get originalImage => _originalImage;
  double get brightness => _brightness;
  double get contrast => _contrast;
  double get saturation => _saturation;
  double get spookiness => _spookiness;
  bool get isProcessing => _isProcessing;
  String get statusMessage => _statusMessage;
  bool get canUndo => _editHistory.canUndo;
  bool get canRedo => _editHistory.canRedo;
  HalloweenFilter? get appliedFilter => _appliedFilter;

  // Sticker getters
  List<StickerModel> get stickers => List.unmodifiable(_stickers);
  String? get selectedStickerId => _selectedStickerId;
  List<TextStickerModel> get textStickers => List.unmodifiable(_textStickers);
  String? get selectedTextStickerId => _selectedTextStickerId;

  // Selected prompt getter
  HalloweenPrompt? get selectedPrompt => _selectedPrompt;

  /// Initialize editor with an image
  void initializeImage(Uint8List imageData) {
    _originalImage = imageData;
    _currentImage = imageData;
    _editHistory.clear();
    _editHistory.addState(imageData, description: 'Original');
    _resetAdjustments();
    notifyListeners();
  }

  /// Apply Halloween filter using Nano Banana API
  Future<void> applyFilter(HalloweenFilter filter) async {
    if (_currentImage == null) {
      throw Exception('No image loaded');
    }

    _setProcessing(true, 'Applying ${filter.name} filter...');

    try {
      final response = await _nanoBananaService.applyHalloweenFilter(
        imageData: _currentImage!,
        filter: filter,
        onQueueUpdate: (status) {
          if (status.isInProgress) {
            _setProcessing(true, 'Processing... ${status.status}');
          }
        },
      );

      if (response.images.isNotEmpty) {
        final imageUrl = response.images.first.url;
        final imageBytes = await _nanoBananaService.downloadImage(imageUrl);

        _currentImage = imageBytes;
        _appliedFilter = filter;
        _editHistory.addState(imageBytes, description: 'Filter: ${filter.name}');
        _setProcessing(false, 'Filter applied successfully!');
      } else {
        _setProcessing(false, 'Failed to apply filter');
      }
    } catch (e) {
      _setProcessing(false, 'Error: ${_formatApiError(e)}');
    }
    // No additional notifyListeners needed - _setProcessing handles it
  }

  /// Replace background using Nano Banana API
  Future<void> replaceBackground(HalloweenBackground background) async {
    if (_currentImage == null) {
      throw Exception('No image loaded');
    }

    _setProcessing(true, 'Replacing background...');

    try {
      final response = await _nanoBananaService.generateHalloweenBackground(
        background: background,
        onQueueUpdate: (status) {
          if (status.isInProgress) {
            _setProcessing(true, 'Generating... ${status.status}');
          }
        },
      );

      if (response.images.isNotEmpty) {
        final imageUrl = response.images.first.url;
        final imageBytes = await _nanoBananaService.downloadImage(imageUrl);

        _currentImage = imageBytes;
        _editHistory.addState(imageBytes, description: 'Background: ${background.name}');
        _setProcessing(false, 'Background replaced!');
      } else {
        _setProcessing(false, 'Failed to replace background');
      }
    } catch (e) {
      _setProcessing(false, 'Error: ${_formatApiError(e)}');
    }
    // No additional notifyListeners needed - _setProcessing handles it
  }

  /// Apply custom edit with natural language prompt
  Future<void> applyCustomEdit(String prompt) async {
    if (_currentImage == null) {
      throw Exception('No image loaded');
    }

    _setProcessing(true, 'Processing your request...');

    try {
      final response = await _nanoBananaService.editImage(
        imageData: _currentImage!,
        prompt: prompt,
        onQueueUpdate: (status) {
          if (status.isInProgress) {
            _setProcessing(true, 'Creating... ${status.status}');
          }
        },
      );

      if (response.images.isNotEmpty) {
        final imageUrl = response.images.first.url;
        final imageBytes = await _nanoBananaService.downloadImage(imageUrl);

        _currentImage = imageBytes;
        _editHistory.addState(imageBytes, description: prompt);
        _setProcessing(false, 'Edit applied!');
      } else {
        _setProcessing(false, 'Failed to apply edit');
      }
    } catch (e) {
      _setProcessing(false, 'Error: ${_formatApiError(e)}');
    }
    // No additional notifyListeners needed - _setProcessing handles it
  }

  /// Apply Halloween creative prompt
  Future<void> applyHalloweenPrompt(HalloweenPrompt halloweenPrompt) async {
    if (_currentImage == null) {
      throw Exception('No image loaded');
    }

    print('👻 Applying Halloween prompt: ${halloweenPrompt.title}');
    _setProcessing(true, 'Applying ${halloweenPrompt.title}...');

    try {
      // Use the full prompt with quality tags
      print('👻 Full prompt: ${halloweenPrompt.fullPrompt}');
      final response = await _nanoBananaService.editImage(
        imageData: _currentImage!,
        prompt: halloweenPrompt.fullPrompt,
        onQueueUpdate: (status) {
          if (status.isInProgress) {
            _setProcessing(true, 'Creating magic... ${status.status}');
          }
        },
      );

      print('👻 Received response with ${response.images.length} images');
      if (response.images.isNotEmpty) {
        final imageUrl = response.images.first.url;
        print('👻 Downloading image from: $imageUrl');
        final imageBytes = await _nanoBananaService.downloadImage(imageUrl);
        print('👻 Downloaded ${imageBytes.length} bytes');

        _currentImage = imageBytes;
        _editHistory.addState(imageBytes, description: halloweenPrompt.title);
        _setProcessing(false, '${halloweenPrompt.title} applied!');
        print('👻 Successfully applied transformation!');
      } else {
        print('❌ No images in response!');
        _setProcessing(false, 'Failed to apply ${halloweenPrompt.title}');
      }
    } catch (e) {
      print('❌ Error applying Halloween prompt: $e');
      _setProcessing(false, 'Error: ${_formatApiError(e)}');
    }
    // No additional notifyListeners needed - _setProcessing handles it
  }

  /// Update brightness
  void updateBrightness(double value) {
    _brightness = value;
    notifyListeners();
  }

  /// Update contrast
  void updateContrast(double value) {
    _contrast = value;
    notifyListeners();
  }

  /// Update saturation
  void updateSaturation(double value) {
    _saturation = value;
    notifyListeners();
  }

  /// Update spookiness level
  void updateSpookiness(double value) {
    _spookiness = value;
    notifyListeners();
  }

  /// Apply current adjustments to image
  Future<void> applyAdjustments() async {
    if (_originalImage == null) return;

    // Check if any adjustments are active
    if (_brightness == 0 &&
        _contrast == 0 &&
        _saturation == 0 &&
        _spookiness == 0) {
      return;
    }

    _setProcessing(true, 'Applying adjustments...');

    try {
      // Start with original or current image
      Uint8List imageToProcess = _originalImage!;

      // Apply basic adjustments
      if (_brightness != 0 || _contrast != 0 || _saturation != 0) {
        imageToProcess = await LocalImageFilters.applyAllAdjustments(
          imageToProcess,
          brightness: _brightness,
          contrast: _contrast,
          saturation: _saturation,
        );
      }

      // Apply spookiness filter
      if (_spookiness != 0) {
        imageToProcess = await LocalImageFilters.applySpookiness(
          imageToProcess,
          _spookiness,
        );
      }

      _currentImage = imageToProcess;
      _editHistory.addState(
        imageToProcess,
        description: 'Adjustments applied',
      );

      _setProcessing(false, 'Adjustments applied!');
    } catch (e) {
      _setProcessing(false, 'Failed to apply adjustments: $e');
    }
    // No additional notifyListeners needed - _setProcessing handles it
  }

  /// Apply a local preset filter
  Future<void> applyLocalPreset(FilterPreset preset) async {
    if (_currentImage == null) return;

    _setProcessing(true, 'Applying ${preset.name}...');

    try {
      final filtered = await LocalImageFilters.applyPreset(
        _currentImage!,
        preset,
      );

      _currentImage = filtered;
      _editHistory.addState(filtered, description: 'Filter: ${preset.name}');
      _setProcessing(false, '${preset.name} applied!');
    } catch (e) {
      _setProcessing(false, 'Failed to apply filter: $e');
    }
    // No additional notifyListeners needed - _setProcessing handles it
  }

  /// Reset all adjustments
  void _resetAdjustments() {
    _brightness = 0;
    _contrast = 0;
    _saturation = 0;
    _spookiness = 0;
  }

  /// Reset adjustments and return to original
  void resetAdjustments() {
    _brightness = 0;
    _contrast = 0;
    _saturation = 0;
    _spookiness = 0;
    if (_originalImage != null) {
      _currentImage = _originalImage;
    }
    notifyListeners();
  }

  /// Undo last edit
  void undo() {
    final previousState = _editHistory.undo();
    if (previousState != null) {
      _currentImage = previousState.imageData;
      notifyListeners();
    }
  }

  /// Redo edit
  void redo() {
    final nextState = _editHistory.redo();
    if (nextState != null) {
      _currentImage = nextState.imageData;
      notifyListeners();
    }
  }

  /// Reset to original image
  void resetToOriginal() {
    if (_originalImage != null) {
      _currentImage = _originalImage;
      _editHistory.clear();
      _editHistory.addState(_originalImage!, description: 'Original');
      _resetAdjustments();
      _appliedFilter = null;
      notifyListeners();
    }
  }

  /// Set processing state
  void _setProcessing(bool processing, String message) {
    if (_disposed) return;

    _isProcessing = processing;
    _statusMessage = message;

    // Schedule notification for after the current frame to avoid
    // calling notifyListeners during build phase
    // Only schedule one notification at a time to prevent callback buildup
    if (!_notificationScheduled) {
      _notificationScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notificationScheduled = false;
        if (!_disposed) {
          notifyListeners();
        }
      });
    }

  }

  // Sticker management methods

  /// Add a sticker to the image
  void addSticker(StickerModel sticker) {
    _stickers.add(sticker);
    _selectedStickerId = sticker.id;
    notifyListeners();
  }

  /// Select a sticker by ID
  void selectSticker(String? stickerId) {
    _selectedStickerId = stickerId;
    notifyListeners();
  }

  /// Update a sticker's properties
  void updateSticker(String stickerId, {
    Offset? position,
    double? scale,
    double? rotation,
    bool? isFlipped,
  }) {
    final index = _stickers.indexWhere((s) => s.id == stickerId);
    if (index != -1) {
      _stickers[index] = _stickers[index].copyWith(
        position: position,
        scale: scale,
        rotation: rotation,
        isFlipped: isFlipped,
      );
      notifyListeners();
    }
  }

  /// Remove a sticker by ID
  void removeSticker(String stickerId) {
    _stickers.removeWhere((s) => s.id == stickerId);
    if (_selectedStickerId == stickerId) {
      _selectedStickerId = null;
    }
    notifyListeners();
  }

  /// Add a text sticker to the image
  void addTextSticker(TextStickerModel textSticker) {
    _textStickers.add(textSticker);
    _selectedTextStickerId = textSticker.id;
    notifyListeners();
  }

  /// Select a text sticker by ID
  void selectTextSticker(String? textStickerId) {
    _selectedTextStickerId = textStickerId;
    notifyListeners();
  }

  /// Update a text sticker's properties
  void updateTextSticker(String textStickerId, {
    String? text,
    Offset? position,
    double? scale,
    double? rotation,
    Color? textColor,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
  }) {
    final index = _textStickers.indexWhere((s) => s.id == textStickerId);
    if (index != -1) {
      _textStickers[index] = _textStickers[index].copyWith(
        text: text,
        position: position,
        scale: scale,
        rotation: rotation,
        textColor: textColor,
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        textAlign: textAlign,
      );
      notifyListeners();
    }
  }

  /// Remove a text sticker by ID
  void removeTextSticker(String textStickerId) {
    _textStickers.removeWhere((s) => s.id == textStickerId);
    if (_selectedTextStickerId == textStickerId) {
      _selectedTextStickerId = null;
    }
    notifyListeners();
  }

  /// Set selected prompt (for style-first workflow)
  void setSelectedPrompt(HalloweenPrompt? prompt) {
    _selectedPrompt = prompt;
    notifyListeners();
  }

  /// Clear selected prompt
  void clearSelectedPrompt() {
    _selectedPrompt = null;
    notifyListeners();
  }

  /// Get the final composited image with stickers rendered
  /// Returns the image with all stickers permanently drawn on it
  Future<Uint8List> getCompositedImage(Size canvasSize) async {
    if (_currentImage == null) {
      throw Exception('No image loaded');
    }

    if (_stickers.isEmpty) {
      // No stickers, return current image
      return _currentImage!;
    }

    try {
      // Use the Canvas-based method for better quality emoji rendering
      return await ImageCompositionService.composeImageWithStickersCanvas(
        baseImageBytes: _currentImage!,
        stickers: _stickers,
        canvasSize: canvasSize,
      );
    } catch (e) {
      // Fallback to image package method if Canvas method fails
      try {
        return await ImageCompositionService.composeImageWithStickers(
          baseImageBytes: _currentImage!,
          stickers: _stickers,
          canvasSize: canvasSize,
        );
      } catch (fallbackError) {
        debugPrint('Failed to composite image: $e, Fallback error: $fallbackError');
        // Return original image if both methods fail
        return _currentImage!;
      }
    }
  }

  /// Clear editor state
  void clearEditor() {
    _currentImage = null;
    _originalImage = null;
    _editHistory.clear();
    _stickers.clear();
    _selectedStickerId = null;
    _textStickers.clear();
    _selectedTextStickerId = null;
    _selectedPrompt = null;
    _resetAdjustments();
    _appliedFilter = null;
    _isProcessing = false;
    _statusMessage = '';
    notifyListeners();
  }

  /// Format API error messages for user display
  String _formatApiError(dynamic error) {
    final errorString = error.toString();

    // Check for common API errors
    if (errorString.contains('401') || errorString.contains('Unauthorized')) {
      return 'Invalid API key. Please check your fal.ai API key.';
    } else if (errorString.contains('429') || errorString.contains('rate limit')) {
      return 'Rate limit exceeded. Please try again later.';
    } else if (errorString.contains('timeout') || errorString.contains('Timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('network') || errorString.contains('NetworkException')) {
      return 'Network error. Please check your connection.';
    }

    // Return a shortened error message
    return errorString.length > 100
        ? '${errorString.substring(0, 100)}...'
        : errorString;
  }

  @override
  void dispose() {
    _disposed = true;
    clearEditor();
    super.dispose();
  }
}
