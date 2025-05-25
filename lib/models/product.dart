import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String size;
  final String color;
  final String brand;
  final String description;
  final String category;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.size,
    required this.color,
    required this.brand,
    required this.description,
    required this.category,
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
    String? brand,
    String? description,
    String? category,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      category: category ?? this.category,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      size: data['size'] ?? '',
      color: data['color'] ?? '',
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}