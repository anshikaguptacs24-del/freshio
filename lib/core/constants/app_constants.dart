import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> dietOptions = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
    'Gluten-Free',
    'Dairy-Free',
    'Low-Carb',
    'High-Protein',
    'Other'
  ];

  static const List<String> quantityUnits = [
    'kg', 'g', 'L', 'ml', 'pcs', 'packs', 'dozen'
  ];

  static const List<String> itemCategories = [
    'General',
    'Vegetables',
    'Leafy Vegetables',
    'Fruits',
    'Dairy',
    'Bakery',
    'Grains & Cereals',
    'Pulses & Legumes',
    'Meat & Seafood',
    'Frozen Food',
    'Snacks',
    'Beverages',
    'Spices & Condiments',
    'Packaged Food',
    'Other'
  ];

  static List<String> get filteredCategories => itemCategories
      .where((e) => e != null && e.isNotEmpty)
      .cast<String>()
      .toList();

  static List<String> get filteredUnits => quantityUnits
      .where((e) => e != null && e.isNotEmpty)
      .cast<String>()
      .toList();

  static Color getDietColor(String? diet) {
    final d = (diet ?? '').toLowerCase();
    if (d.contains('vegetarian') || d.contains('vegan')) return Colors.green;
    if (d.contains('non-vegetarian')) return Colors.red;
    if (d.contains('keto')) return Colors.orange;
    return Colors.blueGrey;
  }

  static IconData getCategoryIcon(String? category) {
    final c = (category ?? '').toLowerCase();
    if (c.isEmpty) return Icons.category_rounded;
    if (c.contains('vegetable')) return Icons.eco_rounded;
    if (c.contains('fruit')) return Icons.apple_rounded;
    if (c.contains('dairy')) return Icons.water_drop_rounded;
    if (c.contains('bakery')) return Icons.bakery_dining_rounded;
    if (c.contains('meat') || c.contains('seafood')) return Icons.set_meal_rounded;
    if (c.contains('beverage')) return Icons.coffee_rounded;
    if (c.contains('snack')) return Icons.fastfood_rounded;
    if (c.contains('grain') || c.contains('pulse')) return Icons.grass_rounded;
    if (c.contains('frozen')) return Icons.ac_unit_rounded;
    if (c.contains('spice')) return Icons.science_rounded;
    return Icons.category_rounded;
  }

  static IconData getUnitIcon(String? unit) {
    final u = (unit ?? '').toLowerCase();
    if (u.contains('kg') || u.contains('g')) return Icons.scale_rounded;
    if (u.contains('l') || u.contains('ml')) return Icons.opacity_rounded;
    return Icons.inventory_2_rounded;
  }

  static String detectCategory(String? name) {
    final text = (name ?? '').toLowerCase();
    if (text.isEmpty) return 'General';
    
    // Mapping keywords to categories
    final Map<String, List<String>> keywords = {
      'Dairy': ['milk', 'cheese', 'butter', 'yogurt', 'curd', 'cream'],
      'Fruits': ['apple', 'banana', 'orange', 'mango', 'grape', 'berry', 'strawberry', 'pineapple', 'watermelon'],
      'Vegetables': ['carrot', 'potato', 'onion', 'tomato', 'cucumber', 'broccoli', 'cauliflower', 'pepper'],
      'Leafy Vegetables': ['spinach', 'lettuce', 'cabbage', 'kale', 'cilantro', 'mint'],
      'Bakery': ['bread', 'bun', 'cake', 'cookie', 'pastry', 'bagel'],
      'Meat & Seafood': ['chicken', 'beef', 'pork', 'fish', 'egg', 'shrimp', 'meat'],
      'Beverages': ['juice', 'coffee', 'tea', 'soda', 'coke', 'water', 'drink'],
      'Grains & Cereals': ['rice', 'wheat', 'oat', 'quinoa', 'pasta', 'noodle'],
      'Snacks': ['chips', 'chocolate', 'nut', 'popcorn', 'biscuit'],
      'Frozen Food': ['frozen', 'ice cream', 'pizza'],
      'Spices & Condiments': ['salt', 'pepper', 'sugar', 'sauce', 'ketchup', 'oil'],
    };

    for (var entry in keywords.entries) {
      if (entry.value.any((kw) => text.contains(kw))) {
        return entry.key;
      }
    }

    return 'General';
  }

  static int estimateShelfLifeDays(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.isEmpty) return 4;

    if (n.contains('milk')) return 3;
    if (n.contains('cheese')) return 14;
    if (n.contains('banana')) return 2;
    if (n.contains('apple')) return 10;
    if (n.contains('bread')) return 3;
    if (n.contains('spinach')) return 2;
    if (n.contains('meat') || n.contains('chicken')) return 2;
    if (n.contains('rice') || n.contains('pasta')) return 180;

    return 4; // Default
  }
}
