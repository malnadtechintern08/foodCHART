import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/faq_item.dart';
import '../providers/support_providers.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'General',
    'Recipes & Cooking',
    'Submissions',
    'Dietary & Health',
    'App & Account',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryArg = _selectedCategory == 'All' ? null : _selectedCategory;
    final faqsAsync = ref.watch(faqsProvider(categoryArg));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Help & FAQs',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh FAQs',
            onPressed: () => ref.invalidate(faqsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(faqsProvider),
        child: Column(
          children: [
            // Search Input Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              color: isDark ? AppColors.darkBackground : Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search questions, cooking tips, timers...',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: isDark ? Colors.white38 : AppColors.lightTextMuted,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Filter Chips
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                          labelStyle: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                          ),
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.border : AppColors.lightBorder),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: isDark ? AppColors.border : AppColors.lightBorder),

            // FAQ Accordion List
            Expanded(
              child: faqsAsync.when(
                data: (allFaqs) {
                  final filtered = allFaqs.where((f) {
                    if (_searchQuery.isEmpty) return true;
                    return f.question.toLowerCase().contains(_searchQuery) ||
                        f.answer.toLowerCase().contains(_searchQuery) ||
                        f.category.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(40),
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 36),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No Questions Found',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try searching for something else or contact our support team.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: isDark ? Colors.white60 : AppColors.lightTextMuted, fontSize: 13),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => context.pushNamed(RouteNames.contactUs),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Contact Support'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 32 + MediaQuery.paddingOf(context).bottom),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return _buildFooterContactCard(context, isDark);
                      }
                      final faq = filtered[index];
                      return _buildFaqTile(faq, isDark);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading FAQs: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(FaqItem faq, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.question_mark_rounded, color: AppColors.primary, size: 16),
          ),
          title: Text(
            faq.question,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              faq.category,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Text(
                faq.answer,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterContactCard(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF141414)]
              : [Colors.white, const Color(0xFFFFF6F4)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent_rounded, size: 36, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text(
            'Still Have Questions?',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Can\'t find what you\'re looking for? Reach out to our culinary support team.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white60 : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => context.pushNamed(RouteNames.contactUs),
            icon: const Icon(Icons.email_outlined, size: 16),
            label: const Text('Contact Support Desk'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
