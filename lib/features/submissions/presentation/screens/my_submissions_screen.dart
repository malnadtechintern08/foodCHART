import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/recipe_submission.dart';
import '../providers/submission_providers.dart';
import 'submit_recipe_screen.dart';

class MySubmissionsScreen extends ConsumerWidget {
  const MySubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final submissionsAsync = ref.watch(mySubmissionsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'My Recipe Submissions',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: () => ref.invalidate(mySubmissionsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/submit-recipe'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Submit Recipe', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inbox_outlined, color: AppColors.primary, size: 42),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Recipe Submissions Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share your authentic recipes with the Food CHART community! Submissions are reviewed by our team before publication.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/submit-recipe'),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Submit Your First Recipe', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mySubmissionsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: submissions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final sub = submissions[index];
                return _buildSubmissionCard(context, ref, sub);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Could not load submissions: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(mySubmissionsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, WidgetRef ref, RecipeSubmission sub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Status chip colors & icons
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (sub.status) {
      case SubmissionStatus.pending:
        statusColor = Colors.amber;
        statusBg = Colors.amber.withValues(alpha: 0.12);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case SubmissionStatus.underReview:
        statusColor = Colors.blue;
        statusBg = Colors.blue.withValues(alpha: 0.12);
        statusIcon = Icons.remove_red_eye_outlined;
        break;
      case SubmissionStatus.changesRequested:
        statusColor = Colors.orange;
        statusBg = Colors.orange.withValues(alpha: 0.12);
        statusIcon = Icons.rotate_left_rounded;
        break;
      case SubmissionStatus.approved:
        statusColor = Colors.green;
        statusBg = Colors.green.withValues(alpha: 0.12);
        statusIcon = Icons.check_circle_outline;
        break;
      case SubmissionStatus.published:
        statusColor = const Color(0xFF4CAF50);
        statusBg = const Color(0xFF4CAF50).withValues(alpha: 0.15);
        statusIcon = Icons.verified_rounded;
        break;
      case SubmissionStatus.rejected:
        statusColor = Colors.redAccent;
        statusBg = Colors.redAccent.withValues(alpha: 0.12);
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sub.hasChangesRequested
              ? Colors.orange.withValues(alpha: 0.5)
              : (isDark ? Colors.white12 : Colors.grey[200]!),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category, Time, and Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sub.categoryName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      sub.status.displayName,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Recipe Title
          Text(
            sub.recipeName,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),

          // Meta info
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 14, color: isDark ? Colors.white54 : Colors.black45),
                  const SizedBox(width: 4),
                  Text('${sub.totalTime} mins', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant, size: 14, color: isDark ? Colors.white54 : Colors.black45),
                  const SizedBox(width: 4),
                  Text('${sub.ingredientCount} ingredients', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              Text(
                sub.isVegetarian ? '🌱 Veg' : '🍗 Non-Veg',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sub.isVegetarian ? AppColors.veg : AppColors.nonVeg,
                ),
              ),
            ],
          ),

          // Hashtags row
          if (sub.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: sub.tags.take(4).map((t) {
                return Text(
                  '#$t',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ],

          // Admin Feedback if changes requested
          if (sub.hasChangesRequested && sub.adminNotes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.feedback_outlined, size: 16, color: Colors.orange),
                      SizedBox(width: 6),
                      Text('Admin Feedback:', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub.adminNotes!,
                    style: const TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          // Rejection reason if rejected
          if (sub.isRejected && sub.rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.redAccent),
                      SizedBox(width: 6),
                      Text('Moderation Decision:', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub.rejectionReason!,
                    style: const TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submitted: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),

              Row(
                children: [
                  // If Changes Requested, show Edit button
                  if (sub.hasChangesRequested)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SubmitRecipeScreen(editSubmissionId: sub.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 16),
                      label: const Text('Edit & Resubmit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                  // If Published, show View in Food CHART
                  if (sub.isPublished && sub.publishedRecipeId != null)
                    ElevatedButton.icon(
                      onPressed: () => context.push('/recipe/${sub.publishedRecipeId}'),
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: const Text('View in Food CHART', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.veg,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                  // If Pending, show Withdraw option
                  if (sub.isPending)
                    TextButton(
                      onPressed: () => _confirmWithdraw(context, ref, sub),
                      child: const Text('Withdraw', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmWithdraw(BuildContext context, WidgetRef ref, RecipeSubmission sub) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Submission?'),
        content: Text('Are you sure you want to withdraw "${sub.recipeName}"? It will be removed from review.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(submissionControllerProvider.notifier).withdrawSubmission(sub.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Submission withdrawn.' : 'Could not withdraw.')),
                );
              }
            },
            child: const Text('Yes, Withdraw', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
