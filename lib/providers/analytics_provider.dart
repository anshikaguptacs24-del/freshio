import 'package:flutter/material.dart';
import '../data/models/item.dart';
import '../data/services/local_storage_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final LocalStorageService _service = LocalStorageService();

  int _totalConsumed = 0;
  int _totalWasted = 0;
  Map<String, int> _consumedByCategory = {};
  Map<String, int> _wastedByCategory = {};
  Map<String, int> _addedByCategory = {};
  Map<String, int> _consumedPerDay = {};
  Map<String, int> _wastedPerDay = {};

  int get totalConsumed => _totalConsumed;
  int get totalWasted => _totalWasted;
  Map<String, int> get consumedByCategory => _consumedByCategory;
  Map<String, int> get wastedByCategory => _wastedByCategory;
  Map<String, int> get addedByCategory => _addedByCategory;
  Map<String, int> get consumedPerDay => _consumedPerDay;
  Map<String, int> get wastedPerDay => _wastedPerDay;

  AnalyticsProvider() {
    _loadStats();
  }

  Future<void> _loadStats() async {
    _totalConsumed = _service.getConsumedCount();
    _totalWasted = _service.getWastedCount();
    _consumedByCategory = _service.getCategoryStats("consumed");
    _wastedByCategory = _service.getCategoryStats("wasted");
    _addedByCategory = _service.getCategoryStats("added");
    _consumedPerDay = _service.getCategoryStats("consumed_daily");
    _wastedPerDay = _service.getCategoryStats("wasted_daily");
    notifyListeners();
  }

  void recordConsumed(Item item) {
    _totalConsumed++;
    _service.saveConsumedCount(_totalConsumed);

    _consumedByCategory[item.category] = (_consumedByCategory[item.category] ?? 0) + 1;
    _service.saveCategoryStats("consumed", _consumedByCategory);

    final day = _normalizeDate(DateTime.now());
    _consumedPerDay[day] = (_consumedPerDay[day] ?? 0) + 1;
    _service.saveCategoryStats("consumed_daily", _consumedPerDay);

    notifyListeners();
  }

  void recordWaste(Item item) {
    _totalWasted++;
    _service.saveWastedCount(_totalWasted);

    _wastedByCategory[item.category] = (_wastedByCategory[item.category] ?? 0) + 1;
    _service.saveCategoryStats("wasted", _wastedByCategory);

    final day = _normalizeDate(DateTime.now());
    _wastedPerDay[day] = (_wastedPerDay[day] ?? 0) + 1;
    _service.saveCategoryStats("wasted_daily", _wastedPerDay);

    notifyListeners();
  }

  void recordAdded(Item item) {
    _addedByCategory[item.category] = (_addedByCategory[item.category] ?? 0) + 1;
    _service.saveCategoryStats("added", _addedByCategory);
    notifyListeners();
  }

  void undoConsumed(Item item) {
    if (_totalConsumed > 0) _totalConsumed--;
    _service.saveConsumedCount(_totalConsumed);

    if ((_consumedByCategory[item.category] ?? 0) > 0) {
      _consumedByCategory[item.category] = _consumedByCategory[item.category]! - 1;
    }
    _service.saveCategoryStats("consumed", _consumedByCategory);

    final day = _normalizeDate(DateTime.now());
    if ((_consumedPerDay[day] ?? 0) > 0) {
      _consumedPerDay[day] = _consumedPerDay[day]! - 1;
    }
    _service.saveCategoryStats("consumed_daily", _consumedPerDay);

    notifyListeners();
  }

  String getPersonalizedSuggestion(List<Item> expiringSoonItems) {
    if (_wastedByCategory.isNotEmpty) {
      final worst = _wastedByCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (worst.value >= 2) {
        return "You often waste ${worst.key} — try using it earlier 🥗";
      }
    }

    if (_consumedByCategory.isNotEmpty) {
      final best = _consumedByCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (best.value >= 3) {
        return "You use a lot of ${best.key} — consider buying more 🛒";
      }
    }

    if (expiringSoonItems.isNotEmpty) {
      return "Eat ${expiringSoonItems.first.name} soon, it expires in ${expiringSoonItems.first.expiry.difference(DateTime.now()).inDays} days! ⏳";
    }

    return "You're doing a great job managing your food! 👍";
  }

  String _normalizeDate(DateTime d) => "${d.year}-${d.month}-${d.day}";
}
