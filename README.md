<<<<<<< HEAD
# FoodCHART 🍳
> Your Master Offline Culinary Companion

foodCHART is an offline-first recipe and cooking companion Flutter application engineered to the **Flutter Production Architecture Standard** (Feature-First Clean Architecture + Riverpod + GoRouter + SQLite Local Persistence).

---

## ✨ Features

- 📶 **100% Offline-First**: Works completely without internet. All recipes, categories, favorites, and timers run locally.
- 🎨 **Culinary Aesthetic & Dark/Light Mode**: Warm terracotta, saffron amber, and OLED-optimized charcoal dark theme with modern typography (Outfit / Plus Jakarta Sans).
- 🌍 **Curated Global Recipes & Famous Chefs**: Authentic dishes from Italy, India, Japan, Mexico, France, Thailand, and the Mediterranean (featuring dishes by Gordon Ramsay, Massimo Bottura, Vikas Khanna, Jiro Ono, Rick Bayless, Julia Child, and more).
- ⚡ **Quick Launch (< 25 Mins)**: Speedy meal selector for busy home cooks.
- 🗂️ **Visual Categories & Cuisines**: Color-coded category cards with dynamic recipe counters.
- 🔍 **Real-Time Multi-Criteria Search & Filter**: Instant search across recipe titles, ingredients, chefs, cuisines, difficulty levels (Easy/Medium/Hard), and max cooking time.
- ⚖️ **Interactive Portion Scaler**: Scale ingredient quantities automatically by adjusting serving portions (+ / -).
- ⏱️ **Interactive Cooking Mode**: Step-by-step guidance with checkable sub-tasks, progress bar, and built-in digital countdown timers for timed cooking steps.
- ❤️ **Pinned Favorites**: Instant one-tap bookmarking with reactive synchronization across all views.
- ✍️ **Custom Recipe Builder**: Add, edit, and manage your own family recipes with dynamic ingredient and step inputs.

---

## 🏛️ Architecture Overview

foodCHART is structured with **Feature-First Clean Architecture**:

```
lib/
├── app/
│   ├── app.dart
│   └── router/
│       ├── app_router.dart
│       ├── route_names.dart
│       └── route_paths.dart
├── core/
│   ├── constants/
│   ├── database/
│   │   ├── database_service.dart
│   │   └── seed_data.dart
│   ├── errors/
│   ├── services/
│   │   └── preference_service.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── app_typography.dart
│   ├── utils/
│   └── widgets/
└── features/
    ├── categories/
    ├── cooking_mode/
    ├── favorites/
    ├── recipes/
    └── settings/
```

### Dependency Flow
```
Presentation (UI, Widgets, Providers) ➔ Domain (Entities, Use Cases, Repository Contracts) ➔ Data (Models, Data Sources, Repositories)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x or higher)
- Dart SDK (3.x or higher)

### Installation & Run
```bash
# 1. Clone the repository
git clone https://github.com/your-username/CookMate.git
cd CookMate

# 2. Install dependencies
flutter pub get

# 3. Run unit & widget tests
flutter test

# 4. Launch on your device or simulator
flutter run
```

---

## 🧪 Testing

Run the full suite of domain and widget tests:
```bash
flutter test
```

---

## 📄 Documentation
- [Architecture Documentation](docs/architecture.md)
- [Requirements & Feature Scope](docs/requirements.md)
- [Architecture Decision Records (ADRs)](docs/decisions.md)
=======
# FoodCHART
FoodCHART is a user friend recipes  app used for making new recipes 
>>>>>>> 72515bb22baafc19e863b111e0a890ae60fe7f9b
