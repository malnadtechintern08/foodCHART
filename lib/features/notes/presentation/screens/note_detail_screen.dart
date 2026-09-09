import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/presentation/providers/recipe_providers.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NoteDetailScreen extends ConsumerWidget {
  final String noteId;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
  });

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Note note) {
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
                context.pop();
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
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteDetailProvider(noteId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return noteAsync.when(
      data: (note) {
        if (note == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppEmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.noNotesTitle,
              description: l10n.noNotesDesc,
            ),
          );
        }

        final catName = NoteCategory.getLocalizedName(note.category, l10n);
        final formattedDate = DateFormat('d MMM yyyy, h:mm a').format(note.createdAt);
        final formattedUpdated = DateFormat('d MMM yyyy, h:mm a').format(note.updatedAt);

        return Scaffold(
          appBar: AppBar(
            actions: [
              // Pin Action
              IconButton(
                icon: Icon(
                  note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  color: note.isPinned ? AppColors.primaryOrange : null,
                ),
                tooltip: note.isPinned ? l10n.unpin : l10n.pin,
                onPressed: () {
                  ref.read(notesControllerProvider.notifier).togglePin(note.id);
                },
              ),
              // Favorite Action
              IconButton(
                icon: Icon(
                  note.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: note.isFavorite ? AppColors.nonVegRed : null,
                ),
                tooltip: l10n.favorite,
                onPressed: () {
                  ref.read(notesControllerProvider.notifier).toggleFavorite(note.id);
                },
              ),
              // Edit Action
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.editNote,
                onPressed: () {
                  context.pushNamed(
                    RouteNames.noteEdit,
                    pathParameters: {'id': note.id},
                    extra: note,
                  );
                },
              ),
              // Delete Action
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.nonVegRed),
                tooltip: l10n.deleteNote,
                onPressed: () => _showDeleteDialog(context, ref, note),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Date Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        catName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note Title
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),

                // Tags
                if (note.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: note.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Connected Related Recipe Section (if any)
                if (note.hasRelatedRecipe) ...[
                  _buildRelatedRecipeSection(context, ref, note, isDark, l10n),
                  const SizedBox(height: 20),
                ],

                Divider(color: isDark ? AppColors.border : AppColors.lightBorder),
                const SizedBox(height: 16),

                // Note Full Content
                SelectableText(
                  note.content.isNotEmpty ? note.content : '(No content entered)',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),

                const SizedBox(height: 40),
                // Footer update timestamp
                Center(
                  child: Text(
                    'Last modified: $formattedUpdated',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const AppLoadingIndicator(),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildRelatedRecipeSection(
    BuildContext context,
    WidgetRef ref,
    Note note,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final recipeAsync = ref.watch(recipeDetailProvider(note.relatedRecipeId!));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryOrange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.relatedRecipe,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note.relatedRecipeTitle ?? (recipeAsync.value?.title ?? 'Recipe'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              side: const BorderSide(color: AppColors.primaryOrange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              context.pushNamed(
                RouteNames.recipeDetail,
                pathParameters: {'id': note.relatedRecipeId!},
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Open', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryOrange)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryOrange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
