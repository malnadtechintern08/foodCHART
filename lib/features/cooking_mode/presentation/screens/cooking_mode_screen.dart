import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/recipe_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../rating/presentation/widgets/rating_popup_dialog.dart';
import '../../../rating/services/rating_service.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../providers/cooking_session_provider.dart';
import '../widgets/cooking_timer_widget.dart';

class CookingModeScreen extends ConsumerWidget {
  final Recipe recipe;

  const CookingModeScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionState = ref.watch(cookingSessionProvider(recipe));
    final sessionNotifier = ref.read(cookingSessionProvider(recipe).notifier);
    final l10n = AppLocalizations.of(context)!;

    if (sessionState.isFinished) {
      return _buildCelebrationScreen(context, isDark, l10n);
    }

    final currentStep = recipe.instructions.isNotEmpty
        ? recipe.instructions[sessionState.currentStepIndex]
        : null;
    final totalSteps = recipe.instructions.length;
    final currentStepNum = sessionState.currentStepIndex + 1;
    final isStepCompleted = sessionState.completedSteps.contains(sessionState.currentStepIndex);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
          tooltip: l10n.exit,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.stepOf(currentStepNum, totalSteps),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            Text(
              recipe.localizedTitle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              sessionNotifier.toggleStepCompletion(sessionState.currentStepIndex);
            },
            icon: Icon(
              isStepCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
              color: isStepCompleted ? AppColors.secondary : AppColors.lightTextMuted,
              size: 20,
            ),
            label: Text(
              isStepCompleted ? l10n.done : l10n.markDone,
              style: TextStyle(
                color: isStepCompleted ? AppColors.secondary : AppColors.lightTextMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: totalSteps > 0 ? (currentStepNum / totalSteps) : 0,
              minHeight: 4,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Number Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '#$currentStepNum',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Step Instruction Text
                    Text(
                      currentStep?.instruction ?? 'No instruction details.',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Integrated Step Timer Widget (if this step has duration)
                    if (currentStep != null && currentStep.hasTimer) ...[
                      CookingTimerWidget(
                        remainingSeconds: sessionState.remainingTimerSeconds,
                        initialSeconds: sessionState.initialTimerSeconds,
                        isRunning: sessionState.isTimerRunning,
                        onStart: sessionNotifier.startTimer,
                        onPause: sessionNotifier.pauseTimer,
                        onReset: sessionNotifier.resetTimer,
                        onAddSeconds: sessionNotifier.addTimerSeconds,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Step Quick Ingredients Reference
                    Text(
                      l10n.ingredients,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recipe.ingredients
                          .map((ing) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                  ),
                                ),
                                child: Text(
                                  '${ing.name} (${ing.amount} ${ing.unit})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Controls
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      if (sessionState.currentStepIndex > 0) ...[
                        OutlinedButton.icon(
                          onPressed: sessionNotifier.previousStep,
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: Text(l10n.previous),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final isFinishing = currentStepNum == totalSteps;
                            sessionNotifier.toggleStepCompletion(sessionState.currentStepIndex);
                            sessionNotifier.nextStep();
                            if (isFinishing) {
                              await RatingService.instance.recordMeaningfulAction();
                              if (context.mounted) {
                                Future.delayed(const Duration(milliseconds: 600), () {
                                  if (context.mounted) {
                                    showCookMateRatingPopup(context, isManual: false);
                                  }
                                });
                              }
                            }
                          },
                          icon: Icon(
                            currentStepNum == totalSteps ? Icons.celebration_rounded : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                          label: Text(
                            currentStepNum == totalSteps ? l10n.finishCooking : l10n.nextStep,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationScreen(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.bonAppetit,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.celebrationSub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.backToDetails),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
