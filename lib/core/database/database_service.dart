import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'seed_data.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

class DatabaseService {
  static DatabaseService? _instance;
  Database? _database;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Setup FFI for desktop if needed
      if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      String path;
      if (kIsWeb) {
        path = AppConstants.dbName;
      } else {
        final documentsDirectory = await getApplicationDocumentsDirectory();
        path = p.join(documentsDirectory.path, AppConstants.dbName);
      }

      return await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 6) {
            // Backup user-created custom recipes before re-seeding catalog
            List<Map<String, dynamic>> customRecipes = [];
            try {
              customRecipes = await db.query('recipes', where: 'is_custom = 1');
            } catch (_) {}

            // Drop and re-create catalog tables for clean synchronization with full 120-recipe catalog
            await db.execute('DROP TABLE IF EXISTS instructions');
            await db.execute('DROP TABLE IF EXISTS ingredients');
            await db.execute('DROP TABLE IF EXISTS recipes');
            await db.execute('DROP TABLE IF EXISTS categories');
            await _onCreate(db, newVersion);

            // Restore custom user recipes if any
            for (final r in customRecipes) {
              try {
                await db.insert('recipes', r);
              } catch (_) {}
            }
          }
        },

        onOpen: (db) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS notes (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              category TEXT NOT NULL,
              tags TEXT NOT NULL,
              is_pinned INTEGER NOT NULL DEFAULT 0,
              is_favorite INTEGER NOT NULL DEFAULT 0,
              related_recipe_id TEXT,
              related_recipe_title TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_pinned ON notes (is_pinned)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_favorite ON notes (is_favorite)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_category ON notes (category)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_created ON notes (created_at)');
        },
      );
    } catch (e) {
      throw AppDatabaseException('Failed to initialize database: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // 2. Recipes table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recipes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        chef_name TEXT NOT NULL,
        cuisine TEXT NOT NULL,
        image_url TEXT NOT NULL,
        prep_time_minutes INTEGER NOT NULL,
        cook_time_minutes INTEGER NOT NULL,
        servings INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        category_id TEXT NOT NULL,
        tags TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_custom INTEGER NOT NULL DEFAULT 0,
        is_vegetarian INTEGER NOT NULL DEFAULT 1,
        rating REAL NOT NULL DEFAULT 4.8,
        region TEXT NOT NULL DEFAULT 'Karnataka',
        subcategory TEXT NOT NULL DEFAULT '',
        nutrition TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // 3. Ingredients table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id TEXT NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        unit TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // 4. Instructions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS instructions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id TEXT NOT NULL,
        step_number INTEGER NOT NULL,
        instruction TEXT NOT NULL,
        timer_seconds INTEGER,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // 5. Notes table (Personal Cooking Notes, Tips & Reminders)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        tags TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        related_recipe_id TEXT,
        related_recipe_title TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Indexes for high performance querying
    await db.execute('CREATE INDEX IF NOT EXISTS idx_recipes_category ON recipes (category_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_recipes_favorite ON recipes (is_favorite)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_recipes_custom ON recipes (is_custom)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_recipes_veg ON recipes (is_vegetarian)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_recipes_title ON recipes (title)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_ingredients_recipe ON ingredients (recipe_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_instructions_recipe ON instructions (recipe_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_pinned ON notes (is_pinned)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_favorite ON notes (is_favorite)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_category ON notes (category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_notes_created ON notes (created_at)');

    // Seed 200 authentic Indian and Malnad recipes
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    final batch = db.batch();

    // Insert categories
    for (final cat in SeedData.categories) {
      batch.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert recipes & relations
    for (final recipe in SeedData.recipes) {
      final recipeData = {
        'id': recipe['id'],
        'title': recipe['title'],
        'description': recipe['description'],
        'chef_name': recipe['chef_name'],
        'cuisine': recipe['cuisine'],
        'image_url': recipe['image_url'],
        'prep_time_minutes': recipe['prep_time_minutes'],
        'cook_time_minutes': recipe['cook_time_minutes'],
        'servings': recipe['servings'],
        'difficulty': recipe['difficulty'],
        'category_id': recipe['category_id'],
        'tags': recipe['tags'],
        'is_favorite': recipe['is_favorite'] ?? 0,
        'is_custom': recipe['is_custom'] ?? 0,
        'is_vegetarian': recipe['is_vegetarian'] ?? 1,
        'rating': recipe['rating'] ?? 4.8,
        'region': recipe['region'] ?? 'Karnataka',
        'subcategory': recipe['subcategory'] ?? '',
        'nutrition': recipe['nutrition'] ?? '',
        'created_at': recipe['created_at'],
      };
      batch.insert('recipes', recipeData, conflictAlgorithm: ConflictAlgorithm.replace);

      final ingredients = recipe['ingredients'] as List<Map<String, dynamic>>? ?? [];
      for (final ing in ingredients) {
        batch.insert('ingredients', {
          'recipe_id': recipe['id'],
          'name': ing['name'],
          'amount': ing['amount'],
          'unit': ing['unit'],
        });
      }

      final instructions = recipe['instructions'] as List<Map<String, dynamic>>? ?? [];
      for (final inst in instructions) {
        batch.insert('instructions', {
          'recipe_id': recipe['id'],
          'step_number': inst['step_number'],
          'instruction': inst['instruction'],
          'timer_seconds': inst['timer_seconds'],
        });
      }
    }

    await batch.commit(noResult: true);
  }

  Future<void> resetToSeedData() async {
    final db = await database;
    await db.delete('instructions');
    await db.delete('ingredients');
    await db.delete('recipes');
    await db.delete('categories');
    await _seedDatabase(db);
  }
}
