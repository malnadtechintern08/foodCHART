import '../../domain/entities/faq_item.dart';

class FaqModel extends FaqItem {
  const FaqModel({
    required super.id,
    required super.category,
    required super.question,
    required super.answer,
    super.sortOrder = 0,
    super.isPublished = true,
    super.updatedAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    DateTime? updated;
    if (json['updated_at'] != null) {
      try {
        updated = DateTime.parse(json['updated_at'].toString());
      } catch (_) {}
    }

    return FaqModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      category: (json['category'] ?? 'General').toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      sortOrder: int.tryParse(json['sort_order'].toString()) ?? 0,
      isPublished: (json['is_published'] == 1 || json['is_published'] == true || json['is_published'] == '1'),
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'question': question,
      'answer': answer,
      'sort_order': sortOrder,
      'is_published': isPublished ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Default offline list of FAQs
  static List<FaqModel> defaultFaqs() {
    return const [
      FaqModel(
        id: 1,
        category: 'General',
        question: 'What is Food CHART and who is it for?',
        answer: 'Food CHART is an all-in-one culinary companion designed for food enthusiasts, home cooks, and lovers of authentic regional cuisine. It brings together heritage recipes (such as Malnad specialties) alongside modern pan-Indian classics with offline support, step-by-step timers, and smart grocery checklists.',
        sortOrder: 1,
      ),
      FaqModel(
        id: 2,
        category: 'General',
        question: 'Does Food CHART work without an internet connection?',
        answer: 'Yes! Food CHART is built offline-first. All core recipes, instructions, ingredients, notes, and timers function completely offline. An internet connection is only needed when syncing newly published community recipes or submitting your own recipes for review.',
        sortOrder: 2,
      ),
      FaqModel(
        id: 3,
        category: 'Recipes & Cooking',
        question: 'Can I adjust the recipe servings?',
        answer: 'Absolutely. When viewing any recipe details page, tap the plus (+) or minus (-) buttons next to Servings. All ingredient quantities automatically calculate and scale in real time.',
        sortOrder: 3,
      ),
      FaqModel(
        id: 4,
        category: 'Recipes & Cooking',
        question: 'How do the cooking timers work?',
        answer: 'In both the Recipe Details screen and the interactive Cooking Mode, recipe steps with cooking times show a timer button. Tapping it activates a countdown timer with audio-haptic feedback so you never overcook or burn dishes.',
        sortOrder: 4,
      ),
      FaqModel(
        id: 5,
        category: 'Submissions',
        question: 'How do I submit my own family recipe to Food CHART?',
        answer: 'Navigate to "My Kitchen" or the side drawer and select "Submit Recipe". Enter the title, preparation time, servings, ingredients, instructions, and optionally upload a photo of your dish. Once submitted, our editorial team reviews it before publishing it to the community.',
        sortOrder: 5,
      ),
      FaqModel(
        id: 6,
        category: 'Submissions',
        question: 'How long does recipe moderation take?',
        answer: 'Our culinary moderation team typically reviews submitted recipes within 24 to 48 hours. You will receive an in-app status notification once your recipe is approved or if modifications are suggested.',
        sortOrder: 6,
      ),
      FaqModel(
        id: 7,
        category: 'Dietary & Health',
        question: 'How can I find Pure Vegetarian recipes?',
        answer: 'You can tap the "Pure Veg" toggle chip on the Explore or All Recipes screen. Every recipe is also marked with a green indicator for Pure Veg or red for Non-Veg.',
        sortOrder: 7,
      ),
      FaqModel(
        id: 8,
        category: 'Dietary & Health',
        question: 'Are nutritional facts available for recipes?',
        answer: 'Yes! Each recipe includes estimated calories, protein, and carbohydrates per serving to assist with your meal planning.',
        sortOrder: 8,
      ),
      FaqModel(
        id: 9,
        category: 'App & Account',
        question: 'Can I save my favorite recipes and personal notes?',
        answer: 'Yes. Tap the heart icon on any recipe to add it to Favorites. You can also write personal cooking notes, secret variations, and tips under the "My Notes" section in settings.',
        sortOrder: 9,
      ),
      FaqModel(
        id: 10,
        category: 'App & Account',
        question: 'How do I contact customer support?',
        answer: 'You can reach our team anytime via the "Contact Us" screen in the app, or send an email directly to support@cookmate.app.',
        sortOrder: 10,
      ),
    ];
  }
}
