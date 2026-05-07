import 'package:flutter/material.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/providers/recipe_provider.dart';

class SmartInsight {
  final String message;
  final IconData icon;
  final RecipeMatch? suggestionRecipe;

  SmartInsight({
    required this.message,
    required this.icon,
    this.suggestionRecipe,
  });
}

class SmartAssistantService {
  static SmartInsight generateIntelligence(List<Item> items, RecipeProvider recipeProvider) {
    final expiring = items.where((e) => !e.isWaste && InventoryProvider.isExpiringSoon(e)).toList();
    
    if (expiring.isNotEmpty) {
      final matches = recipeProvider.getSmartRecipes(items);
      final topMatch = matches.isNotEmpty ? matches.first : null;

      if (topMatch != null && topMatch.hasExpiring) {
        return SmartInsight(
          message: "Use your expiring ${expiring.first.name} for ${topMatch.recipe.name}! 🥘",
          icon: Icons.auto_awesome_rounded,
          suggestionRecipe: topMatch,
        );
      } else {
        return SmartInsight(
          message: "You have ${expiring.length} items expiring soon. Use them now! ⚠️",
          icon: Icons.timer_rounded,
        );
      }
    } else if (items.isEmpty) {
      return SmartInsight(
        message: "Your pantry is empty. Let's add some items! 🛒",
        icon: Icons.shopping_basket_rounded,
      );
    }
    
    return SmartInsight(
      message: "Your pantry is looking fresh! 👍",
      icon: Icons.check_circle_outline,
    );
  }
}
