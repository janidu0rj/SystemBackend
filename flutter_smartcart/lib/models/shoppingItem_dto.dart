class ShoppingItem {
  final String itemName;
  final int quantity;
  final double weight;
  final int productShelfNumber;
  final int productRowNumber;

  ShoppingItem({
    required this.itemName,
    required this.quantity,
    required this.weight,
    required this.productShelfNumber,
    required this.productRowNumber,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    itemName: json['itemName'],
    quantity: json['quantity'],
    weight: json['weight'],
    productShelfNumber: json['productShelfNumber'],
    productRowNumber: json['productRowNumber'],
  );
}
