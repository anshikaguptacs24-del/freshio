import 'package:flutter/material.dart';
import 'package:freshio/core/theme/app_theme.dart';

class Item {
  String name;
  String category;
  DateTime expiry;
  bool isWaste;
  double quantity;
  double weightKg;

  Item({
    required this.name,
    required this.category,
    required this.expiry,
    this.isWaste = false,
    this.quantity = 1,
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

  Map<String, dynamic> toJson() => {
        "name": name,
        "category": category,
        "expiry": expiry.toIso8601String(),
        "isWaste": isWaste,
        "quantity": quantity,
        "weightKg": weightKg,
      };

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json["name"],
      category: json["category"],
      expiry: DateTime.parse(json["expiry"]),
      isWaste: json["isWaste"],
      quantity: json["quantity"].toDouble(),
      weightKg: json["weightKg"].toDouble(),
    );
  }
}