import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freshio/data/models/item.dart';

class LocalStorageService {

  ////////////////////////////////////////////////////////////
  // SAVE ITEMS
  ////////////////////////////////////////////////////////////

  Future<void> saveItems(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();

    final data = items.map((e) => e.toJson()).toList();

    await prefs.setString("items", jsonEncode(data));
  }

  ////////////////////////////////////////////////////////////
  // LOAD ITEMS
  ////////////////////////////////////////////////////////////

  Future<List<Item>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("items");

    if (data == null) return [];

    final decoded = jsonDecode(data) as List;

    return decoded.map((e) => Item.fromJson(e)).toList();
  }
}