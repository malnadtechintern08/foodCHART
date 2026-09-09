import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/recipe_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../providers/recipe_providers.dart';

class RecipeFilterBottomSheet extends ConsumerStatefulWidget {
  const RecipeFilterBottomSheet({super.key});

  @override
  ConsumerState<RecipeFilterBottomSheet> createState() => _RecipeFilterBottomSheetState();
}

class _RecipeFilterBottomSheetState extends ConsumerState<RecipeFilterBottomSheet> {
  String? _selectedCategory;
  String? _selectedDifficulty;
  int? _selectedMaxTime;

  @override
  void initState() {
    super.initState();
    final current = ref.read(recipeFilterProvider);
    _selectedCategory = current.categoryId;
    _selectedDifficulty = current.difficulty;
    _selectedMaxTime = current.maxTimeMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);
    final l10n = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;

    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.paddingOf(context).bottom + MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Header Drag Handle & Title
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.filterRecipes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _selectedDifficulty = null;
                    _selectedMaxTime = null;
                  });
                },
                child: Text(l10n.reset, style: const TextStyle(color: AppColors.primaryOrange)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Difficulty Filter
          Text(l10n.difficultyLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChoiceChip(l10n.categoryAll, _selectedDifficulty == null, () {
                setState(() => _selectedDifficulty = null);
              }),
              _buildChoiceChip(l10n.easy, _selectedDifficulty == 'Easy', () {
                setState(() => _selectedDifficulty = 'Easy');
              }),
              _buildChoiceChip(l10n.medium, _selectedDifficulty == 'Medium', () {
                setState(() => _selectedDifficulty = 'Medium');
              }),
              _buildChoiceChip(l10n.hard, _selectedDifficulty == 'Hard', () {
                setState(() => _selectedDifficulty = 'Hard');
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Max Cooking Time Filter
          Text(l10n.maxTimeLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildChoiceChip(l10n.anyTime, _selectedMaxTime == null, () {
                setState(() => _selectedMaxTime = null);
              }),
              _buildChoiceChip(l10n.under15m, _selectedMaxTime == 15, () {
                setState(() => _selectedMaxTime = 15);
              }),
              _buildChoiceChip(l10n.under30m, _selectedMaxTime == 30, () {
                setState(() => _selectedMaxTime = 30);
              }),
              _buildChoiceChip(l10n.under60m, _selectedMaxTime == 60, () {
                setState(() => _selectedMaxTime = 60);
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Categories Filter
          Text(l10n.categoryLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          categoriesAsync.when(
            data: (categories) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChoiceChip(l10n.allCategories, _selectedCategory == null, () {
                  setState(() => _selectedCategory = null);
                }),
                ...categories.map((c) => _buildChoiceChip(
                      RecipeTranslations.getCategoryName(c.name, langCode),
                      _selectedCategory == c.id,
                      () => setState(() => _selectedCategory = c.id),
                    )),
              ],
            ),
            loading: () => const SizedBox(height: 20),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 28),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final notifier = ref.read(recipeFilterProvider.notifier);
                notifier.setCategory(_selectedCategory);
                notifier.setDifficulty(_selectedDifficulty);
                notifier.setMaxTime(_selectedMaxTime);
                Navigator.of(context).pop();
              },
              child: Text(l10n.applyFilters),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange
              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryOrange
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ),
    );
  }
}
