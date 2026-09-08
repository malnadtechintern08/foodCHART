import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/support_providers.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageAsync = ref.watch(supportPageProvider('help-center'));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Help Center & Guides',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Guides',
            onPressed: () => ref.invalidate(supportPageProvider('help-center')),
          ),
        ],
      ),
      body: pageAsync.when(
        data: (page) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(supportPageProvider('help-center')),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header Search & Hero
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
                            child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'User Guides & Help Center',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.summary.isNotEmpty
                            ? page.summary
                            : 'Learn how to master every culinary feature in Food CHART, from smart filters to recipe moderation.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Action Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickLinkCard(
                        context,
                        icon: Icons.question_answer_rounded,
                        title: 'Browse FAQs',
                        sub: 'Common questions answered',
                        color: const Color(0xFF2196F3),
                        onTap: () => context.pushNamed(RouteNames.faq),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickLinkCard(
                        context,
                        icon: Icons.contact_support_rounded,
                        title: 'Contact Support',
                        sub: 'Talk with our team',
                        color: AppColors.primary,
                        onTap: () => context.pushNamed(RouteNames.contactUs),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Guide Sections
                const Text(
                  'STEP-BY-STEP GUIDES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),

                _buildGuideCard(
                  icon: Icons.search_rounded,
                  title: '1. Discovering & Filtering Recipes',
                  description:
                      'Explore authentic heritage categories (Malnad, Breakfast, Lunch/Dinner, Snacks, Healthy). Filter seamlessly by Pure Veg / Non-Veg, prep time under 30 mins, and tap hashtags like #MalnadSpecial to find themed dishes.',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                _buildGuideCard(
                  icon: Icons.timer_outlined,
                  title: '2. Interactive Cooking Mode & Timers',
                  description:
                      'Open any recipe and tap "Start Cooking Mode". Enjoy high-contrast step views with active countdown timers for boiling, steaming, and simmering so your dishes come out consistently perfect.',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                _buildGuideCard(
                  icon: Icons.shopping_cart_outlined,
                  title: '3. Smart Shopping List & Servings',
                  description:
                      'Scale ingredients dynamically by tapping + or - next to Servings. Add missing items to your shopping list with a single tap, check off groceries while shopping, and clear items when finished.',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                _buildGuideCard(
                  icon: Icons.add_circle_outline_rounded,
                  title: '4. Submitting Your Own Recipes',
                  description:
                      'Share your secret family recipes with the Food CHART community! Fill out the submission form with preparation times, ingredients, instructions, and dish photos. Track review status under "My Submissions".',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),

                _buildGuideCard(
                  icon: Icons.wifi_off_rounded,
                  title: '5. Offline First Experience',
                  description:
                      'Food CHART is designed to work in kitchens with weak or no Wi-Fi. Recipes, notes, and timers are saved locally on your phone. Whenever you reconnect, tap sync to fetch newly approved recipes.',
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
          child: Text('Error loading Help Center: $err'),
        ),
      ),
    );
  }

  Widget _buildQuickLinkCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String sub,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.white54 : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
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
