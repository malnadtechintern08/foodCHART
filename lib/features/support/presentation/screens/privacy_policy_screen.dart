import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/support_providers.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageAsync = ref.watch(supportPageProvider('privacy-policy'));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Policy',
            onPressed: () => ref.invalidate(supportPageProvider('privacy-policy')),
          ),
        ],
      ),
      body: pageAsync.when(
        data: (page) {
          final version = page.meta['version'] ?? '2.1';
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(supportPageProvider('privacy-policy')),
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
                          : [Colors.white, const Color(0xFFFFF7F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 28),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Version $version',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        page.summary.isNotEmpty
                            ? page.summary
                            : 'Understand how Food CHART protects, respects, and secures your culinary and device data.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Key Guarantees Chips
                Row(
                  children: [
                    Expanded(
                      child: _buildBadgeCard(
                        context,
                        icon: Icons.cloud_off_rounded,
                        label: 'Offline First',
                        sub: 'Local storage only',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBadgeCard(
                        context,
                        icon: Icons.no_accounts_rounded,
                        label: 'Zero Ads',
                        sub: 'No data selling',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBadgeCard(
                        context,
                        icon: Icons.lock_outline_rounded,
                        label: 'Encrypted',
                        sub: 'TLS 1.3 in-transit',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Render Sections
                ..._buildParsedContent(page.content, isDark),

                const SizedBox(height: 24),

                // Contact Privacy Team Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardBackground : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Have Privacy Questions?',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(
                              'Reach out directly to our support desk.',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AppColors.lightTextMuted),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.pushNamed(RouteNames.contactUs),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load Privacy Policy: $err'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(supportPageProvider('privacy-policy')),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sub,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10.5,
              color: isDark ? Colors.white60 : AppColors.lightTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParsedContent(String rawContent, bool isDark) {
    final lines = rawContent.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (trimmed.startsWith('# ')) {
        // Skip title as it's in the banner
        continue;
      } else if (trimmed.startsWith('### ')) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(
          Text(
            trimmed.substring(4),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 6));
      } else if (trimmed.startsWith('---')) {
        widgets.add(
          Divider(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            height: 24,
          ),
        );
      } else if (trimmed.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    trimmed.substring(2).replaceAll('**', ''),
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Text(
            trimmed.replaceAll('**', ''),
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
