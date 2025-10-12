# Nanobana API Integration Guide

This document explains how to use the fal.ai Nanobana API integration in SpookEdit.

## Setup

### 1. Get Your API Key

1. Visit [fal.ai dashboard](https://fal.ai/dashboard/keys)
2. Create an account or sign in
3. Generate a new API key

### 2. Configure Environment Variables

1. Open the `.env` file in the project root
2. Replace `YOUR_API_KEY_HERE` with your actual API key:

```env
FAL_API_KEY=your_actual_api_key_here
```

**Important:** Never commit your `.env` file to version control! It's already in `.gitignore`.

### 3. Install Dependencies

```bash
flutter pub get
```

## Usage Examples

### Basic Image Generation

```dart
import 'package:spook_edit/services/nano_banana_service.dart';
import 'package:spook_edit/models/nanobana_models.dart';
import 'package:spook_edit/utils/app_constants.dart';

// Initialize the service
final service = NanoBananaService(apiKey: AppConstants.falApiKey);

// Generate an image
final response = await service.generateImage(
  prompt: 'A spooky haunted house at night',
  aspectRatio: AspectRatio.square,
  outputFormat: OutputFormat.jpeg,
);

// Get the image URL
final imageUrl = response.images.first.url;
```

### With Queue Status Updates

```dart
final response = await service.generateImage(
  prompt: 'A vampire in gothic castle',
  onQueueUpdate: (status) {
    print('Status: ${status.status}');
    if (status.queuePosition != null) {
      print('Queue position: ${status.queuePosition}');
    }
  },
);
```

### Halloween Filters

The service includes pre-configured Halloween filters:

```dart
// Apply a Halloween filter
final response = await service.applyHalloweenFilter(
  filter: HalloweenFilter.spookyNight,
  aspectRatio: AspectRatio.square,
);
```

Available filters:
- `HalloweenFilter.spookyNight` - Dark night scene with eerie atmosphere
- `HalloweenFilter.vampire` - Vampire-themed with red eyes and gothic style
- `HalloweenFilter.zombie` - Zombie horror with decay and green tint
- `HalloweenFilter.ghost` - Ethereal ghostly appearance
- `HalloweenFilter.pumpkinGlow` - Warm pumpkin orange glow
- `HalloweenFilter.haunted` - Vintage cursed photo effect
- `HalloweenFilter.bloodMoon` - Red moon atmosphere
- `HalloweenFilter.witchHour` - Purple-green mystical effect

### Generate Halloween Backgrounds

```dart
final response = await service.generateHalloweenBackground(
  background: HalloweenBackground.hauntedHouse,
  aspectRatio: AspectRatio.landscape169,
);
```

Available backgrounds:
- `HalloweenBackground.hauntedHouse`
- `HalloweenBackground.cemetery`
- `HalloweenBackground.darkForest`
- `HalloweenBackground.fullMoon`
- `HalloweenBackground.abandonedMansion`
- `HalloweenBackground.pumpkinPatch`

### Custom Halloween Images

```dart
final response = await service.generateCustomHalloweenImage(
  basePrompt: 'A cute cat wearing a witch hat',
  style: HalloweenStyle.cute,
  aspectRatio: AspectRatio.square,
);
```

Available styles:
- `HalloweenStyle.spooky` - Eerie and haunting
- `HalloweenStyle.cute` - Family-friendly and playful
- `HalloweenStyle.horror` - Terrifying and dark
- `HalloweenStyle.vintage` - Classic retro Halloween
- `HalloweenStyle.gothic` - Victorian dark romantic

### Non-blocking Queue Operations

For long-running requests, use the queue methods:

```dart
// Submit request
final submission = await service.submitRequest(
  prompt: 'Complex Halloween scene',
  aspectRatio: AspectRatio.landscape169,
  webhookUrl: 'https://your-webhook-url.com', // Optional
);

// Check status later
final status = await service.getStatus(submission.requestId);

if (status.isCompleted) {
  // Get the result
  final result = await service.getResult(submission.requestId);
  final imageUrl = result.images.first.url;
}
```

### File Upload

Upload files to fal.ai storage:

```dart
final url = await service.uploadFile(imageBytes, 'halloween_photo.jpg');
```

### Download Generated Images

```dart
final imageBytes = await service.downloadImage(imageUrl);
```

## Testing

A test screen is included to verify the integration:

```dart
import 'package:spook_edit/views/test/nanobana_test_screen.dart';

// Navigate to test screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const NanoBananaTestScreen()),
);
```

## API Models

### Request Model

```dart
NanoBananaRequest(
  prompt: 'Your prompt here',
  numImages: 1,                    // Default: 1
  outputFormat: 'jpeg',             // 'jpeg' or 'png'
  aspectRatio: '1:1',              // See AspectRatio enum
  syncMode: false,                 // Default: false
)
```

### Response Model

```dart
class NanoBananaResponse {
  final List<NanoBananaImage> images;
  final String? description;
}

class NanoBananaImage {
  final String url;
  final String? contentType;
  final String? fileName;
  final int? fileSize;
}
```

## Aspect Ratios

Available aspect ratios:
- `1:1` (square)
- `16:9` (landscape)
- `9:16` (portrait)
- `21:9` (ultrawide)
- `4:3`, `3:2`, `2:3`, `5:4`, `4:5`, `3:4`

## Error Handling

Always wrap API calls in try-catch blocks:

```dart
try {
  final response = await service.generateImage(
    prompt: 'Spooky scene',
  );
  // Handle success
} catch (e) {
  // Handle error
  print('Error generating image: $e');
}
```

## API Limits & Pricing

- Check your usage at [fal.ai dashboard](https://fal.ai/dashboard)
- API limits depend on your plan
- Generation time varies (typically 5-15 seconds)

## Troubleshooting

### "API Key not found" error
- Ensure `.env` file exists in project root
- Verify `FAL_API_KEY` is set correctly
- Run `flutter pub get` after creating `.env`

### "Asset .env doesn't exist" warning
- Make sure `.env` file is in the project root (not in lib/)
- Check that `.env` is listed in `pubspec.yaml` under assets

### Images not loading
- Check internet connection
- Verify API key is valid
- Check console for error messages

## Additional Resources

- [fal.ai Nanobana Documentation](https://fal.ai/models/fal-ai/nano-banana)
- [fal.ai API Reference](https://fal.ai/docs)
- [Flutter dotenv Package](https://pub.dev/packages/flutter_dotenv)