import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_card.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = ref.read(notesFilterProvider);
    _searchController.text = filter.query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, Note note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteNote),
        content: Text(l10n.deleteNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.nonVegRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(notesControllerProvider.notifier).deleteNote(note.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.noteDeletedSuccess),
                    backgroundColor: AppColors.nonVegRed,
                  ),
                );
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(filteredNotesProvider);
    final filterState = ref.watch(notesFilterProvider);
    final filterNotifier = ref.read(notesFilterProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('📝 ${l10n.myNotes}'),
        actions: [
          // Sort Options Menu
          PopupMenuButton<NotesSortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: l10n.sortNotes,
            onSelected: (option) => filterNotifier.setSortOption(option),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: NotesSortOption.pinnedFirst,
                child: Row(
                  children: [
                    Icon(Icons.push_pin_rounded, size: 18, color: filterState.sortOption == NotesSortOption.pinnedFirst ? AppColors.primaryOrange : null),
                    const SizedBox(width: 8),
                    Text(l10n.sortPinned),
                  ],
                ),
              ),
              PopupMenuItem(
                value: NotesSortOption.newestFirst,
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, size: 18, color: filterState.sortOption == NotesSortOption.newestFirst ? AppColors.primaryOrange : null),
                    const SizedBox(width: 8),
                    Text(l10n.sortNewest),
                  ],
                ),
              ),
              PopupMenuItem(
                value: NotesSortOption.oldestFirst,
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 18, color: filterState.sortOption == NotesSortOption.oldestFirst ? AppColors.primaryOrange : null),
                    const SizedBox(width: 8),
                    Text(l10n.sortOldest),
                  ],
                ),
              ),
              PopupMenuItem(
                value: NotesSortOption.alphabetical,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha_rounded, size: 18, color: filterState.sortOption == NotesSortOption.alphabetical ? AppColors.primaryOrange : null),
                    const SizedBox(width: 8),
                    Text(l10n.sortAlpha),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Subtitle Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.notesSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchNotesHint,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryOrange),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          filterNotifier.setQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (val) => filterNotifier.setQuery(val),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Segmented Tabs (All, Pinned, Favorites)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTabButton(
                  title: l10n.allNotes,
                  isSelected: filterState.activeTab == NotesTab.all,
                  onTap: () => filterNotifier.setActiveTab(NotesTab.all),
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  title: '📌 ${l10n.pinned}',
                  isSelected: filterState.activeTab == NotesTab.pinned,
                  onTap: () => filterNotifier.setActiveTab(NotesTab.pinned),
                ),
                const SizedBox(width: 8),
                _buildTabButton(
                  title: '❤️ ${l10n.favorites}',
                  isSelected: filterState.activeTab == NotesTab.favorites,
                  onTap: () => filterNotifier.setActiveTab(NotesTab.favorites),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.categoryAll),
                  selected: filterState.selectedCategory == null,
                  selectedColor: AppColors.primaryOrange,
                  backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: filterState.selectedCategory == null ? FontWeight.w800 : FontWeight.w500,
                    color: filterState.selectedCategory == null
                        ? Colors.white
                        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                  ),
                  side: BorderSide(
                    color: filterState.selectedCategory == null
                        ? AppColors.primaryOrange
                        : (isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                  onSelected: (_) => filterNotifier.setSelectedCategory(null),
                ),
                ...NoteCategory.allCategories.map((cat) {
                  final isSelected = filterState.selectedCategory == cat;
                  final catLabel = NoteCategory.getLocalizedName(cat, l10n);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ChoiceChip(
                      label: Text(catLabel),
                      selected: isSelected,
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : (isDark ? AppColors.border : AppColors.lightBorder),
                      ),
                      onSelected: (_) => filterNotifier.setSelectedCategory(isSelected ? null : cat),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Notes List / Grid
          Expanded(
            child: notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.note_alt_outlined,
                    title: l10n.noNotesTitle,
                    description: l10n.noNotesDesc,
                    actionLabel: l10n.createFirstNote,
                    onAction: () => context.pushNamed(RouteNames.noteCreate),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 80 + MediaQuery.paddingOf(context).bottom),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return NoteCard(
                      note: note,
                      onTap: () {
                        context.pushNamed(
                          RouteNames.noteDetail,
                          pathParameters: {'id': note.id},
                        );
                      },
                      onEdit: () {
                        context.pushNamed(
                          RouteNames.noteEdit,
                          pathParameters: {'id': note.id},
                          extra: note,
                        );
                      },
                      onDelete: () => _showDeleteDialog(context, note),
                      onTogglePin: () => ref.read(notesControllerProvider.notifier).togglePin(note.id),
                      onToggleFavorite: () => ref.read(notesControllerProvider.notifier).toggleFavorite(note.id),
                    );
                  },
                );
              },
              loading: () => const AppLoadingIndicator(),
              error: (err, _) => Center(child: Text('Error loading notes: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.noteCreate),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addNote, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryOrange.withValues(alpha: 0.15)
                : (isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryOrange
                  : (isDark ? AppColors.border : AppColors.lightBorder),
              width: isSelected ? 1.4 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryOrange
                    : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
