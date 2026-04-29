import 'package:flutter/material.dart';
import '../data/models/item.dart';
import '../data/services/local_storage_service.dart';
import '../core/services/notification_service.dart';

class InventoryProvider extends ChangeNotifier {
  final LocalStorageService _service = LocalStorageService();

  List<Item> _items = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  List<Item> get expiringSoonItems {
    final now = DateTime.now();
    return _items.where((i) {
      final days = i.expiry.difference(now).inDays;
      return !i.isWaste && days >= 0 && days <= 2;
    }).toList();
  }

  List<Item> get donatableItems {
    final now = DateTime.now();
    return _items.where((i) {
      final days = i.expiry.difference(now).inDays;
      return !i.isWaste && days > 2;
    }).toList();
  }

  Future<void> loadItems() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _service.loadItems();
      _isInitialized = true;
      
      // Schedule notifications for loaded items
      for (var item in _items) {
        NotificationService.scheduleItemNotification(item);
      }
    } catch (e) {
      debugPrint("Error loading items: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ////////////////////////////////////////////////////////////
  // ADD
  ////////////////////////////////////////////////////////////

  Future<void> addItem(Item item) async {
    try {
      _items.add(item);
      print("Adding item: ${item.name}. Total items: ${_items.length}");
      await _service.saveItems(_items);
      
      // Schedule notification for new item
      NotificationService.scheduleItemNotification(item);
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding item: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // DELETE
  ////////////////////////////////////////////////////////////

  void deleteItem(int index) {
    _items.removeAt(index);
    _save();
  }

  ////////////////////////////////////////////////////////////
  // UPDATE
  ////////////////////////////////////////////////////////////

  void updateItem(int index, Item item) {
    _items[index] = item;
    _save();
  }

  ////////////////////////////////////////////////////////////
  // AUTO WASTE UPDATE
  ////////////////////////////////////////////////////////////

  void updateWasteStatus() {
    final now = DateTime.now();

    for (var item in _items) {
      if (item.expiry.isBefore(now)) {
        item.isWaste = true;
      }
    }

    notifyListeners();
  }

  ////////////////////////////////////////////////////////////
  // HELPERS
  ////////////////////////////////////////////////////////////

  static bool isExpired(Item item) => item.expiry.isBefore(DateTime.now());

  static bool isExpiringSoon(Item item) =>
      item.expiry.difference(DateTime.now()).inDays <= 2 && !isExpired(item);

  ////////////////////////////////////////////////////////////
  // SAVE
  ////////////////////////////////////////////////////////////

  void _save() {
    _service.saveItems(_items);
    notifyListeners();
  }
}