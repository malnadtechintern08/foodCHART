import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../services/rating_service.dart';

/// Shows the Instagram-style rating popup for CookMate.
///
/// If [isManual] is true (e.g. triggered from Settings/Profile), the popup
/// opens unconditionally. If false, it checks whether the user has performed
/// sufficient meaningful actions and is not within a cooldown window.
Future<void> showCookMateRatingPopup(
  BuildContext context, {
  bool isManual = false,
  RatingService? ratingService,
  VoidCallback? onSendFeedback,
  void Function(int stars)? onSendFeedbackWithStars,
}) async {
  final service = ratingService ?? RatingService.instance;

  if (service.isDialogShowing) return;

  if (!isManual) {
    final shouldShow = await service.canShowAutomaticPopup(actionThreshold: 0, cooldownDays: 5);
    if (!shouldShow) return;
    await service.recordPopupShown();
  }

  if (!context.mounted) return;

  service.isDialogShowing = true;
  try {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Rating',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.88 + (0.12 * curvedValue),
          child: Opacity(
            opacity: anim1.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, anim1, anim2) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: RatingPopupDialog(
            ratingService: service,
            onSendFeedback: onSendFeedback,
            onSendFeedbackWithStars: onSendFeedbackWithStars ??
                (onSendFeedback == null
                    ? (stars) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            try {
                              context.pushNamed(
                                RouteNames.rateUs,
                                extra: {'stars': stars},
                              );
                            } catch (_) {}
                          }
                        });
                      }
                    : null),
          ),
        );
      },
    );
  } finally {
    service.isDialogShowing = false;
  }
}

class RatingPopupDialog extends StatefulWidget {
  const RatingPopupDialog({
    super.key,
    this.ratingService,
    this.onSendFeedback,
    this.onSendFeedbackWithStars,
  });

  final RatingService? ratingService;
  final VoidCallback? onSendFeedback;
  final void Function(int stars)? onSendFeedbackWithStars;

  @override
  State<RatingPopupDialog> createState() => _RatingPopupDialogState();
}

class _RatingPopupDialogState extends State<RatingPopupDialog> with SingleTickerProviderStateMixin {
  int _selectedStars = 0;
  bool _isProcessing = false;

  RatingService get _service => widget.ratingService ?? RatingService.instance;

  void _handleStarTap(int starIndex) {
    setState(() {
      _selectedStars = starIndex;
    });
  }

  Future<void> _handlePlayStoreRate() async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() => _isProcessing = true);
    await _service.recordRatingSubmitted(_selectedStars);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    final success = await _service.openPlayStoreReview();

    if (!success && messenger != null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open Play Store. Please try again later.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSendFeedback() async {
    setState(() => _isProcessing = true);
    await _service.recordRatingSubmitted(_selectedStars);

    final stars = _selectedStars;
    final feedbackCallback = widget.onSendFeedback;
    final starsCallback = widget.onSendFeedbackWithStars;

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (starsCallback != null) {
        starsCallback(stars);
      } else if (feedbackCallback != null) {
        feedbackCallback();
      } else if (mounted) {
        try {
          context.pushNamed(
            RouteNames.rateUs,
            extra: {'stars': stars},
          );
        } catch (_) {}
      }
    });
  }

  Future<void> _handleMaybeLater() async {
    await _service.recordDismissed();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard;
    final borderColor = isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final screenHeight = MediaQuery.sizeOf(context).height;
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: screenHeight * 0.85),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Close button & Brand Food Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                // CookMate Food Icon with soft glow
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.2),
                        Colors.amber.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '🍳',
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: subtitleColor,
                  ),
                  tooltip: 'Maybe Later',
                  onPressed: _handleMaybeLater,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              'Enjoying Food CHART? 🍳❤️',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              "We hope you're enjoying Food CHART. Your feedback helps us make the app better!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: subtitleColor,
              ),
            ),
            const SizedBox(height: 16),

            // Interactive 5 Stars
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final starNum = index + 1;
                    final isSelected = starNum <= _selectedStars;
                    return GestureDetector(
                      key: Key('star_$starNum'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _handleStarTap(starNum),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 34,
                            color: isSelected ? const Color(0xFFFFB300) : subtitleColor.withValues(alpha: 0.5),
                            shadows: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Dynamic Feedback Section & Buttons
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              transitionBuilder: (child, anim) {
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                );
              },
              child: _buildConditionalContent(context, isDark, textColor, subtitleColor),
            ),

            const SizedBox(height: 8),

            // Maybe Later Button
            TextButton(
              key: const Key('maybe_later_button'),
              onPressed: _isProcessing ? null : _handleMaybeLater,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                foregroundColor: subtitleColor,
              ),
              child: const Text(
                'Maybe Later',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildConditionalContent(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subtitleColor,
  ) {
    if (_selectedStars >= 4) {
      // 4 or 5 stars: Play Store flow
      return Column(
        key: const ValueKey('high_rating_content'),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.favorite_rounded, color: AppColors.primary, size: 16),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "We're glad you're enjoying Food CHART! ❤️",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.vegGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('rate_playstore_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isProcessing ? null : _handlePlayStoreRate,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.star_rounded, size: 20),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '⭐ Rate Food CHART on Play Store',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_selectedStars >= 1) {
      // 1, 2, or 3 stars: Feedback flow
      return Column(
        key: const ValueKey('low_rating_content'),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
            ),
            child: const Text(
              'Thanks for your feedback. Tell us how we can improve Food CHART.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF9800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 46),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('send_feedback_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.surface : AppColors.lightBackground,
                  foregroundColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                  side: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: _isProcessing ? null : _handleSendFeedback,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.primary),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Send Feedback',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Default 0 stars: prompt to select
    return Padding(
      key: const ValueKey('initial_hint'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        'Tap a star to rate',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: subtitleColor.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
