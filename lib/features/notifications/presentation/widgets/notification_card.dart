import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onToggleRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onToggleRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    final cardBg = isUnread
        ? (isDark ? const Color(0xFF222222) : Colors.white)
        : (isDark ? const Color(0xFF161616) : const Color(0xFFF7F7F7));

    final cardBorderColor = isUnread
        ? (isDark ? AppColors.primary.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.3))
        : (isDark ? AppColors.border.withValues(alpha: 0.6) : AppColors.lightBorder);

    final cardContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: isUnread ? 1.2 : 1.0),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: notification.type.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notification.type.color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      notification.type.icon,
                      color: notification.type.color,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title + Red Dot Indicator + Time
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isUnread) ...[
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            notification.timeWithClockFormatted,
                            style: TextStyle(

                              fontSize: 11,
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                              color: isUnread
                                  ? AppColors.primary
                                  : (isDark ? AppColors.textMuted : AppColors.lightTextMuted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Message Body
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                          color: isDark
                              ? (isUnread ? const Color(0xFFD4D4D4) : AppColors.textMuted)
                              : (isUnread ? const Color(0xFF424242) : AppColors.lightTextMuted),
                        ),
                      ),

                      // Optional Metadata Tag (e.g. Related Recipe pill)
                      if (notification.relatedType != null && notification.relatedType!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF262626) : const Color(0xFFEBEBEB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notification.relatedType == 'recipe'
                                ? 'Tap to view recipe →'
                                : notification.relatedType == 'recipe_submission'
                                    ? 'Tap to view submission →'
                                    : 'Tap for details →',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Popup menu for quick status toggling and deletion
                if (onToggleRead != null || onDelete != null) ...[
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                    ),
                    color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
                    ),
                    onSelected: (val) {
                      if (val == 'toggle' && onToggleRead != null) {
                        onToggleRead!();
                      } else if (val == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onToggleRead != null)
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                isUnread ? Icons.done_all_rounded : Icons.mark_as_unread_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isUnread ? 'Mark as read' : 'Mark as unread',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Delete notification',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: ValueKey('notif_card_${notification.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        background: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.delete_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
