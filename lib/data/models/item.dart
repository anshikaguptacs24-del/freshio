import 'package:flutter/material.dart';
import 'package:freshio/core/theme/app_theme.dart';

class Item {
  String name;
  String category;
  DateTime expiry;
  bool isWaste;
  double quantity;
  String unit; // Added unit
  double weightKg;

  Item({
    required this.name,
    required this.category,
    required this.expiry,
    this.isWaste = false,
    this.quantity = 1,
    this.unit = "pcs", // Default value
    this.weightKg = 0.5,
  });

  String get status {
    final now = DateTime.now();
    if (isWaste) return "Waste";
    if (expiry.isBefore(now)) return "Expired";
    if (expiry.difference(now).inDays <= 1) return "Expiring Soon";
    return "Fresh";
  }

  Color get color {
    if (isWaste) return AppColors.waste;
    final now = DateTime.now();
    if (expiry.isBefore(now)) return AppColors.expired;
    if (expiry.difference(now).inDays <= 1) return AppColors.expiring;
    return AppColors.fresh;
  }

  // Display quantity with unit
  String get quantityDisplay => "${quantity % 1 == 0 ? quantity.toInt() : quantity} $unit";

  Map<String, dynamic> toJson() => {
        "name": name,
        "category": category,
        "expiry": expiry.toIso8601String(),
        "isWaste": isWaste,
        "quantity": quantity,
        "unit": unit,
        "weightKg": weightKg,
      };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json["name"] ?? "",
      category: json["category"] ?? "General",
      expiry: json["expiry"] != null 
          ? DateTime.parse(json["expiry"]) 
          : DateTime.now().add(const Duration(days: 3)),
      isWaste: json["isWaste"] ?? false,
      quantity: (json["quantity"] ?? 1).toDouble(),
      unit: json["unit"] ?? "pcs",
      weightKg: (json["weightKg"] ?? 0.5).toDouble(),
    );
  }
}