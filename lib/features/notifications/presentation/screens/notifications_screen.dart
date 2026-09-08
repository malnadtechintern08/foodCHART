import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_card.dart';
import '../../../recipes/presentation/providers/recipe_providers.dart';
import '../../services/cookmate_notification_service.dart';
import '../../services/notification_sync_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationSyncService.instance.updateRef(ref);
      ref.read(notificationsProvider.notifier).loadNotifications();
      ref.read(unreadNotificationCountProvider.notifier).refresh();
    });
  }

  bool _isNavigating = false;

  void _showMarkAllReadDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Mark all notifications as read?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: Text(
          'All notifications will be marked as read. They will remain visible in your feed for the next 24 hours before automatically disappearing.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.textMuted : AppColors.lightTextMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx, rootNavigator: true).pop();
              HapticFeedback.mediumImpact();
              ref.read(notificationsProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Mark All'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear all notifications?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: Text(
          'All notifications will be deleted and removed from your feed.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.textMuted : AppColors.lightTextMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx, rootNavigator: true).pop();
              HapticFeedback.mediumImpact();
              ref.read(notificationsProvider.notifier).clearAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(NotificationModel notif) {
    HapticFeedback.lightImpact();
    ref.read(notificationsProvider.notifier).deleteNotification(notif.id);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification "${notif.title}" deleted.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onNotificationTap(NotificationModel notif) {
    if (_isNavigating) return;
    _isNavigating = true;
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _isNavigating = false;
    });

    HapticFeedback.selectionClick();
    // Mark as read immediately
    ref.read(notificationsProvider.notifier).markAsRead(notif.id);

    // Smart navigation dispatch
    if (notif.relatedType == 'recipe' && notif.relatedId != null && notif.relatedId!.isNotEmpty) {
      try {
        ref.read(syncRecipesWithServerProvider.future);
        context.push('/recipe/${notif.relatedId}');
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This content is no longer available.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (notif.relatedType == 'recipe_submission' || notif.relatedId == 'submissions') {
      try {
        context.pushNamed(RouteNames.mySubmissions);
      } catch (_) {
        context.pushNamed(RouteNames.notificationDetails, extra: notif, pathParameters: {'id': notif.id.toString()});
      }
    } else if (notif.relatedType == 'feature') {
      if (notif.relatedId == 'hashtags' || notif.relatedId == 'search') {
        context.pushNamed(RouteNames.search);
      } else if (notif.relatedId == 'submissions') {
        context.pushNamed(RouteNames.mySubmissions);
      } else {
        context.goNamed(RouteNames.explore);
      }
    } else {
      // General announcement or deep details
      context.pushNamed(
        RouteNames.notificationDetails,
        pathParameters: {'id': notif.id.toString()},
        extra: notif,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsState = ref.watch(notificationsProvider);
    final currentFilter = ref.watch(notificationFilterProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Test Heads-Up Popup',
            icon: const Icon(Icons.notifications_active_outlined, size: 22, color: AppColors.primary),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await CookMateNotificationService.instance.showTestNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Heads-up notification triggered! Check the top of your screen.'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _showMarkAllReadDialog,
              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
              label: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Clear All',
            icon: Icon(
              Icons.delete_sweep_outlined,
              size: 22,
              color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
            ),
            onPressed: _showClearAllDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(notificationsProvider.notifier).loadNotifications(
            filter: currentFilter == 'unread' ? 'unread' : null,
            isRefresh: true,
          );
          await ref.read(unreadNotificationCountProvider.notifier).refresh();
        },
        child: Column(
          children: [
            // Filter Selector Bar (All / Unread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', currentFilter, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    unreadCount > 0 ? 'Unread ($unreadCount)' : 'Unread',
                    'unread',
                    currentFilter,
                    isDark,
                  ),
                ],
              ),
            ),

            // Main Notification List View
            Expanded(
              child: notificationsState.when(
                data: (items) {
                  final filtered = currentFilter == 'unread'
                      ? items.where((n) => !n.isRead).toList()
                      : items;

                  if (filtered.isEmpty) {
                    return _buildEmptyState(isDark, currentFilter);
                  }

                  // Group into "New" and "Earlier"
                  final newItems = filtered.where((n) => n.isNew).toList();
                  final earlierItems = filtered.where((n) => !n.isNew).toList();

                  return ListView(
                    padding: const EdgeInsets.only(top: 10, bottom: 32),
                    children: [
                      if (newItems.isNotEmpty) ...[
                        _buildSectionHeader('NEW', isDark),
                        ...newItems.map((n) => NotificationCard(
                              notification: n,
                              onTap: () => _onNotificationTap(n),
                              onToggleRead: () {
                                if (n.isRead) {
                                  ref.read(notificationsProvider.notifier).markAsUnread(n.id);
                                } else {
                                  ref.read(notificationsProvider.notifier).markAsRead(n.id);
                                }
                              },
                              onDelete: () => _deleteNotification(n),
                            )),
                        const SizedBox(height: 12),
                      ],
                      if (earlierItems.isNotEmpty) ...[
                        _buildSectionHeader('EARLIER', isDark),
                        ...earlierItems.map((n) => NotificationCard(
                              notification: n,
                              onTap: () => _onNotificationTap(n),
                              onToggleRead: () {
                                if (n.isRead) {
                                  ref.read(notificationsProvider.notifier).markAsUnread(n.id);
                                } else {
                                  ref.read(notificationsProvider.notifier).markAsRead(n.id);
                                }
                              },
                              onDelete: () => _deleteNotification(n),
                            )),
                      ],
                    ],
                  );
                },
                loading: () => _buildLoadingState(isDark),
                error: (err, stack) => _buildErrorState(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String current, bool isDark) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(notificationFilterProvider.notifier).state = value;
        ref.read(notificationsProvider.notifier).loadNotifications(
          filter: value == 'unread' ? 'unread' : null,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.border : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String filter) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_active_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "You're all caught up!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter == 'unread'
                  ? 'No unread notifications right now.'
                  : 'No new CookMate notifications right now.\nCheck back later for culinary updates and fresh recipes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          height: 78,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.lightBorder,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 54, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Unable to load notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection or server availability and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(notificationsProvider.notifier).loadNotifications();
                ref.read(unreadNotificationCountProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
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
}
