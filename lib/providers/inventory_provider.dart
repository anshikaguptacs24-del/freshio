
// lib/providers/inventory_provider.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../data/models/item.dart';
import '../data/services/local_storage_service.dart';
import '../core/services/notification_service.dart';
import 'package:freshio/data/services/unsplash_service.dart'; 
import 'analytics_provider.dart';

class InventoryProvider extends ChangeNotifier {
  final LocalStorageService _service = LocalStorageService();

  List<Item> _items = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  int _selectedInventoryTab = 0;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  int get selectedInventoryTab => _selectedInventoryTab;

  set selectedInventoryTab(int value) {
    if (_selectedInventoryTab != value) {
      _selectedInventoryTab = value;
      notifyListeners();
    }
  }

  // --- Static Methods (Fixed "Member not found" errors) ---

  /// Checks if an item has passed its expiry date.
  static bool isExpired(Item item) {
    return item.expiry.isBefore(DateTime.now());
  }

  /// Checks if an item is not yet expired but will expire within the next 2 days.
  static bool isExpiringSoon(Item item) {
    final days = item.expiry.difference(DateTime.now()).inDays;
    return !isExpired(item) && days >= 0 && days <= 2;
  }

  // --- Getters (Fixed "Getter not defined" errors) ---

  /// Returns a list of items that are expiring within 2 days.
  List<Item> get expiringSoonItems {
    return _items.where((i) => isExpiringSoon(i) && !i.isWaste).toList();
  }

  /// Returns a list of items that are still fresh (expiring in more than 2 days).
  List<Item> get donatableItems {
    return _items.where((i) {
      final days = i.expiry.difference(DateTime.now()).inDays;
      return !i.isWaste && days > 2;
    }).toList();
  }

  // --- Core Logic ---

  Future<void> loadItems(AnalyticsProvider analytics) async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _service.loadItems();
      _isInitialized = true;
      
      checkForExpired(analytics);

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

  void checkForExpired(AnalyticsProvider analytics) {
    final now = DateTime.now();
    final expiredItems = _items.where((item) => item.expiry.isBefore(now)).toList();

    if (expiredItems.isNotEmpty) {
      for (var item in expiredItems) {
        _items.remove(item);
        analytics.recordWaste(item);
      }
      _save();
    }
  }

  /// Adds a new item, fetches an image from Unsplash, and handles loading states.
  Future<void> addItem({
    required String name, 
    required String category, 
    required DateTime expiry,
    double quantity = 1.0,
    String unit = "pcs",
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? fetchedUrl;
      
      // Attempt to fetch image with a 5-second timeout to prevent infinite buffering
      try {
        fetchedUrl = await UnsplashService().getImageUrl(name).timeout(
          const Duration(seconds: 5),
        );
      } catch (e) {
        debugPrint("Image fetch timed out or failed: $e");
      }

      final finalImageUrl = fetchedUrl ?? 'https://via.placeholder.com/400x300?text=$name';

      final newItem = Item(
        id: "${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}",
        name: name,
        category: category,
        expiry: expiry,
        quantity: quantity,
        unit: unit,
        imageUrl: finalImageUrl, 
      );

      _items.add(newItem);
      await _save();
      
      NotificationService.scheduleItemNotification(newItem);
    } catch (e) {
      debugPrint("Error adding item: $e");
    } finally {
      // STOP the buffering state regardless of success or failure
      _isLoading = false;
      notifyListeners();
    }
  }

  Item? deleteItem(AnalyticsProvider analytics, String id) {
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex == -1) return null;

    final item = _items[itemIndex];
    _items.removeAt(itemIndex);
    
    analytics.recordWaste(item);
    _save();
    return item;
  }

  void updateItem(Item item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _save();
    }
  }

  Item? consumeItem(AnalyticsProvider analytics, String id) {
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex == -1) return null;
    
    final item = _items[itemIndex];
    _items.removeAt(itemIndex);
    
    analytics.recordConsumed(item);
    _save();
    return item;
  }

  Future<void> _save() async {
    await _service.saveItems(_items);
    notifyListeners();
  }
}