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

  Future<void> saveConsumedCount(int count) async {
    await _storage.setInt("consumed_count", count);
  }

  int getConsumedCount() {
    return _storage.getInt("consumed_count") ?? 0;
  }

  Future<void> saveWastedCount(int count) async {
    await _storage.setInt("wasted_count", count);
  }

  int getWastedCount() {
    return _storage.getInt("wasted_count") ?? 0;
  }

  Future<void> saveCategoryStats(String type, Map<String, int> stats) async {
    await _storage.setString("stats_$type", jsonEncode(stats));
  }

  Map<String, int> getCategoryStats(String type) {
    final data = _storage.getString("stats_$type");
    if (data == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(data);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      debugPrint("Error loading category stats for $type: $e");
      return {};
    }
  }
}