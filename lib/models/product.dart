class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String size;
  final String color;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.size,
    required this.color,
    this.isFeatured = false,
  });
} 