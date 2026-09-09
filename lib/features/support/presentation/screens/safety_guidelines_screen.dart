import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/support_providers.dart';

class SafetyGuidelinesScreen extends ConsumerWidget {
  const SafetyGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageAsync = ref.watch(supportPageProvider('safety-guidelines'));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Safety & Guidelines',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Guidelines',
            onPressed: () => ref.invalidate(supportPageProvider('safety-guidelines')),
          ),
        ],
      ),
      body: pageAsync.when(
        data: (page) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(supportPageProvider('safety-guidelines')),
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 32 + MediaQuery.paddingOf(context).bottom),
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E1E1E), const Color(0xFF141414)]
                          : [Colors.white, const Color(0xFFFFF6F4)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 26),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Culinary Safety & Standards',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.summary.isNotEmpty
                            ? page.summary
                            : 'Essential kitchen hygiene rules, equipment handling, food allergen notices, and community submission ethics.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Allergen Alert Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Food Allergen Advisory',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.amber),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Many authentic regional recipes include tree nuts (cashews, almonds), dairy (ghee, paneer), mustard, or wheat gluten. Always verify recipe tags and check individual ingredients when cooking for allergy-sensitive guests.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? Colors.white70 : const Color(0xFF664D03),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: Food Hygiene
                _buildSectionHeader('1. FOOD HYGIENE & PREPARATION', Icons.clean_hands_rounded),
                const SizedBox(height: 12),
                _buildGuidelineCard(
                  title: 'Hand Hygiene',
                  desc: 'Wash hands with soap and water for at least 20 seconds before food prep, and immediately after touching raw poultry or fish.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildGuidelineCard(
                  title: 'Preventing Cross-Contamination',
                  desc: 'Use distinct color-coded chopping boards and knives for raw meats and fresh ready-to-eat vegetables.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildGuidelineCard(
                  title: 'Safe Cooking Temperatures',
                  desc: 'Ensure poultry, meats, and seafood reach safe internal temperatures before serving to eliminate harmful bacteria.',
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Section 2: Appliance Safety
                _buildSectionHeader('2. KITCHEN APPLIANCE & COOKWARE SAFETY', Icons.outdoor_grill_rounded),
                const SizedBox(height: 12),
                _buildGuidelineCard(
                  title: 'Pressure Cooker Protocol',
                  desc: 'Never force open a pressurized cooker. Clean the vent weight and safety valve thoroughly before and after every use.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildGuidelineCard(
                  title: 'Hot Oil & Deep Frying',
                  desc: 'Never leave hot oil unattended. Keep pan handles turned away from foot traffic. Never use water on oil fires.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildGuidelineCard(
                  title: 'Knife Safety & Grip',
                  desc: 'Use sharp knives on non-slip surfaces. A dull knife requires more pressure and is significantly more hazardous.',
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Section 3: Community Guidelines
                _buildSectionHeader('3. COMMUNITY SUBMISSION ETHICS', Icons.groups_rounded),
                const SizedBox(height: 12),
                _buildGuidelineCard(
                  title: 'Authenticity & Accurate Quantities',
                  desc: 'Provide realistic cooking durations and accurate ingredient units so fellow home cooks achieve delicious results.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildGuidelineCard(
                  title: 'Original Photography Only',
                  desc: 'Upload actual photos of food prepared in your own kitchen. Watermarked stock images or internet screenshots will be declined.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildGuidelineCard(
                  title: 'Respectful, Family-Friendly Content',
                  desc: 'Food CHART is an inclusive culinary sanctuary. Promotional ads, spam, and abusive language are strictly filtered.',
                  isDark: isDark,
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('Error loading Safety Guidelines: $err'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuidelineCard({
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.vegGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: AppColors.vegGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
