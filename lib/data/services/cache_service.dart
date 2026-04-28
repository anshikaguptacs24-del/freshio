import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _recipesKey = 'cached_recipes_data';

  Future<void> saveRecipes(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recipesKey, data);
  }

  Future<String?> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_recipesKey);
  }
}
