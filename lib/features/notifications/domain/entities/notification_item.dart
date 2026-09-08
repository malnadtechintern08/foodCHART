import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum NotificationType {
  newRecipe,
  recipeUpdated,
  adminAnnouncement,
  newFeature,
  recipeApproved,
  recipeRejected,
  changesRequested,
  general,
  promotion,
  system;

  static NotificationType fromString(String? typeStr) {
    switch (typeStr?.toLowerCase().trim()) {
      case 'new_recipe':
      case 'newrecipe':
        return NotificationType.newRecipe;
      case 'recipe_updated':
      case 'recipeupdated':
        return NotificationType.recipeUpdated;
      case 'admin_announcement':
      case 'adminannouncement':
      case 'announcement':
        return NotificationType.adminAnnouncement;
      case 'new_feature':
      case 'newfeature':
        return NotificationType.newFeature;
      case 'recipe_approved':
      case 'recipeapproved':
      case 'approved':
        return NotificationType.recipeApproved;
      case 'recipe_rejected':
      case 'reciperejected':
      case 'rejected':
        return NotificationType.recipeRejected;
      case 'changes_requested':
      case 'changesrequested':
        return NotificationType.changesRequested;
      case 'promotion':
      case 'promo':
        return NotificationType.promotion;
      case 'system':
        return NotificationType.system;
      case 'general':
      default:
        return NotificationType.general;
    }
  }

  String get dbValue {
    switch (this) {
      case NotificationType.newRecipe:
        return 'new_recipe';
      case NotificationType.recipeUpdated:
        return 'recipe_updated';
      case NotificationType.adminAnnouncement:
        return 'admin_announcement';
      case NotificationType.newFeature:
        return 'new_feature';
      case NotificationType.recipeApproved:
        return 'recipe_approved';
      case NotificationType.recipeRejected:
        return 'recipe_rejected';
      case NotificationType.changesRequested:
        return 'changes_requested';
      case NotificationType.promotion:
        return 'promotion';
      case NotificationType.system:
        return 'system';
      case NotificationType.general:
        return 'general';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.newRecipe:
        return Icons.restaurant_menu_rounded;
      case NotificationType.recipeUpdated:
        return Icons.auto_awesome_rounded;
      case NotificationType.adminAnnouncement:
        return Icons.campaign_rounded;
      case NotificationType.newFeature:
        return Icons.rocket_launch_rounded;
      case NotificationType.recipeApproved:
        return Icons.check_circle_rounded;
      case NotificationType.recipeRejected:
        return Icons.cancel_rounded;
      case NotificationType.changesRequested:
        return Icons.edit_note_rounded;
      case NotificationType.promotion:
        return Icons.card_giftcard_rounded;
      case NotificationType.system:
        return Icons.settings_suggest_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.newRecipe:
        return AppColors.primary;
      case NotificationType.recipeUpdated:
        return AppColors.accentGold;
      case NotificationType.adminAnnouncement:
        return AppColors.accentBlue;
      case NotificationType.newFeature:
        return AppColors.accentPurple;
      case NotificationType.recipeApproved:
        return AppColors.success;
      case NotificationType.recipeRejected:
        return AppColors.error;
      case NotificationType.changesRequested:
        return AppColors.warning;
      case NotificationType.promotion:
        return const Color(0xFFFF4081);
      case NotificationType.system:
        return const Color(0xFF78909C);
      case NotificationType.general:
        return AppColors.primary;
    }
  }

  String get label {
    switch (this) {
      case NotificationType.newRecipe:
        return 'New Recipe';
      case NotificationType.recipeUpdated:
        return 'Recipe Updated';
      case NotificationType.adminAnnouncement:
        return 'Food CHART Update';
      case NotificationType.newFeature:
        return 'New Feature';
      case NotificationType.recipeApproved:
        return 'Recipe Approved';
      case NotificationType.recipeRejected:
        return 'Recipe Not Approved';
      case NotificationType.changesRequested:
        return 'Changes Requested';
      case NotificationType.promotion:
        return 'Special Offer';
      case NotificationType.system:
        return 'System Alert';
      case NotificationType.general:
        return 'Notification';
    }
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final String targetType;
  final String? relatedType;
  final String? relatedId;
  final String? image;
  final String? actionLabel;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.targetType = 'all',
    this.relatedType,
    this.relatedId,
    this.image,
    this.actionLabel,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  bool get isNew {
    final now = DateTime.now();
    return !isRead || now.difference(createdAt).inHours < 4;
  }
}
