import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/halloween_prompt.dart';
import '../../utils/app_constants.dart';

/// Widget for selecting Halloween creative prompts
class PromptSelector extends StatefulWidget {
  final Function(HalloweenPrompt) onPromptSelected;
  final HalloweenPrompt? selectedPrompt;

  const PromptSelector({
    super.key,
    required this.onPromptSelected,
    this.selectedPrompt,
  });

  @override
  State<PromptSelector> createState() => _PromptSelectorState();
}

class _PromptSelectorState extends State<PromptSelector> {
  String? _selectedCategory;
  final List<String> _categories = HalloweenPromptsRepository.getCategories();

  @override
  void initState() {
    super.initState();
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category tabs
        _buildCategoryTabs(),
        const SizedBox(height: 12),
        // Prompts list
        Expanded(
          child: _buildPromptsList(),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.primaryOrange
                    : AppConstants.primaryPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppConstants.primaryOrange
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromptsList() {
    if (_selectedCategory == null) {
      return Center(
        child: Text(
          'No prompts available',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppConstants.ghostWhite.withOpacity(0.6),
          ),
        ),
      );
    }

    final prompts =
        HalloweenPromptsRepository.getPromptsByCategory(_selectedCategory!);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        final isSelected = widget.selectedPrompt?.id == prompt.id;

        return _buildPromptCard(prompt, isSelected);
      },
    );
  }

  Widget _buildPromptCard(HalloweenPrompt prompt, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onPromptSelected(prompt),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppConstants.primaryOrange.withOpacity(0.6),
                    AppConstants.primaryPurple.withOpacity(0.6),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : AppConstants.primaryPurple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryOrange
                : AppConstants.primaryOrange.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryOrange.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    prompt.title,
                    style: GoogleFonts.creepster(
                      fontSize: 18,
                      color: AppConstants.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppConstants.primaryOrange,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              prompt.prompt,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppConstants.ghostWhite.withOpacity(0.8),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: prompt.qualityTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConstants.primaryOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppConstants.primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
