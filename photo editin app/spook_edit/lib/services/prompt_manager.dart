import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/halloween_prompt.dart';

/// Manages Halloween prompts from JSON asset
class PromptManager {
  static final PromptManager _instance = PromptManager._internal();
  factory PromptManager() => _instance;
  PromptManager._internal();

  List<HalloweenPrompt> _prompts = [];
  bool _isLoaded = false;

  /// Check if prompts are loaded
  bool get isLoaded => _isLoaded;

  /// Get all prompts
  List<HalloweenPrompt> get allPrompts => List.unmodifiable(_prompts);

  /// Get prompts by category
  List<HalloweenPrompt> getByCategory(String category) {
    return _prompts
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get all unique categories
  List<String> get categories {
    final cats = _prompts.map((p) => p.category).toSet().toList();
    cats.sort();
    return cats;
  }

  /// Get prompt by ID
  HalloweenPrompt? getById(int id) {
    try {
      return _prompts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search prompts by title or category
  List<HalloweenPrompt> search(String query) {
    final lowerQuery = query.toLowerCase();
    return _prompts.where((p) {
      return p.title.toLowerCase().contains(lowerQuery) ||
          p.category.toLowerCase().contains(lowerQuery) ||
          p.prompt.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Get random prompt
  HalloweenPrompt? getRandomPrompt({String? category}) {
    if (_prompts.isEmpty) return null;

    final filtered = category != null
        ? getByCategory(category)
        : _prompts;

    if (filtered.isEmpty) return null;

    filtered.shuffle();
    return filtered.first;
  }

  /// Get prompts grouped by category
  Map<String, List<HalloweenPrompt>> get promptsByCategory {
    final Map<String, List<HalloweenPrompt>> grouped = {};

    for (var prompt in _prompts) {
      grouped.putIfAbsent(prompt.category, () => []).add(prompt);
    }

    return grouped;
  }

  /// Count prompts in each category
  Map<String, int> get categoryCounts {
    final Map<String, int> counts = {};

    for (var prompt in _prompts) {
      counts[prompt.category] = (counts[prompt.category] ?? 0) + 1;
    }

    return counts;
  }

  /// Load prompts from JSON asset
  Future<void> loadPrompts({String path = 'assets/data/halloween_prompts.json'}) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final List<dynamic> jsonData = jsonDecode(jsonString);

      _prompts = jsonData
          .map((json) => HalloweenPrompt.fromJson(json as Map<String, dynamic>))
          .toList();

      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load prompts: $e');
    }
  }

  /// Reload prompts (useful for refreshing)
  Future<void> reload() async {
    _prompts.clear();
    _isLoaded = false;
    await loadPrompts();
  }

  /// Get featured/recommended prompts (first 6)
  List<HalloweenPrompt> get featuredPrompts {
    return _prompts.take(6).toList();
  }

  /// Get popular categories (categories with most prompts)
  List<String> get popularCategories {
    final counts = categoryCounts;
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toList();
  }
}
