# 🎃 SpookEdit - Halloween Photo Editor App Plan

## Table of Contents
1. [App Overview](#app-overview)
2. [Technical Architecture](#technical-architecture)
3. [NanoBanana API Integration](#nanobana-api-integration)
4. [Screen-by-Screen Breakdown](#screen-by-screen-breakdown)
5. [Implementation Roadmap](#implementation-roadmap)
6. [Performance & Optimization](#performance--optimization)
7. [Monetization Strategy](#monetization-strategy)

---

## App Overview

**SpookEdit** is a Halloween-themed photo editor Flutter app that leverages the NanoBanana API (via fal.ai) for AI-powered image generation, filters, and effects.

### Core Features
- AI-powered Halloween filters and effects
- Real-time image processing
- Face detection for smart sticker placement
- Background removal and replacement
- Halloween-themed animations and GIFs
- Social sharing with community features
- Cloud storage and sync

### Target Platforms
- iOS (iPhone/iPad)
- Android (phones/tablets)
- Web (progressive web app)

---

## Technical Architecture

### State Management
```
Provider/Riverpod
├── ImageEditorProvider (current editing state)
├── NanoBananaProvider (API state & caching)
├── GalleryProvider (photo management)
├── UserPreferencesProvider (settings)
└── SocialProvider (community features)
```

### Project Structure
```
lib/
├── main.dart
├── models/
│   ├── nanobana_models.dart (API request/response models)
│   ├── editing_state.dart
│   ├── filter_models.dart
│   └── user_models.dart
├── services/
│   ├── nano_banana_service.dart (API client)
│   ├── image_processing_service.dart
│   ├── storage_service.dart
│   ├── analytics_service.dart
│   └── cache_service.dart
├── providers/
│   ├── image_editor_provider.dart
│   ├── nanobana_provider.dart
│   └── gallery_provider.dart
├── views/
│   ├── splash/
│   ├── home/
│   ├── editor/
│   ├── filters/
│   ├── effects/
│   ├── share/
│   └── test/ (nanobana_test_screen.dart)
├── widgets/
│   ├── common/
│   ├── editor/
│   └── halloween/
├── utils/
│   ├── app_constants.dart
│   ├── halloween_filters.dart
│   ├── image_utils.dart
│   └── error_handler.dart
└── assets/
    ├── fonts/
    ├── stickers/
    ├── frames/
    └── animations/
```

### Key Dependencies
```yaml
dependencies:
  # State Management
  provider: ^6.1.0

  # Image Processing
  image_picker: ^1.0.0
  image_editor: ^1.3.0
  photo_view: ^0.14.0

  # API & Networking
  dio: ^5.4.0
  http: ^1.1.0

  # ML & AI
  google_mlkit_face_detection: ^0.9.0

  # Storage
  shared_preferences: ^2.2.0
  path_provider: ^2.1.0
  gallery_saver: ^2.3.2

  # UI & Animations
  lottie: ^2.7.0
  flutter_animate: ^4.3.0
  shimmer: ^3.0.0

  # Environment
  flutter_dotenv: ^5.1.0

  # Utilities
  uuid: ^4.0.0
  intl: ^0.18.0
```

---

## NanoBanana API Integration

### API Service Architecture

#### Core NanoBananaService Structure
```dart
class NanoBananaService {
  final String apiKey;
  final Dio _dio;
  final CacheService _cache;

  // Endpoints
  static const String baseUrl = 'https://fal.ai/api';
  static const String generateEndpoint = '/fal-ai/nano-banana';

  // Core Methods
  Future<NanoBananaResponse> generateImage({...});
  Future<NanoBananaResponse> applyHalloweenFilter({...});
  Future<NanoBananaResponse> generateHalloweenBackground({...});
  Future<String> uploadFile(Uint8List data, String filename);
  Future<Uint8List> downloadImage(String url);

  // Queue Management
  Future<QueueSubmission> submitRequest({...});
  Future<QueueStatus> getStatus(String requestId);
  Future<NanoBananaResponse> getResult(String requestId);
}
```

#### API Integration by Feature

**1. Halloween Filters**
```dart
// Real-time filter preview using NanoBanana
Future<ProcessedImage> applyFilter(
  Uint8List image,
  HalloweenFilter filter
) async {
  // Check cache first
  final cached = await _cache.getFilteredImage(image, filter);
  if (cached != null) return cached;

  // Apply filter via API
  final response = await nanoBananaService.applyHalloweenFilter(
    filter: filter,
    aspectRatio: AspectRatio.square,
  );

  // Download and cache result
  final processedBytes = await nanoBananaService.downloadImage(
    response.images.first.url
  );

  await _cache.saveFilteredImage(image, filter, processedBytes);
  return ProcessedImage(processedBytes);
}
```

**2. Background Generation**
```dart
// Generate Halloween backgrounds
Future<List<BackgroundOption>> loadBackgrounds() async {
  final backgrounds = [
    HalloweenBackground.hauntedHouse,
    HalloweenBackground.cemetery,
    HalloweenBackground.darkForest,
    // ... more backgrounds
  ];

  // Generate in parallel
  final futures = backgrounds.map((bg) =>
    nanoBananaService.generateHalloweenBackground(
      background: bg,
      aspectRatio: AspectRatio.landscape169,
    )
  );

  final responses = await Future.wait(futures);
  return responses.map((r) => BackgroundOption(r)).toList();
}
```

**3. AI-Powered Smart Features**
```dart
// AI background removal
Future<Uint8List> removeBackground(Uint8List image) async {
  final uploadUrl = await nanoBananaService.uploadFile(image, 'input.jpg');

  // Use custom prompt for background removal
  final response = await nanoBananaService.generateImage(
    prompt: 'remove background, transparent, isolated subject',
    // Additional parameters
  );

  return await nanoBananaService.downloadImage(
    response.images.first.url
  );
}

// Scary-meter analysis
Future<ScaryScore> analyzeScaryLevel(Uint8List image) async {
  final response = await nanoBananaService.generateCustomHalloweenImage(
    basePrompt: 'analyze this image for Halloween scariness level',
    style: HalloweenStyle.horror,
  );

  // Parse response and calculate score
  return ScaryScore.fromAnalysis(response);
}
```

**4. Batch Processing**
```dart
// Process multiple images for collage
Future<List<ProcessedImage>> batchProcess(
  List<Uint8List> images,
  HalloweenFilter filter
) async {
  final submissions = <QueueSubmission>[];

  // Submit all requests to queue
  for (var image in images) {
    final submission = await nanoBananaService.submitRequest(
      prompt: filter.prompt,
      aspectRatio: AspectRatio.square,
    );
    submissions.add(submission);
  }

  // Poll for completion
  final results = <ProcessedImage>[];
  for (var submission in submissions) {
    final result = await _waitForCompletion(submission.requestId);
    results.add(ProcessedImage(result));
  }

  return results;
}
```

### Caching Strategy

```dart
class NanoBanaCacheService {
  static const Duration cacheDuration = Duration(hours: 24);

  // Cache layers
  final MemoryCache _memoryCache;  // For current session
  final DiskCache _diskCache;       // For persistent storage

  // Cache key generation
  String _generateKey(Uint8List image, String operation) {
    final imageHash = sha256.convert(image).toString();
    return '${operation}_$imageHash';
  }

  // Get cached result
  Future<Uint8List?> get(Uint8List image, String operation) async {
    final key = _generateKey(image, operation);

    // Try memory first (fastest)
    var cached = _memoryCache.get(key);
    if (cached != null) return cached;

    // Try disk cache
    cached = await _diskCache.get(key);
    if (cached != null) {
      _memoryCache.set(key, cached); // Promote to memory
      return cached;
    }

    return null;
  }

  // Save to cache
  Future<void> save(
    Uint8List image,
    String operation,
    Uint8List result
  ) async {
    final key = _generateKey(image, operation);
    _memoryCache.set(key, result);
    await _diskCache.set(key, result, duration: cacheDuration);
  }
}
```

### Error Handling & Retry Logic

```dart
class NanoBananaErrorHandler {
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          rethrow;
        }

        // Exponential backoff
        await Future.delayed(retryDelay * attempt);
      }
    }

    throw Exception('Max retries exceeded');
  }

  static Widget buildErrorWidget(Object error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 429:
          return RateLimitErrorWidget(
            message: 'Too many requests. Please try again later.',
            retryAfter: error.response?.headers['retry-after'],
          );
        case 402:
          return QuotaExceededWidget(
            message: 'API quota exceeded. Upgrade to continue.',
          );
        default:
          return GenericErrorWidget(message: error.message);
      }
    }

    return GenericErrorWidget(message: error.toString());
  }
}
```

---

## Screen-by-Screen Breakdown

### 1. SPLASH SCREEN

**Purpose**: Initialize app and NanoBanana API

**UI Components**:
- Animated pumpkin logo with glow effect
- Loading progress indicator
- Background particle animation (floating ghosts)

**NanoBanana Integration**:
```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Initialize NanoBanana service
      final apiKey = AppConstants.falApiKey;
      final service = NanoBananaService(apiKey: apiKey);

      // 2. Test API connectivity
      await service.generateImage(
        prompt: 'test connection',
        numImages: 1,
      );

      // 3. Preload common assets
      await _preloadHalloweenAssets();

      // 4. Check permissions
      await _checkPermissions();

      // 5. Navigate to home
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      _showErrorDialog(e);
    }
  }

  Future<void> _preloadHalloweenAssets() async {
    // Preload common stickers, fonts, etc.
    await Future.wait([
      precacheImage(AssetImage('assets/stickers/ghost.png'), context),
      precacheImage(AssetImage('assets/stickers/pumpkin.png'), context),
      // ... more assets
    ]);
  }
}
```

**Loading States**:
1. "Summoning spirits..." (0-25%)
2. "Preparing potions..." (25-50%)
3. "Awakening the dead..." (50-75%)
4. "Ready to spook!" (75-100%)

---

### 2. HOME/GALLERY SCREEN

**Purpose**: Photo selection and recent edits management

**Layout**:
```
AppBar: "Choose Your Victim 👻"
Body:
  ├── Camera FAB (floating action button)
  ├── Recent Edits Carousel (horizontal)
  ├── Gallery Grid (3 columns)
  └── Import Options Bottom Sheet
```

**NanoBanana Integration**:

**A. AI-Powered Image Suggestions**
```dart
// Suggest Halloween-worthy photos
Future<List<PhotoSuggestion>> getSuggestions() async {
  final recentPhotos = await _loadRecentPhotos();
  final suggestions = <PhotoSuggestion>[];

  for (var photo in recentPhotos) {
    // Analyze photo for Halloween potential
    final score = await _analyzeHalloweenPotential(photo);
    if (score > 0.7) {
      suggestions.add(PhotoSuggestion(
        photo: photo,
        reason: 'Great for vampire filter!',
        suggestedFilter: HalloweenFilter.vampire,
      ));
    }
  }

  return suggestions;
}
```

**B. Trending Effects Section**
```dart
// Show trending Halloween effects
Widget _buildTrendingSection() {
  return FutureBuilder<List<TrendingEffect>>(
    future: nanoBananaService.getTrendingEffects(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return ShimmerLoading();

      return HorizontalList(
        title: 'Trending This Week 🔥',
        items: snapshot.data!,
        onTap: (effect) => _applyEffectToNewPhoto(effect),
      );
    },
  );
}
```

**Features**:
- Quick camera capture
- Recent edits with re-edit capability
- Gallery grid with lazy loading
- AI suggestions for best Halloween photos
- Import from cloud storage

---

### 3. PHOTO EDITOR SCREEN

**Purpose**: Main editing interface with AI-powered tools

**Layout Architecture**:
```dart
Stack(
  children: [
    // Background: Zoomable image
    InteractiveViewer(
      child: Image.memory(editingImage),
    ),

    // Top toolbar
    Positioned(
      top: 0,
      child: EditorTopBar(
        onUndo: _undo,
        onRedo: _redo,
        onSave: _save,
      ),
    ),

    // Bottom tools
    Positioned(
      bottom: 0,
      child: EditorBottomTools(
        tools: [
          FiltersTool(),
          StickersTool(),
          TextTool(),
          AdjustmentsTool(),
          FramesTool(),
        ],
      ),
    ),

    // Processing overlay
    if (isProcessing)
      ProcessingOverlay(progress: processingProgress),
  ],
)
```

**NanoBanana Integration by Tool**:

#### A. Halloween Filters Tool

```dart
class FiltersToolPanel extends StatelessWidget {
  final List<HalloweenFilter> filters = [
    HalloweenFilter.spookyNight,
    HalloweenFilter.vampire,
    HalloweenFilter.zombie,
    HalloweenFilter.ghost,
    HalloweenFilter.pumpkinGlow,
    HalloweenFilter.haunted,
    HalloweenFilter.bloodMoon,
    HalloweenFilter.witchHour,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];

          return FilterPreviewCard(
            filter: filter,
            onTap: () => _applyFilter(context, filter),
            onLongPress: () => _showFilterIntensity(context, filter),
          );
        },
      ),
    );
  }

  Future<void> _applyFilter(
    BuildContext context,
    HalloweenFilter filter
  ) async {
    final provider = context.read<ImageEditorProvider>();

    // Show loading
    provider.setProcessing(true);

    try {
      // Get current image
      final currentImage = provider.currentImage;

      // Apply filter via NanoBanana
      final response = await nanoBananaService.applyHalloweenFilter(
        filter: filter,
        aspectRatio: AspectRatio.square,
        onQueueUpdate: (status) {
          provider.updateProgress(status.progress ?? 0);
        },
      );

      // Download result
      final filteredImage = await nanoBananaService.downloadImage(
        response.images.first.url,
      );

      // Update editor
      provider.updateImage(filteredImage);
      provider.addToHistory('Applied ${filter.name}');

    } catch (e) {
      _showError(context, e);
    } finally {
      provider.setProcessing(false);
    }
  }
}
```

**Filter Implementation**:
```dart
enum HalloweenFilter {
  spookyNight('Spooky Night', 'dark night scene with eerie atmosphere'),
  vampire('Vampire', 'pale skin, red eyes, gothic vampire style'),
  zombie('Zombie', 'decaying skin, green tint, horror zombie effect'),
  ghost('Ghost', 'ethereal transparent ghostly appearance'),
  pumpkinGlow('Pumpkin Glow', 'warm orange pumpkin glow effect'),
  haunted('Haunted', 'vintage cursed photograph effect'),
  bloodMoon('Blood Moon', 'red moon atmospheric horror'),
  witchHour('Witch Hour', 'purple-green mystical witch effect');

  const HalloweenFilter(this.displayName, this.prompt);

  final String displayName;
  final String prompt;
}
```

#### B. Stickers Tool with AI Positioning

```dart
class StickersToolPanel extends StatefulWidget {
  @override
  _StickersToolPanelState createState() => _StickersToolPanelState();
}

class _StickersToolPanelState extends State<StickersToolPanel> {
  final categories = [
    StickerCategory.creatures,
    StickerCategory.pumpkins,
    StickerCategory.props,
    StickerCategory.effects,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category tabs
        CategoryTabs(
          categories: categories,
          onCategoryChanged: (category) {
            setState(() => selectedCategory = category);
          },
        ),

        // Stickers grid
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final sticker = _getStickersForCategory(selectedCategory)[index];

              return StickerCard(
                sticker: sticker,
                onTap: () => _addSticker(sticker),
              );
            },
          ),
        ),

        // AI Smart Placement button
        ElevatedButton.icon(
          icon: Icon(Icons.auto_fix_high),
          label: Text('Smart Placement'),
          onPressed: _smartPlaceStickers,
        ),
      ],
    );
  }

  // AI-powered smart sticker placement
  Future<void> _smartPlaceStickers() async {
    final provider = context.read<ImageEditorProvider>();

    // Use face detection for optimal placement
    final faces = await _detectFaces(provider.currentImage);

    if (faces.isEmpty) {
      _showMessage('No faces detected. Add stickers manually.');
      return;
    }

    // Suggest sticker placements
    for (var face in faces) {
      final suggestions = _getStickerSuggestions(face);

      // Show placement dialog
      await _showPlacementDialog(face, suggestions);
    }
  }

  List<StickerSuggestion> _getStickerSuggestions(Face face) {
    return [
      StickerSuggestion(
        sticker: Stickers.vampireFangs,
        position: Offset(face.boundingBox.left, face.boundingBox.bottom),
        reason: 'Perfect for vampire fangs!',
      ),
      StickerSuggestion(
        sticker: Stickers.witchHat,
        position: Offset(face.boundingBox.left, face.boundingBox.top - 50),
        reason: 'Great witch hat position!',
      ),
      // More suggestions...
    ];
  }
}
```

#### C. Background Replacement with AI

```dart
class BackgroundReplacementTool extends StatefulWidget {
  @override
  _BackgroundReplacementToolState createState() =>
      _BackgroundReplacementToolState();
}

class _BackgroundReplacementToolState extends State<BackgroundReplacementTool> {
  final backgrounds = [
    HalloweenBackground.hauntedHouse,
    HalloweenBackground.cemetery,
    HalloweenBackground.darkForest,
    HalloweenBackground.fullMoon,
    HalloweenBackground.abandonedMansion,
    HalloweenBackground.pumpkinPatch,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Replace Background', style: Theme.of(context).textTheme.headline6),

        // Step 1: Remove current background
        ElevatedButton.icon(
          icon: Icon(Icons.auto_fix_high),
          label: Text('Remove Background (AI)'),
          onPressed: _removeBackground,
        ),

        SizedBox(height: 16),

        // Step 2: Select new background
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: backgrounds.length,
            itemBuilder: (context, index) {
              return BackgroundCard(
                background: backgrounds[index],
                onTap: () => _applyBackground(backgrounds[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _removeBackground() async {
    final provider = context.read<ImageEditorProvider>();
    provider.setProcessing(true);

    try {
      // Upload current image
      final uploadUrl = await nanoBananaService.uploadFile(
        provider.currentImageBytes,
        'temp_image.jpg',
      );

      // Use AI to remove background
      final response = await nanoBananaService.generateImage(
        prompt: 'remove background, transparent, isolated subject, no background',
        numImages: 1,
        outputFormat: OutputFormat.png, // PNG for transparency
      );

      // Download result
      final transparentImage = await nanoBananaService.downloadImage(
        response.images.first.url,
      );

      provider.updateImage(transparentImage);
      provider.setHasTransparentBackground(true);

      _showSuccess('Background removed successfully!');

    } catch (e) {
      _showError('Failed to remove background: $e');
    } finally {
      provider.setProcessing(false);
    }
  }

  Future<void> _applyBackground(HalloweenBackground background) async {
    final provider = context.read<ImageEditorProvider>();

    if (!provider.hasTransparentBackground) {
      _showError('Please remove background first');
      return;
    }

    provider.setProcessing(true);

    try {
      // Generate Halloween background
      final response = await nanoBananaService.generateHalloweenBackground(
        background: background,
        aspectRatio: AspectRatio.square,
      );

      // Download background
      final backgroundImage = await nanoBananaService.downloadImage(
        response.images.first.url,
      );

      // Composite images (subject on new background)
      final composite = await _compositeImages(
        background: backgroundImage,
        foreground: provider.currentImageBytes,
      );

      provider.updateImage(composite);
      provider.addToHistory('Changed background to ${background.name}');

    } catch (e) {
      _showError('Failed to apply background: $e');
    } finally {
      provider.setProcessing(false);
    }
  }

  Future<Uint8List> _compositeImages({
    required Uint8List background,
    required Uint8List foreground,
  }) async {
    // Use image package to composite
    final bgImage = img.decodeImage(background)!;
    final fgImage = img.decodeImage(foreground)!;

    // Composite foreground over background
    img.compositeImage(bgImage, fgImage);

    return Uint8List.fromList(img.encodeJpg(bgImage));
  }
}
```

#### D. Text Tool with Halloween Fonts

```dart
class TextEditorTool extends StatefulWidget {
  @override
  _TextEditorToolState createState() => _TextEditorToolState();
}

class _TextEditorToolState extends State<TextEditorTool> {
  final halloweenFonts = [
    'Creepster',
    'Eater',
    'Butcherman',
    'Nosifer',
    'Jolly Lodger',
    'Fredericka the Great',
  ];

  final textEffects = [
    TextEffect.drippingBlood,
    TextEffect.glowing,
    TextEffect.shaky,
    TextEffect.shadow3D,
  ];

  String currentText = '';
  String selectedFont = 'Creepster';
  Color textColor = Colors.white;
  TextEffect? selectedEffect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Text input
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter spooky text...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => currentText = value);
            },
          ),

          SizedBox(height: 16),

          // Font selector
          DropdownButton<String>(
            value: selectedFont,
            items: halloweenFonts.map((font) {
              return DropdownMenuItem(
                value: font,
                child: Text(font, style: GoogleFonts.getFont(font)),
              );
            }).toList(),
            onChanged: (font) {
              setState(() => selectedFont = font!);
            },
          ),

          // Color picker
          ColorPicker(
            pickerColor: textColor,
            onColorChanged: (color) {
              setState(() => textColor = color);
            },
          ),

          // Text effects
          Wrap(
            spacing: 8,
            children: textEffects.map((effect) {
              return ChoiceChip(
                label: Text(effect.name),
                selected: selectedEffect == effect,
                onSelected: (selected) {
                  setState(() => selectedEffect = selected ? effect : null);
                },
              );
            }).toList(),
          ),

          // Add text button
          ElevatedButton(
            child: Text('Add Text'),
            onPressed: _addTextToImage,
          ),
        ],
      ),
    );
  }

  Future<void> _addTextToImage() async {
    final provider = context.read<ImageEditorProvider>();

    // Create text layer
    final textLayer = TextLayer(
      text: currentText,
      font: selectedFont,
      color: textColor,
      effect: selectedEffect,
      position: Offset(100, 100), // Default position
    );

    provider.addTextLayer(textLayer);
  }
}
```

#### E. Adjustments with Real-Time Preview

```dart
class AdjustmentsTool extends StatefulWidget {
  @override
  _AdjustmentsToolState createState() => _AdjustmentsToolState();
}

class _AdjustmentsToolState extends State<AdjustmentsTool> {
  double brightness = 0;
  double contrast = 0;
  double saturation = 0;
  double spookiness = 0;
  double fogDensity = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Basic adjustments
          _buildSlider(
            label: 'Brightness',
            value: brightness,
            onChanged: (value) {
              setState(() => brightness = value);
              _applyAdjustments();
            },
          ),

          _buildSlider(
            label: 'Contrast',
            value: contrast,
            onChanged: (value) {
              setState(() => contrast = value);
              _applyAdjustments();
            },
          ),

          _buildSlider(
            label: 'Saturation',
            value: saturation,
            onChanged: (value) {
              setState(() => saturation = value);
              _applyAdjustments();
            },
          ),

          Divider(),

          // Halloween-specific adjustments
          Text('Halloween Effects', style: Theme.of(context).textTheme.headline6),

          _buildSlider(
            label: 'Spookiness 👻',
            value: spookiness,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() => spookiness = value);
              _applyHalloweenEffect();
            },
          ),

          _buildSlider(
            label: 'Fog Density 🌫️',
            value: fogDensity,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() => fogDensity = value);
              _applyFogEffect();
            },
          ),

          // Reset button
          ElevatedButton(
            child: Text('Reset All'),
            onPressed: _resetAdjustments,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = -100,
    double max = 100,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 100,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _applyAdjustments() {
    final provider = context.read<ImageEditorProvider>();

    provider.updateAdjustments(
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
    );
  }

  Future<void> _applyHalloweenEffect() async {
    // Combine multiple effects based on spookiness level
    final provider = context.read<ImageEditorProvider>();

    // Higher spookiness = darker + more contrast + desaturated
    final effectBrightness = -spookiness / 2;
    final effectContrast = spookiness / 2;
    final effectSaturation = -spookiness / 3;

    provider.updateAdjustments(
      brightness: brightness + effectBrightness,
      contrast: contrast + effectContrast,
      saturation: saturation + effectSaturation,
    );
  }
}
```

---

### 4. COLLAGE MAKER SCREEN

**Purpose**: Combine multiple photos with Halloween layouts

**NanoBanana Integration**:

```dart
class CollageMaker extends StatefulWidget {
  @override
  _CollageMakerState createState() => _CollageMakerState();
}

class _CollageMakerState extends State<CollageMaker> {
  List<Uint8List> selectedImages = [];
  CollageLayout? selectedLayout;

  final layouts = [
    CollageLayout.coffinShape,
    CollageLayout.pumpkinShape,
    CollageLayout.ghostShape,
    CollageLayout.grid2x2,
    CollageLayout.grid3x3,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Collage Maker')),
      body: Column(
        children: [
          // Image selector
          ImageSelector(
            maxImages: 9,
            onImagesSelected: (images) {
              setState(() => selectedImages = images);
            },
          ),

          // Layout selector
          LayoutSelector(
            layouts: layouts,
            onLayoutSelected: (layout) {
              setState(() => selectedLayout = layout);
            },
          ),

          // Preview
          if (selectedImages.isNotEmpty && selectedLayout != null)
            CollagePreview(
              images: selectedImages,
              layout: selectedLayout!,
            ),

          // Generate button
          ElevatedButton(
            child: Text('Generate Collage'),
            onPressed: selectedImages.length >= 2 ? _generateCollage : null,
          ),
        ],
      ),
    );
  }

  Future<void> _generateCollage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProcessingDialog(),
    );

    try {
      // Apply consistent filter to all images via NanoBanana
      final filteredImages = await _batchProcessImages(
        selectedImages,
        HalloweenFilter.spookyNight,
      );

      // Create collage layout
      final collage = await _createCollageLayout(
        filteredImages,
        selectedLayout!,
      );

      // Add Halloween decorations
      final decorated = await _addHalloweenDecorations(collage);

      Navigator.pop(context); // Close dialog

      // Navigate to editor with collage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoEditorScreen(image: decorated),
        ),
      );

    } catch (e) {
      Navigator.pop(context);
      _showError(e);
    }
  }

  Future<List<Uint8List>> _batchProcessImages(
    List<Uint8List> images,
    HalloweenFilter filter,
  ) async {
    final submissions = <QueueSubmission>[];

    // Submit all images to NanoBanana queue
    for (var image in images) {
      final uploadUrl = await nanoBananaService.uploadFile(image, 'temp.jpg');

      final submission = await nanoBananaService.submitRequest(
        prompt: filter.prompt,
        aspectRatio: AspectRatio.square,
      );

      submissions.add(submission);
    }

    // Wait for all to complete
    final results = <Uint8List>[];
    for (var submission in submissions) {
      final result = await _waitForResult(submission.requestId);
      final imageBytes = await nanoBananaService.downloadImage(result.url);
      results.add(imageBytes);
    }

    return results;
  }

  Future<Uint8List> _createCollageLayout(
    List<Uint8List> images,
    CollageLayout layout,
  ) async {
    // Use image package to create collage
    final canvas = img.Image(1080, 1080);

    // Position images according to layout
    final positions = layout.getPositions(images.length);

    for (var i = 0; i < images.length; i++) {
      final image = img.decodeImage(images[i])!;
      final position = positions[i];

      // Resize and place image
      final resized = img.copyResize(
        image,
        width: position.width.toInt(),
        height: position.height.toInt(),
      );

      img.compositeImage(
        canvas,
        resized,
        dstX: position.x.toInt(),
        dstY: position.y.toInt(),
      );
    }

    return Uint8List.fromList(img.encodeJpg(canvas));
  }
}
```

---

### 5. ANIMATION CREATOR SCREEN

**Purpose**: Create Halloween GIFs and videos

**NanoBanana Integration**:

```dart
class AnimationCreator extends StatefulWidget {
  @override
  _AnimationCreatorState createState() => _AnimationCreatorState();
}

class _AnimationCreatorState extends State<AnimationCreator> {
  List<AnimationFrame> frames = [];
  Duration frameDuration = Duration(milliseconds: 500);
  AnimationEffect? selectedEffect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Animation')),
      body: Column(
        children: [
          // Frame timeline
          FrameTimeline(
            frames: frames,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                final frame = frames.removeAt(oldIndex);
                frames.insert(newIndex, frame);
              });
            },
            onFrameTap: (frame) => _editFrame(frame),
          ),

          // Add frame button
          ElevatedButton.icon(
            icon: Icon(Icons.add_photo_alternate),
            label: Text('Add Frame'),
            onPressed: _addFrame,
          ),

          // Effect selector
          EffectSelector(
            effects: [
              AnimationEffect.thunderFlash,
              AnimationEffect.ghostFade,
              AnimationEffect.pumpkinFlicker,
              AnimationEffect.batSwarm,
            ],
            onEffectSelected: (effect) {
              setState(() => selectedEffect = effect);
            },
          ),

          // Duration slider
          Slider(
            value: frameDuration.inMilliseconds.toDouble(),
            min: 100,
            max: 2000,
            divisions: 19,
            label: '${frameDuration.inMilliseconds}ms',
            onChanged: (value) {
              setState(() => frameDuration = Duration(milliseconds: value.toInt()));
            },
          ),

          // Preview
          if (frames.length >= 2)
            AnimationPreview(
              frames: frames,
              duration: frameDuration,
              effect: selectedEffect,
            ),

          // Generate button
          ElevatedButton(
            child: Text('Generate Animation'),
            onPressed: frames.length >= 2 ? _generateAnimation : null,
          ),
        ],
      ),
    );
  }

  Future<void> _generateAnimation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProcessingDialog(message: 'Creating spooky animation...'),
    );

    try {
      // Process each frame with NanoBanana
      final processedFrames = <Uint8List>[];

      for (var frame in frames) {
        // Apply frame's filter
        final response = await nanoBananaService.applyHalloweenFilter(
          filter: frame.filter,
          aspectRatio: AspectRatio.square,
        );

        final imageBytes = await nanoBananaService.downloadImage(
          response.images.first.url,
        );

        processedFrames.add(imageBytes);
      }

      // Add effect overlays
      if (selectedEffect != null) {
        await _applyAnimationEffect(processedFrames, selectedEffect!);
      }

      // Create GIF
      final gif = await _createGif(
        processedFrames,
        frameDuration: frameDuration,
      );

      Navigator.pop(context);

      // Navigate to export screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExportScreen(
            image: gif,
            isAnimation: true,
          ),
        ),
      );

    } catch (e) {
      Navigator.pop(context);
      _showError(e);
    }
  }

  Future<Uint8List> _createGif(
    List<Uint8List> frames, {
    required Duration frameDuration,
  }) async {
    // Use image package to create GIF
    final images = frames.map((bytes) => img.decodeImage(bytes)!).toList();

    final animation = img.Animation();

    for (var image in images) {
      animation.addFrame(image);
    }

    return Uint8List.fromList(
      img.encodeGifAnimation(animation, delay: frameDuration.inMilliseconds ~/ 10)!,
    );
  }
}
```

---

### 6. SCARY-O-METER SCREEN

**Purpose**: AI analysis of photo scariness

**NanoBanana Integration**:

```dart
class ScaryOMeterScreen extends StatefulWidget {
  final Uint8List image;

  const ScaryOMeterScreen({required this.image});

  @override
  _ScaryOMeterScreenState createState() => _ScaryOMeterScreenState();
}

class _ScaryOMeterScreenState extends State<ScaryOMeterScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _meterController;
  ScaryAnalysis? analysis;
  bool isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _meterController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      // Upload image to NanoBanana
      final uploadUrl = await nanoBananaService.uploadFile(
        widget.image,
        'scary_analysis.jpg',
      );

      // Analyze image for scary elements
      // (This would use a custom prompt to analyze the image)
      final response = await nanoBananaService.generateImage(
        prompt: '''Analyze this Halloween photo and rate its scariness from 0-10.
        Consider: darkness, spooky colors, Halloween elements, facial expressions.
        Return structured analysis.''',
        numImages: 1,
      );

      // Parse analysis (in real implementation, would use vision API)
      final analysisData = await _detectHalloweenElements(widget.image);

      setState(() {
        analysis = ScaryAnalysis(
          overallScore: analysisData.score,
          darknessLevel: analysisData.darkness,
          spookyColors: analysisData.colors,
          halloweenElements: analysisData.elements,
          suggestions: analysisData.suggestions,
        );
        isAnalyzing = false;
      });

      // Animate meter to final score
      _meterController.animateTo(analysis!.overallScore / 10);

    } catch (e) {
      setState(() {
        isAnalyzing = false;
      });
      _showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scary-O-Meter 👻')),
      body: isAnalyzing
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Image preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(widget.image),
                  ),

                  SizedBox(height: 24),

                  // Scary meter gauge
                  AnimatedBuilder(
                    animation: _meterController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(300, 150),
                        painter: ScaryMeterPainter(
                          score: _meterController.value,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 16),

                  // Overall score
                  Text(
                    '${(analysis!.overallScore * 10).toInt()}% Scary',
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: _getScoreColor(analysis!.overallScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Analysis breakdown
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Analysis', style: Theme.of(context).textTheme.headline6),
                          SizedBox(height: 8),

                          _buildAnalysisRow(
                            'Darkness',
                            analysis!.darknessLevel,
                            Icons.brightness_2,
                          ),

                          _buildAnalysisRow(
                            'Spooky Colors',
                            analysis!.spookyColors,
                            Icons.palette,
                          ),

                          Divider(),

                          Text('Halloween Elements:',
                            style: Theme.of(context).textTheme.subtitle1),
                          Wrap(
                            spacing: 8,
                            children: analysis!.halloweenElements.map((element) {
                              return Chip(
                                label: Text(element),
                                avatar: Icon(Icons.check_circle, size: 16),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Suggestions
                  if (analysis!.suggestions.isNotEmpty)
                    Card(
                      color: Colors.orange.shade100,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Make it Scarier:',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            SizedBox(height: 8),
                            ...analysis!.suggestions.map((suggestion) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(child: Text(suggestion)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.edit),
                        label: Text('Edit Photo'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoEditorScreen(
                                image: widget.image,
                              ),
                            ),
                          );
                        },
                      ),

                      ElevatedButton.icon(
                        icon: Icon(Icons.share),
                        label: Text('Share Score'),
                        onPressed: _shareScore,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalysisRow(String label, double value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(label)),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(_getScoreColor(value)),
            ),
          ),
          SizedBox(width: 8),
          Text('${(value * 100).toInt()}%'),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score < 0.3) return Colors.green;
    if (score < 0.6) return Colors.orange;
    return Colors.red;
  }
}

class ScaryAnalysis {
  final double overallScore;
  final double darknessLevel;
  final double spookyColors;
  final List<String> halloweenElements;
  final List<String> suggestions;

  ScaryAnalysis({
    required this.overallScore,
    required this.darknessLevel,
    required this.spookyColors,
    required this.halloweenElements,
    required this.suggestions,
  });
}
```

---

### 7. SAVE/SHARE SCREEN

**Purpose**: Export and share edited photos

**Layout**:
```dart
class ExportScreen extends StatefulWidget {
  final Uint8List image;
  final bool isAnimation;

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  ExportQuality quality = ExportQuality.high;
  ExportFormat format = ExportFormat.jpeg;
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Save & Share')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Preview
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(widget.image),
            ),

            SizedBox(height: 24),

            // Quality selector
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export Quality', style: Theme.of(context).textTheme.headline6),
                    RadioListTile<ExportQuality>(
                      title: Text('High (Original)'),
                      subtitle: Text('Best quality, larger file'),
                      value: ExportQuality.high,
                      groupValue: quality,
                      onChanged: (value) {
                        setState(() => quality = value!);
                      },
                    ),
                    RadioListTile<ExportQuality>(
                      title: Text('Medium'),
                      subtitle: Text('Optimized for social media'),
                      value: ExportQuality.medium,
                      groupValue: quality,
                      onChanged: (value) {
                        setState(() => quality = value!);
                      },
                    ),
                    RadioListTile<ExportQuality>(
                      title: Text('Low'),
                      subtitle: Text('Smaller file, faster sharing'),
                      value: ExportQuality.low,
                      groupValue: quality,
                      onChanged: (value) {
                        setState(() => quality = value!);
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Format selector (if not animation)
            if (!widget.isAnimation)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Format', style: Theme.of(context).textTheme.headline6),
                      SegmentedButton<ExportFormat>(
                        segments: [
                          ButtonSegment(
                            value: ExportFormat.jpeg,
                            label: Text('JPEG'),
                          ),
                          ButtonSegment(
                            value: ExportFormat.png,
                            label: Text('PNG'),
                          ),
                        ],
                        selected: {format},
                        onSelectionChanged: (Set<ExportFormat> newSelection) {
                          setState(() => format = newSelection.first);
                        },
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Save to Gallery'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16),
                ),
                onPressed: isSaving ? null : _saveToGallery,
              ),
            ),

            SizedBox(height: 16),

            // Share buttons
            Text('Share to:', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 8),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildShareButton(
                  icon: Icons.photo_library,
                  label: 'Instagram',
                  color: Colors.purple,
                  onPressed: () => _shareToInstagram(),
                ),
                _buildShareButton(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onPressed: () => _shareToWhatsApp(),
                ),
                _buildShareButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  color: Colors.blue,
                  onPressed: () => _shareToFacebook(),
                ),
                _buildShareButton(
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: Colors.grey,
                  onPressed: () => _shareGeneric(),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Halloween hashtags
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tag, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Suggested Hashtags',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '#Halloween2024 #SpookEdit #HalloweenPhotos #SpookyVibes #TrickOrTreat',
                      style: TextStyle(color: Colors.blue),
                    ),
                    SizedBox(height: 8),
                    TextButton.icon(
                      icon: Icon(Icons.copy),
                      label: Text('Copy Hashtags'),
                      onPressed: _copyHashtags,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          iconSize: 40,
          color: color,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            padding: EdgeInsets.all(16),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _saveToGallery() async {
    setState(() => isSaving = true);

    try {
      // Process image based on quality settings
      final processedImage = await _processForExport(
        widget.image,
        quality: quality,
        format: format,
      );

      // Save to gallery
      final result = await GallerySaver.saveImage(
        processedImage.path,
        albumName: 'SpookEdit',
      );

      if (result == true) {
        _showSuccess('Saved to gallery!');
      } else {
        _showError('Failed to save image');
      }

    } catch (e) {
      _showError('Error saving image: $e');
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<File> _processForExport(
    Uint8List imageBytes, {
    required ExportQuality quality,
    required ExportFormat format,
  }) async {
    // Decode image
    var image = img.decodeImage(imageBytes)!;

    // Resize based on quality
    switch (quality) {
      case ExportQuality.high:
        // Keep original size
        break;
      case ExportQuality.medium:
        image = img.copyResize(image, width: 1080);
        break;
      case ExportQuality.low:
        image = img.copyResize(image, width: 720);
        break;
    }

    // Encode in selected format
    List<int> encoded;
    String extension;

    switch (format) {
      case ExportFormat.jpeg:
        encoded = img.encodeJpg(image, quality: _getJpegQuality(quality));
        extension = 'jpg';
        break;
      case ExportFormat.png:
        encoded = img.encodePng(image);
        extension = 'png';
        break;
    }

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/spookedit_$timestamp.$extension');
    await file.writeAsBytes(encoded);

    return file;
  }

  int _getJpegQuality(ExportQuality quality) {
    switch (quality) {
      case ExportQuality.high:
        return 95;
      case ExportQuality.medium:
        return 85;
      case ExportQuality.low:
        return 70;
    }
  }
}

enum ExportQuality { high, medium, low }
enum ExportFormat { jpeg, png }
```

---

### 8. SETTINGS SCREEN

**Purpose**: App preferences and NanoBanana API management

```dart
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = true;
  bool soundEffects = true;
  bool autoSave = false;
  ExportQuality defaultQuality = ExportQuality.high;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          // App Preferences
          ListTile(
            title: Text('Appearance', style: Theme.of(context).textTheme.headline6),
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            subtitle: Text('Spooky dark theme'),
            value: darkMode,
            onChanged: (value) {
              setState(() => darkMode = value);
              // Update theme
            },
          ),

          Divider(),

          // Sound
          ListTile(
            title: Text('Audio', style: Theme.of(context).textTheme.headline6),
          ),
          SwitchListTile(
            title: Text('Sound Effects'),
            subtitle: Text('Spooky sounds while editing'),
            value: soundEffects,
            onChanged: (value) {
              setState(() => soundEffects = value);
            },
          ),

          Divider(),

          // Export Settings
          ListTile(
            title: Text('Export', style: Theme.of(context).textTheme.headline6),
          ),
          SwitchListTile(
            title: Text('Auto-save'),
            subtitle: Text('Automatically save edits'),
            value: autoSave,
            onChanged: (value) {
              setState(() => autoSave = value);
            },
          ),
          ListTile(
            title: Text('Default Quality'),
            subtitle: Text(defaultQuality.name),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showQualityDialog,
          ),

          Divider(),

          // NanoBanana API Settings
          ListTile(
            title: Text('API & Storage', style: Theme.of(context).textTheme.headline6),
          ),
          ListTile(
            title: Text('API Status'),
            subtitle: FutureBuilder<bool>(
              future: _checkApiStatus(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text('Checking...');
                }
                return Text(
                  snapshot.data! ? 'Connected ✓' : 'Disconnected ✗',
                  style: TextStyle(
                    color: snapshot.data! ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            trailing: Icon(Icons.info_outline),
            onTap: _showApiInfo,
          ),
          ListTile(
            title: Text('Clear Cache'),
            subtitle: Text('Free up storage space'),
            trailing: Icon(Icons.delete_outline),
            onTap: _clearCache,
          ),

          Divider(),

          // About
          ListTile(
            title: Text('About', style: Theme.of(context).textTheme.headline6),
          ),
          ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: Text('Rate App'),
            trailing: Icon(Icons.star_outline),
            onTap: _rateApp,
          ),
          ListTile(
            title: Text('Share App'),
            trailing: Icon(Icons.share),
            onTap: _shareApp,
          ),
        ],
      ),
    );
  }

  Future<bool> _checkApiStatus() async {
    try {
      final service = NanoBananaService(apiKey: AppConstants.falApiKey);
      await service.generateImage(
        prompt: 'test',
        numImages: 1,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _showApiInfo() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('NanoBanana API Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Provider: fal.ai'),
            SizedBox(height: 8),
            Text('Model: nano-banana'),
            SizedBox(height: 8),
            FutureBuilder<ApiUsage>(
              future: _getApiUsage(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Usage Today: ${snapshot.data!.requestsToday}'),
                    Text('Quota: ${snapshot.data!.quotaRemaining} remaining'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Upgrade'),
            onPressed: () {
              Navigator.pop(context);
              _showUpgradeDialog();
            },
          ),
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache?'),
        content: Text('This will delete all cached images and free up storage.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Clear'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear cache
      await CacheService.clearAll();
      _showSuccess('Cache cleared successfully!');
    }
  }
}
```

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [x] Set up Flutter project structure
- [x] Integrate NanoBanana API (fal.ai)
- [ ] Implement basic state management (Provider)
- [ ] Create splash screen with loading
- [ ] Implement home/gallery screen
- [ ] Set up environment variables (.env)

### Phase 2: Core Editor (Weeks 3-5)
- [ ] Build photo editor screen layout
- [ ] Implement zoom/pan for images
- [ ] Add Halloween filters integration
- [ ] Create filter preview thumbnails
- [ ] Implement stickers system
- [ ] Add text editor with Halloween fonts
- [ ] Build adjustments panel

### Phase 3: AI Features (Weeks 6-7)
- [ ] Implement face detection (ML Kit)
- [ ] Create smart sticker placement
- [ ] Add background removal via NanoBanana
- [ ] Build background generator
- [ ] Implement scary-o-meter analysis
- [ ] Add batch processing for collages

### Phase 4: Advanced Features (Weeks 8-9)
- [ ] Create collage maker
- [ ] Implement animation creator
- [ ] Add frames and borders
- [ ] Build export/share functionality
- [ ] Implement caching system
- [ ] Add undo/redo functionality

### Phase 5: Polish & Optimization (Weeks 10-11)
- [ ] Performance optimization
- [ ] Error handling improvements
- [ ] UI/UX refinements
- [ ] Add animations and transitions
- [ ] Implement analytics
- [ ] Create tutorial/onboarding

### Phase 6: Testing & Launch (Week 12)
- [ ] Unit testing
- [ ] Integration testing
- [ ] Beta testing
- [ ] Bug fixes
- [ ] App store preparation
- [ ] Launch!

---

## Performance & Optimization

### Image Processing Optimization

```dart
class ImageProcessor {
  // Use isolates for heavy processing
  static Future<Uint8List> processInIsolate(
    Uint8List imageData,
    ProcessingFunction function,
  ) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _isolateEntry,
      IsolateData(
        sendPort: receivePort.sendPort,
        imageData: imageData,
        function: function,
      ),
    );

    return await receivePort.first as Uint8List;
  }

  static void _isolateEntry(IsolateData data) async {
    final result = await data.function(data.imageData);
    data.sendPort.send(result);
  }
}
```

### Memory Management

```dart
class ImageCache {
  final int maxCacheSize = 50 * 1024 * 1024; // 50 MB
  final Map<String, CacheEntry> _cache = {};
  int _currentSize = 0;

  void put(String key, Uint8List data) {
    // Remove oldest entries if needed
    while (_currentSize + data.length > maxCacheSize && _cache.isNotEmpty) {
      _removeOldest();
    }

    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
    _currentSize += data.length;
  }

  void _removeOldest() {
    var oldest = _cache.entries.first;

    for (var entry in _cache.entries) {
      if (entry.value.timestamp.isBefore(oldest.value.timestamp)) {
        oldest = entry;
      }
    }

    _currentSize -= oldest.value.data.length;
    _cache.remove(oldest.key);
  }
}
```

### API Request Optimization

```dart
class RequestBatcher {
  static const Duration batchWindow = Duration(milliseconds: 500);
  final List<BatchRequest> _pending = [];
  Timer? _timer;

  Future<T> addRequest<T>(Future<T> Function() request) async {
    final completer = Completer<T>();

    _pending.add(BatchRequest(
      request: request,
      completer: completer,
    ));

    _timer?.cancel();
    _timer = Timer(batchWindow, _processBatch);

    return completer.future;
  }

  Future<void> _processBatch() async {
    if (_pending.isEmpty) return;

    final batch = List.from(_pending);
    _pending.clear();

    // Process all requests in parallel
    await Future.wait(
      batch.map((req) async {
        try {
          final result = await req.request();
          req.completer.complete(result);
        } catch (e) {
          req.completer.completeError(e);
        }
      }),
    );
  }
}
```

---

## Monetization Strategy

### Free Tier
- 20 filter applications per day
- 10 AI background removals per day
- Basic stickers and frames
- Standard export quality
- Watermark on exports

### Premium Tier ($4.99/month)
- Unlimited filter applications
- Unlimited AI features
- Exclusive Halloween stickers
- Premium frames and effects
- No watermark
- Priority processing
- Cloud storage (5GB)
- Early access to new features

### One-time Purchases
- Sticker packs ($0.99-$2.99)
- Filter packs ($1.99-$3.99)
- Remove ads ($2.99)
- Lifetime premium ($19.99)

---

## Analytics & Tracking

```dart
class AnalyticsService {
  static Future<void> trackEvent(String event, Map<String, dynamic> properties) async {
    // Send to analytics service (Firebase, Mixpanel, etc.)
    await FirebaseAnalytics.instance.logEvent(
      name: event,
      parameters: properties,
    );
  }

  static Future<void> trackFilterUsage(HalloweenFilter filter) async {
    await trackEvent('filter_applied', {
      'filter_name': filter.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> trackExport(ExportFormat format, ExportQuality quality) async {
    await trackEvent('image_exported', {
      'format': format.name,
      'quality': quality.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

---

## Conclusion

This comprehensive app plan provides a complete roadmap for building **SpookEdit**, a Halloween photo editor powered by the NanoBanana API. The architecture is designed for:

1. **Scalability**: Modular design allows easy addition of new features
2. **Performance**: Caching, isolates, and optimization strategies
3. **User Experience**: Smooth animations and responsive UI
4. **Monetization**: Clear premium features and upgrade path
5. **Maintainability**: Clean code structure and documentation

Follow the implementation roadmap phase by phase, and you'll have a fully functional Halloween photo editor ready for launch!

**Next Steps**:
1. Review and refine the plan based on your specific requirements
2. Set up the development environment
3. Begin Phase 1 implementation
4. Iterate based on user feedback

Happy coding, and have a spooky Halloween! 🎃👻