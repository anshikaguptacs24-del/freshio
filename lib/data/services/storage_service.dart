import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception("StorageService not initialized. Call init() first.");
    }
    return _prefs!;
  }

  // Helper methods
  Future<bool> setString(String key, String value) => prefs.setString(key, value);
  String? getString(String key) => prefs.getString(key);
  
  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);
  bool? getBool(String key) => prefs.getBool(key);

  Future<bool> remove(String key) => prefs.remove(key);
}
