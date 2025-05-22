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

  // Add a copyWith for easier updates
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    String? size,
    String? color,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      color: color ?? this.color,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}