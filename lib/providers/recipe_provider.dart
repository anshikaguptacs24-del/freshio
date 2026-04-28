import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshio/data/models/recipe.dart';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/providers/inventory_provider.dart';
import 'package:freshio/data/services/api_service.dart';
import 'package:freshio/data/services/cache_service.dart';

class RecipeMatch {
  final Recipe recipe;
  final double score;
  final double matchPercentage;
  final List<String> missing;
  final bool hasExpiring;

  RecipeMatch({
    required this.recipe,
    required this.score,
    required this.matchPercentage,
    required this.missing,
    required this.hasExpiring,
  });
}

class RecipeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  RecipeProvider() {
    // Initial fetch
    fetchRecipes();
  }

  Future<void> fetchRecipes({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _recipes.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> rawData = await _apiService.fetchRecipes();
      
      _recipes = rawData.map((data) {
        final String name = data['name'] ?? 'Tasty Dish';
        final String image = data['image'] ?? '';
        return Recipe(
          name: name,
          image: image.isNotEmpty ? image : "https://source.unsplash.com/400x300/?food",
          ingredients: List<String>.from(data['ingredients'] ?? []),
          steps: List<String>.from(data['steps'] ?? []),
        );
      }).toList();
      
      // Save to cache
      await _cacheService.saveRecipes(jsonEncode(rawData));
    } catch (e) {
      // API Failed, try loading from cache
      try {
        final cachedDataStr = await _cacheService.getRecipes();
        if (cachedDataStr != null && cachedDataStr.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(cachedDataStr);
          _recipes = decoded.map((data) {
            final String name = data['name'] ?? 'Tasty Dish';
            final String image = data['image'] ?? '';
            return Recipe(
              name: name,
              image: image.isNotEmpty ? image : "https://source.unsplash.com/400x300/?food",
              ingredients: List<String>.from(data['ingredients'] ?? []),
              steps: List<String>.from(data['steps'] ?? []),
            );
          }).toList();
        } else {
          _error = e.toString().replaceAll('Exception: ', '');
        }
      } catch (cacheError) {
        _error = e.toString().replaceAll('Exception: ', '');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String normalize(String text) {
    return text.toLowerCase().trim();
  }

  List<RecipeMatch> getSmartRecipes(List<Item> items) {
    // 1. Filter out expired items completely
    final validPantry = items.where((i) => !i.isWaste && !InventoryProvider.isExpired(i)).toList();
    
    final availableNames = validPantry.map((e) => normalize(e.name)).toSet();
    final expiringNames = validPantry
        .where((i) => InventoryProvider.isExpiringSoon(i))
        .map((e) => normalize(e.name))
        .toSet();

    List<RecipeMatch> result = [];

    for (var recipe in _recipes) {
      final recipeIngredients = recipe.ingredients.map(normalize).toList();
      
      int availableCount = 0;
      int expiringSoonCount = 0;
      List<String> missing = [];

      for (var ing in recipeIngredients) {
        bool found = false;
        for (var pName in availableNames) {
           if (pName.contains(ing) || ing.contains(pName)) {
             found = true;
             availableCount++;
             if (expiringNames.any((e) => e.contains(pName) || pName.contains(e))) {
               expiringSoonCount++;
             }
             break;
           }
        }
        if (!found) {
          missing.add(ing);
        }
      }

      // 2. Score Formula: (available * 2) + (expiringSoon * 3) - missing
      double score = (availableCount * 2.0) + (expiringSoonCount * 3.0) - missing.length;
      
      // 3. Match % for UI (existing logic)
      double matchPercentage = recipeIngredients.isEmpty ? 0 : availableCount / recipeIngredients.length;

      result.add(
        RecipeMatch(
          recipe: recipe,
          score: score,
          matchPercentage: matchPercentage,
          missing: missing,
          hasExpiring: expiringSoonCount > 0,
        ),
      );
    }

    // 4. Sort by score DESCENDING
    result.sort((a, b) => b.score.compareTo(a.score));

    return result;
  }
}