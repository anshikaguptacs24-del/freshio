import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/item.dart';
import '../data/services/local_storage_service.dart';
import '../core/services/notification_service.dart';
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

  Future<void> loadItems(BuildContext context) async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _service.loadItems();
      _isInitialized = true;
      
      // Auto check for expired items on load
      checkForExpired(context);

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

  void checkForExpired(BuildContext context) {
    final now = DateTime.now();
    final expiredItems = _items.where((item) => item.expiry.isBefore(now)).toList();

    if (expiredItems.isNotEmpty) {
      final analytics = Provider.of<AnalyticsProvider>(context, listen: false);
      for (var item in expiredItems) {
        _items.remove(item);
        analytics.recordWaste(item);
      }
      _save();
    }
  }

  Future<void> addItem(BuildContext context, Item item) async {
    try {
      _items.add(item);
      await _service.saveItems(_items);
      
      Provider.of<AnalyticsProvider>(context, listen: false).recordAdded(item);
      NotificationService.scheduleItemNotification(item);
      
      // Check if newly added item is already expired (edge case)
      checkForExpired(context);
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding item: $e");
    }
  }

  void deleteItem(BuildContext context, String id) {
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex == -1) return;

    final item = _items[itemIndex];
    _items.removeAt(itemIndex);
    
    // Manual delete is recorded as waste
    Provider.of<AnalyticsProvider>(context, listen: false).recordWaste(item);
    
    _save();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.name} removed (marked as waste) ❌"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void updateItem(Item item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _save();
    }
  }

  void consumeItem(BuildContext context, String id) {
    final itemIndex = _items.indexWhere((i) => i.id == id);
    if (itemIndex == -1) return;
    
    final item = _items[itemIndex];
    _items.removeAt(itemIndex);
    notifyListeners();

    final analytics = Provider.of<AnalyticsProvider>(context, listen: false);
    analytics.recordConsumed(item);

    _save();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🎉 ${item.name} consumed!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.white,
          onPressed: () {
            _items.insert(itemIndex, item);
            analytics.undoConsumed(item);
            _save();
          },
        ),
      ),
    );
  }

  static bool isExpired(Item item) => item.expiry.isBefore(DateTime.now());

  static bool isExpiringSoon(Item item) =>
      item.expiry.difference(DateTime.now()).inDays <= 2 && !isExpired(item);

  void _save() {
    _service.saveItems(_items);
    notifyListeners();
  }
}