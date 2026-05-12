import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:freshio/data/models/recipe.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(_baseUrl)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipes = data['recipes'];
      
      return recipes.map((item) {
        return Recipe.fromJson({
          'id': item['id'],
          'name': item['name'],
          'image': item['image'],
          'ingredients': item['ingredients'],
          'steps': item['instructions'], // dummyjson uses 'instructions'
        });
      }).toList();
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }
}
