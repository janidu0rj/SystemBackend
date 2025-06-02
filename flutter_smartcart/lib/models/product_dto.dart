class ProductDTO {
  final String barcode;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String category;
  final String brand;
  final double weight;
  final int shelfNumber;
  final int rowNumber;
  final String imageUrl; // Optional, can be empty

  ProductDTO({
    required this.barcode,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.brand,
    required this.weight,
    required this.shelfNumber,
    required this.rowNumber,
    this.imageUrl = '',
  });

  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    return ProductDTO(
      barcode: json['barcode'] ?? '',
      name: json['productName'] ?? '',
      description: json['productDescription'] ?? '',
      price: (json['productPrice'] ?? 0).toDouble(),
      quantity: json['productQuantity'] ?? 0,
      category: json['productCategory'] ?? '',
      brand: json['productBrand'] ?? '',
      weight: (json['productWeight'] ?? 0).toDouble(),
      shelfNumber: json['productShelfNumber'] ?? 0,
      rowNumber: json['productRowNumber'] ?? 0,
      imageUrl: json['productImage'] ?? '', // Make sure backend sends image URL as string
    );
  }
}
