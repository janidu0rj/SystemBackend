class CartDTO {
  final int id;
  final String name;
  final int quantity;
  final double price;
  final double? weight;

  CartDTO({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.weight,
  });

  // ✅ Factory constructor for JSON deserialization
  factory CartDTO.fromJson(Map<String, dynamic> json) {
    return CartDTO(
      id: json['id'] as int,
      name: json['name'] ?? '',
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    );
  }
}
