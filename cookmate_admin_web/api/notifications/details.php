
<?php
/**
 * Food CHART API - Notification Details Endpoint
 * GET /api/notifications/details.php?id=123
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/auth_middleware.php';
require_once __DIR__ . '/../../includes/notification_functions.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$pdo = get_db_connection();
ensure_notifications_tables_exist($pdo);
$user = get_authenticated_user($pdo, false, true, 'Food CHART Foodie');
$userId = $user ? (int)$user['id'] : 1;

$notifId = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if ($notifId <= 0) {
    json_response([
        'success' => false,
        'message' => 'Notification ID is required.'
    ], 400);
}

try {
    $stmt = $pdo->prepare("
        SELECT 
            n.id,
            n.title,
            n.message,
            n.type,
            n.target_type,
            n.target_user_id,
            n.related_type,
            n.related_id,
            n.image,
            n.action_label,
            n.status,
            n.created_at,
            COALESCE(un.is_read, 0) AS is_read,
            un.read_at
        FROM notifications n
        LEFT JOIN user_notifications un 
               ON un.notification_id = n.id AND un.user_id = ?
        WHERE n.id = ?
          AND n.status = 'active'
          AND (
               n.target_type = 'all' 
               OR (n.target_type = 'specific_user' AND n.target_user_id = ?)
               OR (n.target_type = 'all_except_user' AND (n.target_user_id IS NULL OR n.target_user_id != ?))
          )
        LIMIT 1
    ");
    $stmt->execute([$userId, $notifId, $userId, $userId]);
    $notif = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$notif) {
        json_response([
            'success' => false,
            'message' => 'Notification not found or access denied.'
        ], 404);
    }

    // Automatically mark as read upon viewing details (preserves existing read_at if already read)
    mark_notification_as_read($pdo, $notifId, $userId);

    // Re-fetch read_at timestamp
    $unStmt = $pdo->prepare("SELECT read_at FROM user_notifications WHERE notification_id = ? AND user_id = ?");
    $unStmt->execute([$notifId, $userId]);
    $readAt = $unStmt->fetchColumn();

    $relatedData = null;
    // Enrich with related recipe data if applicable
    if ($notif['related_type'] === 'recipe' && !empty($notif['related_id'])) {
        $recStmt = $pdo->prepare("SELECT id, title, description, cuisine, image_url, prep_time_minutes, cook_time_minutes FROM recipes WHERE id = ?");
        $recStmt->execute([$notif['related_id']]);
        $rec = $recStmt->fetch(PDO::FETCH_ASSOC);
        if ($rec) {
            $relatedData = [
                'type'        => 'recipe',
                'id'          => $rec['id'],
                'title'       => $rec['title'],
                'description' => $rec['description'],
                'cuisine'     => $rec['cuisine'],
                'image_url'   => $rec['image_url'],
            ];
        }
    } elseif ($notif['related_type'] === 'recipe_submission' && !empty($notif['related_id'])) {
        $subStmt = $pdo->prepare("SELECT id, recipe_name, status, rejection_reason, admin_notes, published_recipe_id FROM recipe_submissions WHERE id = ?");
        $subStmt->execute([$notif['related_id']]);
        $sub = $subStmt->fetch(PDO::FETCH_ASSOC);
        if ($sub) {
            $relatedData = [
                'type'                => 'recipe_submission',
                'id'                  => (int)$sub['id'],
                'recipe_name'         => $sub['recipe_name'],
                'status'              => $sub['status'],
                'rejection_reason'    => $sub['rejection_reason'],
                'admin_notes'         => $sub['admin_notes'],
                'published_recipe_id' => $sub['published_recipe_id'],
            ];
        }
    }

    $unreadCount = get_user_unread_count($pdo, $userId);

    json_response([
        'success'      => true,
        'unread_count' => $unreadCount,
        'data'         => [
            'id'           => (int)$notif['id'],
            'title'        => $notif['title'],
            'message'      => $notif['message'],
            'type'         => $notif['type'],
            'target_type'  => $notif['target_type'],
            'related_type' => $notif['related_type'],
            'related_id'   => $notif['related_id'],
            'related_data' => $relatedData,
            'image'        => $notif['image'],
            'action_label' => $notif['action_label'] ?? null,
            'is_read'      => true,
            'read_at'      => $readAt,
            'created_at'   => $notif['created_at'],
        ]
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to load notification details: ' . $e->getMessage()
    ], 500);
}
