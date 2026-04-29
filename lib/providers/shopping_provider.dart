import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:freshio/data/models/shopping_item.dart';
import 'package:freshio/data/services/storage_service.dart';

class ShoppingProvider with ChangeNotifier {
  List<ShoppingItem> _items = [];
  final StorageService _storage = StorageService();
  static const String _storageKey = 'shopping_items';

  ShoppingProvider() {
    _loadItems();
  }

  List<ShoppingItem> get items => _items;

  Future<void> _loadItems() async {
    final String? itemsJson = _storage.getString(_storageKey);
    if (itemsJson != null) {
      final List<dynamic> decoded = json.decode(itemsJson);
      _items = decoded.map((item) => ShoppingItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveItems() async {
    final String encoded = json.encode(_items.map((item) => item.toJson()).toList());
    await _storage.setString(_storageKey, encoded);
  }

  void addItem(String name) {
    _items.add(
      ShoppingItem(
        id: DateTime.now().toString(),
        name: name,
      ),
    );
    notifyListeners();
    _saveItems();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    _saveItems();
  }

  void toggleBought(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isBought = !_items[index].isBought;
      notifyListeners();
      _saveItems();
    }
  }
}
