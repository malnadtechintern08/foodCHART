import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_providers.dart';

class NotificationDetailsScreen extends ConsumerWidget {
  final int notificationId;
  final NotificationModel? initialNotification;

  const NotificationDetailsScreen({
    super.key,
    required this.notificationId,
    this.initialNotification,
  });

  void _handleAction(BuildContext context, NotificationModel notif) {
    if (notif.relatedType == 'recipe' && notif.relatedId != null && notif.relatedId!.isNotEmpty) {
      context.push('/recipe/${notif.relatedId}');
    } else if (notif.relatedType == 'recipe_submission' || notif.relatedId == 'submissions') {
      context.pushNamed(RouteNames.mySubmissions);
    } else if (notif.relatedType == 'feature') {
      if (notif.relatedId == 'hashtags' || notif.relatedId == 'search') {
        context.pushNamed(RouteNames.search);
      } else if (notif.relatedId == 'submissions') {
        context.pushNamed(RouteNames.mySubmissions);
      } else {
        context.goNamed(RouteNames.explore);
      }
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncNotif = ref.watch(notificationDetailsProvider(notificationId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Notification Details',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Delete Notification',
            icon: const Icon(Icons.delete_outline_rounded, size: 22, color: AppColors.error),
            onPressed: () {
              ref.read(notificationsProvider.notifier).deleteNotification(notificationId);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification deleted.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: asyncNotif.when(
        data: (notif) => _buildContent(context, notif, isDark),
        loading: () {
          if (initialNotification != null) {
            return _buildContent(context, initialNotification!, isDark);
          }
          return const Center(child: AppLoadingIndicator());
        },
        error: (err, stack) {
          if (initialNotification != null) {
            return _buildContent(context, initialNotification!, isDark);
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load notification details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(notificationDetailsProvider(notificationId)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationModel notif, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 32 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Type Pill + Timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: notif.type.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(notif.type.icon, size: 14, color: notif.type.color),
                          const SizedBox(width: 6),
                          Text(
                            notif.type.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: notif.type.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      notif.timeAgoFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  notif.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Message Text
                Text(
                  notif.message,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Received: ${notif.fullFormattedTime}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


          // Optional Image Card
          if (notif.image != null && notif.image!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: notif.image!.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: notif.image!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, err, stack) => const SizedBox.shrink(),
                    )
                  : Image.asset(
                      notif.image!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
                    ),
            ),
          ],

          // Related Content Details Card
          if (notif.relatedData != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141414) : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATTACHED DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (notif.relatedData!['title'] != null)
                    Text(
                      notif.relatedData!['title'].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  if (notif.relatedData!['recipe_name'] != null)
                    Text(
                      notif.relatedData!['recipe_name'].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  if (notif.relatedData!['rejection_reason'] != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Reason: ${notif.relatedData!['rejection_reason']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Primary Action CTA
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _handleAction(context, notif),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: Text(
                notif.actionLabel?.isNotEmpty == true
                    ? notif.actionLabel!
                    : notif.relatedType == 'recipe'
                        ? 'View Recipe 🍲'
                        : notif.relatedType == 'recipe_submission'
                            ? 'View My Submission 📝'
                            : notif.relatedType == 'feature'
                                ? 'Explore Feature 🚀'
                                : 'Back to Notifications',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
