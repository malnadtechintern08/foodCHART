import 'package:cookmate/core/database/seed_data.dart';

void main() {
  print('Total recipes: ${SeedData.recipes.length}');
  for (var r in SeedData.recipes) {
    print('${r['id']}|${r['title']}|${r['category_id']}|${r['image_url']}');
  }
}
