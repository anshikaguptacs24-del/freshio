import 'package:freshio/data/services/storage_service.dart';

class CacheService {
  static const String _recipesKey = 'cached_recipes_data';
  final StorageService _storage = StorageService();

  Future<void> saveRecipes(String data) async {
    await _storage.setString(_recipesKey, data);
  }

  Future<String?> getRecipes() async {
    return _storage.getString(_recipesKey);
  }
}
