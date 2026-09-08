import '../../domain/entities/support_page.dart';

class SupportPageModel extends SupportPage {
  const SupportPageModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.summary,
    required super.content,
    super.meta = const {},
    super.isPublished = true,
    super.updatedAt,
  });

  factory SupportPageModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> parsedMeta = {};
    if (json['meta'] is Map<String, dynamic>) {
      parsedMeta = json['meta'] as Map<String, dynamic>;
    } else if (json['meta_json'] is String && (json['meta_json'] as String).isNotEmpty) {
      try {
        // Will be decoded if passed as string
      } catch (_) {}
    }

    DateTime? updated;
    if (json['updated_at'] != null) {
      try {
        updated = DateTime.parse(json['updated_at'].toString());
      } catch (_) {}
    }

    return SupportPageModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      meta: parsedMeta,
      isPublished: (json['is_published'] == 1 || json['is_published'] == true || json['is_published'] == '1'),
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'summary': summary,
      'content': content,
      'meta': meta,
      'is_published': isPublished ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Built-in fallback for Privacy Policy
  static SupportPageModel defaultPrivacyPolicy() {
    return const SupportPageModel(
      id: 'privacy-policy',
      title: 'Privacy Policy',
      slug: 'privacy-policy',
      summary: 'Understand how Food CHART collects, protects, and respects your culinary and device data.',
      content: '''# Food CHART Privacy Policy

**Effective Date:** January 1, 2026  
**Last Updated:** September 5, 2026  

Welcome to **Food CHART**, your personal culinary and recipe companion dedicated to preserving authentic heritage cuisine. Your privacy is paramount to us. This Privacy Policy explains our practices regarding the collection, use, and disclosure of your information when you use our mobile application and website services.

---

### 1. Information We Collect
Food CHART is built with an **offline-first philosophy**. We minimize data collection to provide you with a seamless cooking experience:
- **Device Preferences:** Selected theme mode (Dark/Light), active language preference, and serving multiplier.
- **Local Culinary Data:** Favorites, recently viewed recipes, smart shopping lists, and personal kitchen notes are stored directly on your device's local database (SQLite) and are never transmitted to external servers without your permission.
- **Recipe Submissions & Community Contributions:** When you voluntarily submit a recipe or feedback, we collect your contributor name, recipe details, ingredient measurements, preparation steps, and optional dish photos.
- **Technical & Diagnostics:** Minimal anonymous performance logs and crash metrics to keep Food CHART fast and reliable.

---

### 2. Device Permissions
Food CHART only requests permissions strictly necessary to deliver app features:
- **Camera & Photo Gallery:** Used solely when you choose to attach or take a photo for recipe submissions or dish notes. Photos remain private unless you publish them in a community submission.
- **Notifications:** Used only to send you timer alerts during cooking and updates on your recipe submissions (you can disable these anytime in device settings).
- **Storage / Files:** Used for exporting or backing up your notes and shopping list.

---

### 3. How We Use Your Information
We use collected information exclusively to:
1. Provide, maintain, and enhance the recipe discovery and cooking experience.
2. Review, verify, and publish community recipes with proper contributor credit.
3. Send cooking timer notifications and submission status updates.
4. Detect security issues and prevent fraudulent or abusive submissions.

We **NEVER** sell, rent, or trade your personal data to third-party advertisers.

---

### 4. Data Storage and Security
We utilize industry-standard cryptographic practices (SSL/TLS encryption in transit, strict parameterized database queries) to protect any information submitted to our servers. Local app data stays encrypted and isolated within your device sandbox.

---

### 5. Your Rights and Choices
- **Access & Correction:** You can review and edit your submissions, favorites, notes, and preferences directly within the app.
- **Data Reset:** You can reset local catalog cache or delete your locally stored notes and shopping list at any time through **Settings > Offline Database > Reset Data**.
- **Inquiries & Deletion:** To request deletion of your published community submission or contact data, please reach out via our **Contact Us** screen or email `privacy@cookmate.app`.

---

### 6. Updates to This Policy
We may periodically update this policy to reflect new features or regulatory requirements. Changes will be posted in this section with an updated revision date.''',
      meta: {
        'version': '2.1',
        'contact_email': 'privacy@cookmate.app',
        'jurisdiction': 'India',
      },
      isPublished: true,
    );
  }

  /// Built-in fallback for Contact Us
  static SupportPageModel defaultContactUs() {
    return const SupportPageModel(
      id: 'contact-us',
      title: 'Contact Us',
      slug: 'contact-us',
      summary: 'Get in touch with the Food CHART team for recipe help, partnership inquiries, or app feedback.',
      content: '''### We Would Love to Hear From You!

Whether you have questions about authentic Malnad recipes, want to report a bug, suggest new culinary features, or collaborate with our culinary research team, our friendly team is here to assist you.''',
      meta: {
        'support_email': 'support@cookmate.app',
        'press_email': 'press@cookmate.app',
        'phone': '+91 (80) 4567-8900',
        'whatsapp': '+91 98765 43210',
        'address': 'Food CHART Culinary Labs, 4th Floor, Brigade Gateway, Malleshwaram, Bengaluru, Karnataka 560055, India',
        'hours': 'Monday – Saturday: 9:00 AM – 6:00 PM IST',
        'social': {
          'instagram': '@cookmate_app',
          'twitter': '@CookMateApp',
          'youtube': 'CookMateKitchen'
        }
      },
      isPublished: true,
    );
  }

  /// Built-in fallback for Help Center
  static SupportPageModel defaultHelpCenter() {
    return const SupportPageModel(
      id: 'help-center',
      title: 'Help Center',
      slug: 'help-center',
      summary: 'Explore guides, step-by-step tutorials, and tips for making the most out of Food CHART.',
      content: '''# Food CHART Help Center & User Guide

Find answers, tutorials, and practical tips on using Food CHART to master everyday cooking and authentic heritage recipes.

---

### 1. Discovering & Filtering Recipes
- **Heritage Categories:** Browse collections like Malnad Special, South Indian Breakfast, Royal Curries, Snacks, and Healthy Millets.
- **Smart Filters:** Filter by Pure Vegetarian / Non-Vegetarian, Difficulty (Easy, Medium, Hard), and Cooking Time.
- **Hashtag Search:** Tap any hashtag (e.g. `#MalnadSpecial`, `#DosaLove`) to view all recipes tagged with that theme.

---

### 2. Interactive Cooking Mode
- When viewing a recipe, tap **Start Cooking Mode**.
- Navigate through steps with large readable text designed for kitchen counters.
- Built-in interactive timers ring and vibrate when simmering, boiling, or baking steps finish.

---

### 3. Shopping List & Dynamic Servings
- Adjust the servings counter on any recipe; ingredient quantities dynamically re-scale automatically.
- Tap **Add to Shopping List** to send missing items to your smart grocery checklist, organized by aisle.

---

### 4. Submitting Your Recipes
- Tap the **+** button in My Kitchen or Recipe Submissions.
- Fill in the title, preparation time, servings, step-by-step instructions, and upload a dish photo.
- Our editorial team reviews submissions within 24-48 hours. Track real-time review progress under **My Submissions**.

---

### 5. Offline Access & Data Sync
- Food CHART works **100% offline**. You can view recipes, use timers, and manage notes without cellular or Wi-Fi connectivity.
- When internet is available, tap the sync icon to fetch newly approved recipes and notification announcements.''',
      meta: {
        'topics': [
          'Discovering Recipes',
          'Interactive Cooking Mode',
          'Dynamic Servings',
          'Submitting Recipes',
          'Offline First'
        ]
      },
      isPublished: true,
    );
  }

  /// Built-in fallback for Safety and Guidelines
  static SupportPageModel defaultSafetyGuidelines() {
    return const SupportPageModel(
      id: 'safety-guidelines',
      title: 'Safety and Guidelines',
      slug: 'safety-guidelines',
      summary: 'Essential kitchen safety, food hygiene, allergen information, and community recipe guidelines.',
      content: '''# Safety, Hygiene & Community Guidelines

At Food CHART, your health and safety in the kitchen are just as important as the delicious dishes you prepare. Please review these essential guidelines.

---

### 1. Food Hygiene & Preparation Safety
- **Hand Washing:** Always wash hands with soap and warm water for at least 20 seconds before and after handling raw ingredients.
- **Cross-Contamination:** Use separate cutting boards and knives for raw poultry/meat/fish and fresh vegetables/cooked foods.
- **Safe Internal Temperatures:** Ensure meat, poultry, and seafood are cooked to safe minimum internal temperatures (Poultry: 74°C / 165°F; Ground Meat: 71°C / 160°F; Fish: 63°C / 145°F).
- **Storing Leftovers:** Refrigerate cooked dishes within two hours of preparation in airtight glass or food-safe containers. Reheat thoroughly before eating.

---

### 2. Kitchen Appliance & Equipment Safety
- **Pressure Cookers:** Always inspect steam vents, safety valves, and rubber gaskets before sealing. Never force open a hot pressure cooker; wait until pressure drops naturally.
- **Hot Oil & Deep Frying:** Keep pan handles turned inward. Never pour water onto oil fires; use a lid or fire blanket.
- **Sharp Knives:** Keep knives honed and sharp. Cut on stable cutting boards placed on a damp cloth to prevent slipping.

---

### 3. Allergen Awareness & Ingredient Substitutions
- Many authentic Indian recipes feature tree nuts (cashews, almonds), dairy (ghee, paneer, milk), mustard seeds, or gluten.
- Always review recipe tags and allergen notices if cooking for individuals with food allergies.
- Feel free to use healthy substitutes (e.g. oil instead of ghee for vegan cooking, coconut milk instead of dairy cream).

---

### 4. Community Recipe Submission Standards
When submitting recipes to Food CHART, contributors agree to uphold our community trust:
- **Authenticity:** Submit accurate ingredients, realistic cooking times, and clear step-by-step instructions.
- **Originality:** Share your own recipes or traditional family techniques. Do not copy copyrighted text from books or commercial websites.
- **Photo Quality:** Upload genuine, high-quality photos of the actual prepared dish. Stock photos or irrelevant images will be rejected.
- **Respectful Content:** Promotional spam, non-food advertisements, and abusive language are strictly prohibited.''',
      meta: {
        'emergency_phone': '112 / 108',
        'allergen_notice_enabled': true,
      },
      isPublished: true,
    );
  }
}
