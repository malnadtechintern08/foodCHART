<?php
/**
 * Food CHART Web Admin - Migration Runner for 004 Support & Pages
 */
require_once __DIR__ . '/config/db.php';

try {
    $pdo = get_db_connection();
    $sqlFile = __DIR__ . '/migrations/004_create_support_and_pages.sql';
    if (!file_exists($sqlFile)) {
        throw new Exception("Migration file not found: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);
    $pdo->exec($sql);

    $pageCount = (int)$pdo->query("SELECT COUNT(*) FROM support_pages")->fetchColumn();
    $faqCount = (int)$pdo->query("SELECT COUNT(*) FROM faqs")->fetchColumn();
    $inqCount = (int)$pdo->query("SELECT COUNT(*) FROM contact_inquiries")->fetchColumn();

    echo "Migration 004 executed successfully!\n";
    echo "Support Pages: $pageCount\n";
    echo "FAQs: $faqCount\n";
    echo "Contact Inquiries: $inqCount\n";
} catch (Exception $e) {
    echo "Migration error: " . $e->getMessage() . "\n";
    exit(1);
}
