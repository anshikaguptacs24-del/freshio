import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/recipes';

  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    final response = await http.get(Uri.parse(_baseUrl)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipes = data['recipes'];
      
      return recipes.map((item) => {
        'name': item['name'],
        'image': item['image'],
        'ingredients': List<String>.from(item['ingredients'] ?? []),
        'steps': List<String>.from(item['instructions'] ?? []),
      }).toList();
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }
}
