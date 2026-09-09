import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_language.dart';
import '../localization/language_provider.dart';
import '../theme/app_colors.dart';

class LanguageSelectorModal extends ConsumerWidget {
  const LanguageSelectorModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const LanguageSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.border : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ • भाषा चुनें',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Language Options List
          ...AppLanguage.values.map((lang) {
            final isSelected = currentLanguage == lang;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryOrange.withValues(alpha: isDark ? 0.18 : 0.1)
                    : (isDark ? AppColors.surface : AppColors.lightBackground),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : (isDark ? AppColors.border : AppColors.lightBorder),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onTap: () {
                  ref.read(languageProvider.notifier).setLanguage(lang);
                  Navigator.of(context).pop();
                },
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : (isDark ? AppColors.cardBackground : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : (isDark ? AppColors.border : AppColors.lightBorder),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      lang.nativeName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryOrange
                            : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                    if (lang != AppLanguage.en) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${lang.englishName})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : (isDark ? AppColors.border : AppColors.lightBorder),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
