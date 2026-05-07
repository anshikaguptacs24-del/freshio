import 'dart:math';

class Recipe {
  final String id;
  final String name;
  final List<String> ingredients;
  final String image;
  final List<String> steps;

  Recipe({
    String? id,
    required this.name,
    required this.ingredients,
    required this.image,
    required this.steps,
  }) : id = id ?? "${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}";

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "ingredients": ingredients,
        "image": image,
        "steps": steps,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json["id"]?.toString(),
      name: json["name"] ?? 'Tasty Dish',
      ingredients: List<String>.from(json["ingredients"] ?? []),
      image: json["image"] ?? "https://source.unsplash.com/400x300/?food",
      steps: List<String>.from(json["steps"] ?? []),
    );
  }
}