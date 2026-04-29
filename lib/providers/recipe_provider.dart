import 'dart:convert';
import 'package:flutter/foundation.dart';
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

List<dynamic> _decodeJson(String data) => jsonDecode(data) as List<dynamic>;

class RecipeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final CacheService _cacheService = CacheService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  // Cache for matched recipes to avoid recomputing if items haven't changed
  List<RecipeMatch>? _cachedMatches;
  int? _lastItemHash;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  RecipeProvider();

  Future<void> fetchRecipes({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _isInitialized) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> rawData = await _apiService.fetchRecipes();
      
      _recipes = await compute(_parseRecipes, rawData);
      
      // Save to cache
      await _cacheService.saveRecipes(jsonEncode(rawData));
      _isInitialized = true;
    } catch (e) {
      debugPrint("API Fetch failed, trying cache: $e");
      try {
        final cachedDataStr = await _cacheService.getRecipes();
        if (cachedDataStr != null && cachedDataStr.isNotEmpty) {
          final List<dynamic> decoded = await compute(_decodeJson, cachedDataStr);
          final List<Map<String, dynamic>> castedData = decoded.cast<Map<String, dynamic>>();
          _recipes = await compute(_parseRecipes, castedData);
          _isInitialized = true;
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

  static List<Recipe> _parseRecipes(List<dynamic> rawData) {
    return rawData.map((data) {
      final String name = data['name'] ?? 'Tasty Dish';
      final String image = data['image'] ?? '';
      return Recipe(
        name: name,
        image: image.isNotEmpty ? image : "https://source.unsplash.com/400x300/?food",
        ingredients: List<String>.from(data['ingredients'] ?? []),
        steps: List<String>.from(data['steps'] ?? []),
      );
    }).toList();
  }

  static String normalize(String text) {
    return text.toLowerCase().trim();
  }

  List<RecipeMatch> getSmartRecipes(List<Item> items) {
    // Check if we can return cached result
    final currentHash = Object.hashAll(items.map((e) => e.name + e.expiry.toIso8601String() + e.isWaste.toString()));
    if (_cachedMatches != null && _lastItemHash == currentHash) {
      return _cachedMatches!;
    }

    if (_recipes.isEmpty) return [];

    // Optimization: Pre-process pantry items into a Set for O(1) lookup
    final validPantry = items.where((i) => !i.isWaste && !InventoryProvider.isExpired(i)).toList();
    
    final availableNames = validPantry.map((e) => normalize(e.name)).toSet();
    final expiringNames = validPantry
        .where((i) => InventoryProvider.isExpiringSoon(i))
        .map((e) => normalize(e.name))
        .toSet();

    List<RecipeMatch> result = [];

    for (var recipe in _recipes) {
      int availableCount = 0;
      int expiringSoonCount = 0;
      List<String> missing = [];

      for (var rawIng in recipe.ingredients) {
        final ing = normalize(rawIng);
        bool found = false;
        
        // Check exact match or partial match in available names
        // Since availableNames is a Set, exact match is fast.
        if (availableNames.contains(ing)) {
          found = true;
          availableCount++;
          if (expiringNames.contains(ing)) {
            expiringSoonCount++;
          }
        } else {
          // Fallback to partial matching for items like "Milk" matching "Organic Milk"
          for (var pName in availableNames) {
            if (pName.contains(ing) || ing.contains(pName)) {
              found = true;
              availableCount++;
              if (expiringNames.contains(pName)) {
                expiringSoonCount++;
              }
              break;
            }
          }
        }

        if (!found) {
          missing.add(rawIng);
        }
      }

      double score = (availableCount * 2.0) + (expiringSoonCount * 3.0) - missing.length;
      double matchPercentage = recipe.ingredients.isEmpty ? 0 : availableCount / recipe.ingredients.length;

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

    result.sort((a, b) => b.score.compareTo(a.score));
    
    // Update cache
    _cachedMatches = result;
    _lastItemHash = currentHash;
    
    return result;
  }
}