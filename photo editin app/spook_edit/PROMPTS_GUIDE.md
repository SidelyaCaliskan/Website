# Halloween Prompts Integration Guide

This guide explains how to use the 40+ pre-made Halloween prompts in SpookEdit with the Nanobana API.

## Overview

The app includes 40+ carefully crafted Halloween prompts organized into 11 categories:

- **Costume** (10 prompts) - Transform yourself into classic Halloween characters
- **Makeup** (4 prompts) - Apply stunning makeup effects
- **Scene** (4 prompts) - Place yourself in spooky settings
- **Group** (1 prompt) - Group photo transformations
- **Pets** (1 prompt) - Halloween pet costumes
- **Cute** (4 prompts) - Family-friendly Halloween scenes
- **Cinematic** (3 prompts) - Movie-quality atmospheric shots
- **Stylized** (5 prompts) - Artistic interpretations
- **Product** (3 prompts) - Product photography
- **Design** (3 prompts) - Graphics and patterns
- **Couples** (2 prompts) - Couple costume ideas

## Quick Start

### 1. Browse Prompts

```dart
import 'package:spook_edit/services/prompt_manager.dart';

// Initialize the prompt manager
final promptManager = PromptManager();
await promptManager.loadPrompts();

// Get all prompts
final allPrompts = promptManager.allPrompts;

// Get prompts by category
final costumePrompts = promptManager.getByCategory('Costume');
```

### 2. Navigate to Prompt Browser

```dart
Navigator.pushNamed(context, AppConstants.promptBrowserRoute);
```

Or with direct import:

```dart
import 'package:spook_edit/views/prompts/prompt_browser_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const PromptBrowserScreen()),
);
```

### 3. Generate Image from Prompt

```dart
import 'package:spook_edit/services/nano_banana_service.dart';
import 'package:spook_edit/services/prompt_manager.dart';
import 'package:spook_edit/utils/app_constants.dart';

// Get a prompt
final promptManager = PromptManager();
await promptManager.loadPrompts();
final prompt = promptManager.getById(1); // Classic Vampire

// Generate image
final service = NanoBananaService(apiKey: AppConstants.falApiKey);
final response = await service.generateImage(
  prompt: prompt!.prompt,
  aspectRatio: AspectRatio.square,
);

final imageUrl = response.images.first.url;
```

## Prompt Manager API

### Load Prompts

```dart
final manager = PromptManager();

// Load from default location
await manager.loadPrompts();

// Load from custom path
await manager.loadPrompts(path: 'assets/data/custom_prompts.json');

// Reload (refresh)
await manager.reload();
```

### Filter & Search

```dart
// Get by category
final vampirePrompts = manager.getByCategory('Costume');

// Search
final searchResults = manager.search('vampire');

// Get all categories
final categories = manager.categories;

// Get category counts
final counts = manager.categoryCounts;
// Returns: {'Costume': 10, 'Makeup': 4, ...}
```

### Random Selection

```dart
// Get random prompt from all
final random = manager.getRandomPrompt();

// Get random from specific category
final randomCostume = manager.getRandomPrompt(category: 'Costume');
```

### Grouping

```dart
// Get all prompts grouped by category
final grouped = manager.promptsByCategory;
// Returns: {'Costume': [prompt1, prompt2, ...], 'Makeup': [...], ...}

// Get featured prompts (first 6)
final featured = manager.featuredPrompts;

// Get popular categories
final popular = manager.popularCategories;
```

## Using the Prompt Browser UI

The `PromptBrowserScreen` provides a full-featured UI for browsing and using prompts:

### Features

1. **Search Bar** - Search prompts by title, category, or content
2. **Category Filter** - Filter by specific categories
3. **Grid View** - Visual cards for each prompt
4. **Detail Sheet** - Bottom sheet with full prompt details
5. **Aspect Ratio Selector** - Choose output dimensions
6. **Generate Button** - One-tap image generation
7. **Random Prompt** - Shuffle button for inspiration

### Example Usage

```dart
// Navigate to prompt browser
Navigator.pushNamed(context, AppConstants.promptBrowserRoute);

// Or with parameters
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PromptBrowserScreen(),
  ),
);
```

### Customizing the Browser

You can extend the browser with custom features:

```dart
class CustomPromptBrowser extends PromptBrowserScreen {
  // Add your customizations
}
```

## Sample Prompts

### Classic Vampire (Costume)
```
Turn this photo into a classic vampire portrait at night; pale makeup,
subtle fangs, satin cape; preserve my identity and hair; keep background
as a foggy graveyard extension of the original; cinematic contrast; no gore.
```

### Glam Cat (Makeup)
```
Apply glam Halloween cat makeup: black liner extending to whisker dots,
soft smoky eye, glossy nude lip; keep skin texture; no plastic look.
```

### Haunted Library (Scene)
```
Place me in a haunted library: towering shelves, floating books, cool
moonbeam through window; match my original lighting on face; light fog
at ankles.
```

## Integration with Nanobana API

### Basic Generation

```dart
import 'package:spook_edit/models/nanobana_models.dart' as nb;

final service = NanoBananaService(apiKey: AppConstants.falApiKey);
final prompt = promptManager.getById(5); // Pumpkin Trick-or-Treater

final response = await service.generateImage(
  prompt: prompt!.prompt,
  aspectRatio: nb.AspectRatio.square,
  outputFormat: nb.OutputFormat.jpeg,
);
```

### With Queue Updates

```dart
String status = '';

final response = await service.generateImage(
  prompt: prompt.prompt,
  onQueueUpdate: (update) {
    status = update.status;
    print('Queue status: $status');
    if (update.queuePosition != null) {
      print('Position: ${update.queuePosition}');
    }
  },
);
```

### Batch Generation

```dart
// Generate multiple prompts in parallel
final futures = <Future<NanoBananaResponse>>[];

for (var prompt in promptManager.featuredPrompts) {
  futures.add(
    service.generateImage(prompt: prompt.prompt),
  );
}

final results = await Future.wait(futures);
```

## Creating Custom Prompts

### Format

```json
{
  "id": 41,
  "category": "Custom",
  "title": "My Custom Prompt",
  "prompt": "Detailed description of the desired image..."
}
```

### Adding Custom Prompts

1. Edit `assets/data/halloween_prompts.json`
2. Add your prompt following the format above
3. Reload the app or call `manager.reload()`

### Prompt Writing Tips

1. **Be Specific** - Include details about lighting, style, mood
2. **Preserve Identity** - Add "keep my face", "preserve identity"
3. **Set Boundaries** - Use "no gore", "tasteful", "family-friendly"
4. **Include Style Keywords** - "cinematic", "editorial", "vintage"
5. **Specify Composition** - "close-up", "full body", "portrait"

Example:
```
Transform me into [CHARACTER]: [details about costume/appearance];
[lighting instructions]; preserve my identity; [background description];
[mood/style]; [safety boundaries].
```

## Advanced Usage

### Custom Prompt Manager

```dart
class CustomPromptManager extends PromptManager {
  // Add favorites
  List<int> favorites = [];

  List<HalloweenPrompt> getFavorites() {
    return allPrompts.where((p) => favorites.contains(p.id)).toList();
  }

  void toggleFavorite(int id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }
  }
}
```

### Prompt History

```dart
class PromptHistory {
  static final List<int> _history = [];

  static void addToHistory(int promptId) {
    _history.insert(0, promptId);
    if (_history.length > 10) _history.removeLast();
  }

  static List<HalloweenPrompt> getHistory(PromptManager manager) {
    return _history
        .map((id) => manager.getById(id))
        .whereType<HalloweenPrompt>()
        .toList();
  }
}
```

## Testing

### Test the Prompt Manager

```dart
void main() async {
  final manager = PromptManager();
  await manager.loadPrompts();

  print('Total prompts: ${manager.allPrompts.length}');
  print('Categories: ${manager.categories.join(', ')}');
  print('Random prompt: ${manager.getRandomPrompt()?.title}');
}
```

### Test Prompt Browser

Navigate to the test route:

```dart
Navigator.pushNamed(context, AppConstants.promptBrowserRoute);
```

## Troubleshooting

### Prompts Not Loading
- Ensure `assets/data/halloween_prompts.json` exists
- Check `pubspec.yaml` includes `assets/data/` in assets
- Run `flutter pub get` after adding assets

### Empty Results
- Call `await manager.loadPrompts()` before accessing prompts
- Check console for loading errors

### JSON Parse Error
- Validate JSON format at jsonlint.com
- Ensure all fields match the HalloweenPrompt model

## Best Practices

1. **Load Once** - Load prompts at app startup
2. **Cache Results** - Use the singleton PromptManager instance
3. **Error Handling** - Wrap API calls in try-catch blocks
4. **User Feedback** - Show loading states during generation
5. **Respect Limits** - Check API usage and implement rate limiting

## Resources

- [Nanobana API Docs](https://fal.ai/models/fal-ai/nano-banana)
- [Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [SpookEdit GitHub](https://github.com/your-repo)
