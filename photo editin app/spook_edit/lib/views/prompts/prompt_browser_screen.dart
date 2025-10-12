import 'package:flutter/material.dart';
import '../../models/halloween_prompt.dart';
import '../../models/nanobana_models.dart' as nb;
import '../../services/prompt_manager.dart';
import '../../services/nano_banana_service.dart';
import '../../utils/app_constants.dart';

/// Screen for browsing and selecting Halloween prompts
class PromptBrowserScreen extends StatefulWidget {
  const PromptBrowserScreen({super.key});

  @override
  State<PromptBrowserScreen> createState() => _PromptBrowserScreenState();
}

class _PromptBrowserScreenState extends State<PromptBrowserScreen> {
  final PromptManager _promptManager = PromptManager();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCategory;
  List<HalloweenPrompt> _filteredPrompts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrompts() async {
    setState(() => _isLoading = true);

    try {
      if (!_promptManager.isLoaded) {
        await _promptManager.loadPrompts();
      }
      _updateFilteredPrompts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading prompts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateFilteredPrompts() {
    setState(() {
      if (_searchController.text.isNotEmpty) {
        _filteredPrompts = _promptManager.search(_searchController.text);
      } else if (_selectedCategory != null) {
        _filteredPrompts = _promptManager.getByCategory(_selectedCategory!);
      } else {
        _filteredPrompts = _promptManager.allPrompts;
      }
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _updateFilteredPrompts();
    });
  }

  void _onSearchChanged(String query) {
    _updateFilteredPrompts();
  }

  void _showPromptDetail(HalloweenPrompt prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PromptDetailSheet(prompt: prompt),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halloween Prompts'),
        backgroundColor: AppConstants.primaryPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () {
              final random = _promptManager.getRandomPrompt(
                category: _selectedCategory,
              );
              if (random != null) _showPromptDetail(random);
            },
            tooltip: 'Random Prompt',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.darkPurple,
              AppConstants.primaryPurple.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search prompts...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            _updateFilteredPrompts();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Category chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All', null),
                  ..._promptManager.categories.map((cat) {
                    return _buildCategoryChip(cat, cat);
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredPrompts.length} prompts',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  if (_selectedCategory != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_selectedCategory!),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _onCategorySelected(null),
                      backgroundColor: AppConstants.primaryOrange,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),

            // Prompts grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredPrompts.isEmpty
                      ? Center(
                          child: Text(
                            'No prompts found',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredPrompts.length,
                          itemBuilder: (context, index) {
                            final prompt = _filteredPrompts[index];
                            return _buildPromptCard(prompt);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? value) {
    final isSelected = _selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _onCategorySelected(value),
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: AppConstants.primaryOrange,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPromptCard(HalloweenPrompt prompt) {
    final category = PromptCategory.fromString(prompt.category);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.1),
      child: InkWell(
        onTap: () => _showPromptDetail(prompt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryOrange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  category?.emoji ?? '🎃',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                prompt.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),

              // Category text
              Text(
                prompt.category,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet showing prompt details and generation options
class PromptDetailSheet extends StatefulWidget {
  final HalloweenPrompt prompt;

  const PromptDetailSheet({super.key, required this.prompt});

  @override
  State<PromptDetailSheet> createState() => _PromptDetailSheetState();
}

class _PromptDetailSheetState extends State<PromptDetailSheet> {
  late NanoBananaService _service;
  bool _isGenerating = false;
  String? _statusMessage;
  String? _imageUrl;
  nb.AspectRatio _selectedAspectRatio = nb.AspectRatio.square;

  @override
  void initState() {
    super.initState();
    _service = NanoBananaService(apiKey: AppConstants.falApiKey);
  }

  Future<void> _generateImage() async {
    if (AppConstants.falApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your FAL_API_KEY in .env file'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _statusMessage = 'Submitting request...';
      _imageUrl = null;
    });

    try {
      final response = await _service.generateImage(
        prompt: widget.prompt.prompt,
        aspectRatio: _selectedAspectRatio,
        onQueueUpdate: (status) {
          if (mounted) {
            setState(() {
              _statusMessage = 'Status: ${status.status}';
              if (status.queuePosition != null) {
                _statusMessage = '$_statusMessage (Position: ${status.queuePosition})';
              }
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
          if (response.images.isNotEmpty) {
            _imageUrl = response.images.first.url;
            _statusMessage = 'Generated successfully!';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _statusMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = PromptCategory.fromString(widget.prompt.category);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppConstants.darkPurple,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${category?.emoji ?? '🎃'} ${widget.prompt.category}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        widget.prompt.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prompt text
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppConstants.primaryOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          widget.prompt.prompt,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Aspect ratio selector
                      const Text(
                        'Aspect Ratio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          nb.AspectRatio.square,
                          nb.AspectRatio.portrait916,
                          nb.AspectRatio.landscape169,
                        ].map((ratio) {
                          final isSelected = _selectedAspectRatio == ratio;
                          return ChoiceChip(
                            label: Text(ratio.value),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedAspectRatio = ratio);
                            },
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            selectedColor: AppConstants.primaryOrange,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Generate button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isGenerating ? null : _generateImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryOrange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isGenerating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Generate Image',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      // Status message
                      if (_statusMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryPurple.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _statusMessage!,
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      // Generated image
                      if (_imageUrl != null) ...[
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 300,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
