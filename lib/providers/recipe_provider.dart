import 'package:flutter/material.dart';
import 'package:freshio/data/models/recipe.dart';
import 'package:freshio/data/models/item.dart';

class RecipeMatch {
  final Recipe recipe;
  final double score;
  final List<String> missing;

  RecipeMatch({
    required this.recipe,
    required this.score,
    required this.missing,
  });
}

class RecipeProvider extends ChangeNotifier {

  final List<Recipe> _recipes = [
    Recipe(
      name: "Tomato Pasta",
      ingredients: ["tomato", "pasta"],
      image: "assets/images/recipes/pasta.jpg",
      steps: [
        "Boil salted water and cook pasta until al dente.",
        "Sauté diced tomatoes in olive oil with garlic.",
        "Season with salt, pepper, and fresh basil.",
        "Toss pasta with the tomato sauce and serve hot.",
      ],
    ),
    Recipe(
      name: "Fresh Salad",
      ingredients: ["apple", "vegetables"],
      image: "assets/images/recipes/salad.jpg",
      steps: [
        "Wash and chop all vegetables and apple.",
        "Mix in a large bowl with olive oil and lemon.",
        "Season with salt and pepper.",
        "Serve immediately and enjoy!",
      ],
    ),
    Recipe(
      name: "Veggie Curry",
      ingredients: ["tomato", "vegetables"],
      image: "assets/images/recipes/curry.jpg",
      steps: [
        "Heat oil in a pan and sauté onions until golden.",
        "Add spices: cumin, turmeric, and coriander.",
        "Add chopped tomatoes and vegetables.",
        "Simmer for 20 minutes and serve with rice.",
      ],
    ),
    Recipe(
      name: "Egg Omelette",
      ingredients: ["egg", "milk"],
      image: "assets/images/recipes/omelette.jpg",
      steps: [
        "Beat eggs with a splash of milk and season.",
        "Heat butter in a non-stick pan over medium heat.",
        "Pour egg mixture and cook until edges set.",
        "Fold and serve immediately.",
      ],
    ),
  ];

  String normalize(String text) {
    return text.toLowerCase().trim();
  }

  List<RecipeMatch> getSmartRecipes(List<Item> items) {

    final available = items
        .where((e) => !e.isWaste)
        .map((e) => normalize(e.name))
        .toList();

    List<RecipeMatch> result = [];

    for (var recipe in _recipes) {

      final ingredients =
          recipe.ingredients.map(normalize).toList();

      final matched =
          ingredients.where((i) => available.contains(i)).toList();

      final missing =
          ingredients.where((i) => !available.contains(i)).toList();

      double score = matched.length / ingredients.length;

      result.add(
        RecipeMatch(
          recipe: recipe,
          score: score,
          missing: missing,
        ),
      );
    }

    result.sort((a, b) => b.score.compareTo(a.score));

    return result;
  }
}