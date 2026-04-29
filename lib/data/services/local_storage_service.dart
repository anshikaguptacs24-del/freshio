import 'dart:convert';
import 'package:freshio/data/models/item.dart';
import 'package:freshio/data/services/storage_service.dart';
import 'package:flutter/foundation.dart';

List<dynamic> _parseJson(String data) => jsonDecode(data) as List<dynamic>;

class LocalStorageService {
  final StorageService _storage = StorageService();

  Future<void> saveItems(List<Item> items) async {
    final data = items.map((e) => e.toJson()).toList();
    await _storage.setString("items", jsonEncode(data));
  }

  Future<List<Item>> loadItems() async {
    final data = _storage.getString("items");
    if (data == null) return [];

    try {
      final List<dynamic> decoded = await compute(_parseJson, data);
      return decoded.map((e) => Item.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error loading items: $e");
      return [];
    }
  }
}