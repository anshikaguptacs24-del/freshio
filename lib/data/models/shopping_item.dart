class ShoppingItem {
  final String id;
  final String name;
  bool isBought;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isBought = false,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "isBought": isBought,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json["id"],
      name: json["name"],
      isBought: json["isBought"] ?? false,
    );
  }
}
