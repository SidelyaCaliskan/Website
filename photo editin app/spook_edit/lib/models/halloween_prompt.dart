/// Model for Halloween-themed AI generation prompts
class HalloweenPrompt {
  final int id;
  final String category;
  final String title;
  final String prompt;
  final String negativePrompt;
  final List<String> qualityTags;

  const HalloweenPrompt({
    required this.id,
    required this.category,
    required this.title,
    required this.prompt,
    this.negativePrompt = '',
    this.qualityTags = const [],
  });

  /// Get full prompt with quality tags
  String get fullPrompt {
    if (qualityTags.isEmpty) return prompt;
    final tags = qualityTags.join(', ');
    return '$prompt Quality: $tags';
  }

  /// Create from JSON
  factory HalloweenPrompt.fromJson(Map<String, dynamic> json) {
    return HalloweenPrompt(
      id: json['id'] as int,
      category: json['category'] as String,
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      negativePrompt: json['negative_prompt'] as String? ?? '',
      qualityTags: (json['quality_tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'prompt': prompt,
      'negative_prompt': negativePrompt,
      'quality_tags': qualityTags,
    };
  }

  HalloweenPrompt copyWith({
    int? id,
    String? category,
    String? title,
    String? prompt,
    String? negativePrompt,
    List<String>? qualityTags,
  }) {
    return HalloweenPrompt(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      qualityTags: qualityTags ?? this.qualityTags,
    );
  }

  @override
  String toString() => 'HalloweenPrompt(id: $id, category: $category, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HalloweenPrompt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Available prompt categories
enum PromptCategory {
  costume('Costume', '🎭'),
  makeup('Makeup', '💄'),
  scene('Scene', '🏚️'),
  group('Group', '👥'),
  pets('Pets', '🐾'),
  cute('Cute', '🥰'),
  cinematic('Cinematic', '🎬'),
  stylized('Stylized', '🎨'),
  product('Product', '📦'),
  design('Design', '✨'),
  couples('Couples', '💑'),
  seductiveGlamour('Seductive Glamour', '💃'),
  coolCinematic('Cool Cinematic', '😎'),
  playfulCuteSexy('Playful Cute Sexy', '😘'),
  luxuryGoddessEnergy('Luxury Goddess Energy', '👑');

  final String name;
  final String emoji;

  const PromptCategory(this.name, this.emoji);

  /// Get display name with emoji
  String get displayName => '$emoji $name';

  /// Create from string
  static PromptCategory? fromString(String value) {
    try {
      return PromptCategory.values.firstWhere(
        (cat) => cat.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

/// Repository for Halloween prompts
class HalloweenPromptsRepository {
  static final List<HalloweenPrompt> _prompts = [
    // Seductive Glamour
    HalloweenPrompt(
      id: 41,
      category: 'Seductive Glamour',
      title: 'Dark Angel',
      prompt: 'Transform me into a dark angel with glossy black wings, silver halo, shimmering black dress, smoky eyes, cinematic backlight through fog; confident pose; tasteful sensual aura; preserve identity.',
      negativePrompt: 'no nudity, no gore, no explicit clothing, no violent themes',
      qualityTags: ['cinematic lighting', 'soft volumetric fog', 'vogue editorial', 'sharp focus'],
    ),
    HalloweenPrompt(
      id: 42,
      category: 'Seductive Glamour',
      title: 'Vampire Queen',
      prompt: 'Make me a powerful vampire queen sitting on a gothic throne, red velvet gown, deep lipstick, candlelight glow; elegant not horror; confident and alluring; keep my identity and lighting consistency.',
      negativePrompt: 'no blood, no gore, no cleavage focus, no violence',
      qualityTags: ['cinematic rim-light', 'baroque textures', 'high contrast', 'sharp focus'],
    ),
    HalloweenPrompt(
      id: 43,
      category: 'Seductive Glamour',
      title: 'Black Lace Witch',
      prompt: 'Stylize me as a modern black-lace witch; corset-inspired outfit with sheer layers, candle-lit background, smoky shadows, alluring eyes, poised stance; no exposure; maintain elegance.',
      negativePrompt: 'no explicit content, no nudity',
      qualityTags: ['moody lighting', 'portrait depth', 'luxury styling'],
    ),

    // Cool Cinematic
    HalloweenPrompt(
      id: 44,
      category: 'Cool Cinematic',
      title: 'Neon Cyber Witch',
      prompt: 'Turn me into a cyberpunk witch under neon lights; leather jacket, glowing runes, holographic broom, city skyline background; strong pose, cinematic camera angle.',
      negativePrompt: 'no weapons, no violence, no nudity',
      qualityTags: ['neon lighting', 'cyberpunk atmosphere', 'dynamic pose'],
    ),
    HalloweenPrompt(
      id: 45,
      category: 'Cool Cinematic',
      title: 'Shadow Huntress',
      prompt: 'Portray me as a mysterious Halloween huntress: dark bodysuit, long coat, silver moonlight reflecting off metallic details; wind in hair; eyes glowing faintly; strong feminine energy.',
      negativePrompt: 'no gore, no weapon focus, no explicit attire',
      qualityTags: ['moonlight', 'fog effects', 'cinematic realism'],
    ),

    // Playful Cute Sexy
    HalloweenPrompt(
      id: 46,
      category: 'Playful Cute Sexy',
      title: 'Flirty Cat',
      prompt: 'Cute and confident cat costume: silky ears, winged eyeliner, glossy lips, playful expression, warm fairy lights background, soft-focus bokeh; glamour portrait style.',
      negativePrompt: 'no nudity, no cleavage, no exaggerated anatomy',
      qualityTags: ['beauty lighting', 'soft focus', 'studio setup'],
    ),
    HalloweenPrompt(
      id: 47,
      category: 'Playful Cute Sexy',
      title: 'Sparkly Devil',
      prompt: 'Fun and stylish devil costume: glittery red horns, sequin mini-dress, red backlight, confident pose, high-fashion mood, studio photo aesthetic.',
      negativePrompt: 'no explicit content, no gore',
      qualityTags: ['fashion lighting', 'red gel light', 'studio portrait'],
    ),

    // Luxury Goddess Energy
    HalloweenPrompt(
      id: 48,
      category: 'Luxury Goddess Energy',
      title: 'Golden Goddess',
      prompt: 'Render me as a golden goddess of Halloween night; glowing golden gown, radiant aura, flowing hair, subtle crown, surrounded by candlelight; divine feminine energy; elegant and warm.',
      negativePrompt: 'no explicit clothing, no religious iconography misuse',
      qualityTags: ['golden light', 'soft diffusion', 'divine aura'],
    ),
    HalloweenPrompt(
      id: 49,
      category: 'Luxury Goddess Energy',
      title: 'Moon Priestess',
      prompt: 'Make me a celestial moon priestess; shimmering silver gown, lunar halo, starlight particles, serene face, long flowing cape; fantasy editorial look.',
      negativePrompt: 'no exposure, no violence',
      qualityTags: ['ethereal glow', 'cool tones', 'fine detail'],
    ),
    HalloweenPrompt(
      id: 50,
      category: 'Luxury Goddess Energy',
      title: 'Midnight Empress',
      prompt: 'Midnight empress aesthetic: jewel-encrusted crown, flowing velvet dress, candlelit ballroom background, confident and magnetic aura; timeless glamour; cinematic composition.',
      negativePrompt: 'no gore, no nudity, no religious symbols',
      qualityTags: ['cinematic', 'baroque lighting', 'luxury fashion'],
    ),
  ];

  /// Get all prompts
  static List<HalloweenPrompt> getAllPrompts() => List.unmodifiable(_prompts);

  /// Get prompts by category
  static List<HalloweenPrompt> getPromptsByCategory(String category) {
    return _prompts.where((p) => p.category == category).toList();
  }

  /// Get all unique categories
  static List<String> getCategories() {
    return _prompts.map((p) => p.category).toSet().toList();
  }

  /// Get prompt by ID
  static HalloweenPrompt? getPromptById(int id) {
    try {
      return _prompts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search prompts by title or category
  static List<HalloweenPrompt> searchPrompts(String query) {
    final lowerQuery = query.toLowerCase();
    return _prompts.where((p) {
      return p.title.toLowerCase().contains(lowerQuery) ||
          p.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
