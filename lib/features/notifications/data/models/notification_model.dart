import 'package:intl/intl.dart';
import '../../domain/entities/notification_item.dart';

class NotificationModel extends NotificationItem {
  final Map<String, dynamic>? relatedData;
  final DateTime? receivedAt;

  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    super.targetType = 'all',
    super.relatedType,
    super.relatedId,
    super.image,
    super.actionLabel,
    super.isRead = false,
    super.readAt,
    required super.createdAt,
    this.relatedData,
    this.receivedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreatedAt;
    try {
      if (json['created_at'] != null) {
        String raw = json['created_at'].toString().trim();
        // Convert raw MySQL 'YYYY-MM-DD HH:MM:SS' into ISO8601 UTC
        if (RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$').hasMatch(raw)) {
          raw = '${raw.replaceFirst(' ', 'T')}Z';
        }
        parsedCreatedAt = DateTime.parse(raw).toLocal();
      } else {
        parsedCreatedAt = DateTime.now();
      }
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    DateTime? parsedReadAt;
    try {
      if (json['read_at'] != null && json['read_at'].toString().isNotEmpty) {
        String raw = json['read_at'].toString().trim();
        if (RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$').hasMatch(raw)) {
          raw = '${raw.replaceFirst(' ', 'T')}Z';
        }
        parsedReadAt = DateTime.parse(raw).toLocal();
      }
    } catch (_) {
      parsedReadAt = null;
    }

    DateTime? parsedReceivedAt;
    try {
      if (json['received_at'] != null && json['received_at'].toString().isNotEmpty) {
        parsedReceivedAt = DateTime.parse(json['received_at'].toString()).toLocal();
      }
    } catch (_) {
      parsedReceivedAt = null;
    }

    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: NotificationType.fromString(json['type']?.toString()),
      targetType: json['target_type']?.toString() ?? 'all',
      relatedType: json['related_type']?.toString(),
      relatedId: json['related_id']?.toString(),
      image: json['image']?.toString(),
      actionLabel: json['action_label']?.toString(),
      isRead: json['is_read'] == true || json['is_read'] == 1 || json['is_read'] == '1',
      readAt: parsedReadAt,
      createdAt: parsedCreatedAt,
      receivedAt: parsedReceivedAt,
      relatedData: json['related_data'] is Map<String, dynamic> ? json['related_data'] as Map<String, dynamic> : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.dbValue,
      'target_type': targetType,
      'related_type': relatedType,
      'related_id': relatedId,
      'image': image,
      if (actionLabel != null) 'action_label': actionLabel,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      if (receivedAt != null) 'received_at': receivedAt?.toIso8601String(),
      if (relatedData != null) 'related_data': relatedData,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? message,
    NotificationType? type,
    String? targetType,
    String? relatedType,
    String? relatedId,
    String? image,
    String? actionLabel,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? receivedAt,
    Map<String, dynamic>? relatedData,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      targetType: targetType ?? this.targetType,
      relatedType: relatedType ?? this.relatedType,
      relatedId: relatedId ?? this.relatedId,
      image: image ?? this.image,
      actionLabel: actionLabel ?? this.actionLabel,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      receivedAt: receivedAt ?? this.receivedAt,
      relatedData: relatedData ?? this.relatedData,
    );
  }

  /// Whether notification has exceeded the strict 24-hour expiration window.
  bool get isExpired {
    final referenceTime = receivedAt ?? createdAt;
    return DateTime.now().difference(referenceTime).inHours >= 24;
  }

  /// Formats date to human-readable relative time:
  /// Just now, 5 min ago, 2 hours ago, Yesterday, or 03 Sep 2026.
  String get timeAgoFormatted {
    final displayTime = (receivedAt ?? createdAt).toLocal();
    final now = DateTime.now();
    var difference = now.difference(displayTime);
    if (difference.isNegative) difference = Duration.zero;

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final m = difference.inMinutes;
      return '$m min ago';
    } else if (difference.inHours < 24) {
      final h = difference.inHours;
      return h == 1 ? '1 hour ago' : '$h hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(displayTime);
    }
  }

  /// Formats date with relative time plus exact local arrival clock time:
  /// e.g. "Just now • 11:35 AM", "5 min ago • 11:30 AM", "Today • 9:15 AM", "Yesterday • 8:30 PM"
  String get timeWithClockFormatted {
    final displayTime = (receivedAt ?? createdAt).toLocal();
    final now = DateTime.now();
    var difference = now.difference(displayTime);
    if (difference.isNegative) difference = Duration.zero;

    final timeStr = DateFormat('h:mm a').format(displayTime);

    if (difference.inMinutes < 2) {
      return 'Just now • $timeStr';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago • $timeStr';
    } else if (difference.inHours < 24) {
      final isToday = now.year == displayTime.year && now.month == displayTime.month && now.day == displayTime.day;
      if (isToday) {
        return 'Today • $timeStr';
      } else {
        return '${difference.inHours}h ago • $timeStr';
      }
    } else if (difference.inHours < 48) {
      return 'Yesterday • $timeStr';
    } else {
      return DateFormat('dd MMM, h:mm a').format(displayTime);
    }
  }

  /// Complete local timestamp string for notification details modal/screen
  String get fullFormattedTime {
    final displayTime = (receivedAt ?? createdAt).toLocal();
    return DateFormat('dd MMM yyyy, h:mm a').format(displayTime);
  }
}


