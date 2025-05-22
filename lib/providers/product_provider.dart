import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get featuredProducts => _products.where((p) => p.isFeatured).toList();

  // Load products from Firestore
  Future<void> loadProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    _products.clear();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      _products.add(Product(
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
      ));
    }
    notifyListeners();
  }

  // Add product to Firestore
  Future<void> addProduct(Product product) async {
    final doc = await FirebaseFirestore.instance.collection('products').add({
      'name': product.name,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'size': product.size,
      'color': product.color,
      'brand': product.brand,
      'description': product.description,
      'category': product.category,
      'isFeatured': product.isFeatured,
    });
    _products.add(product.copyWith(id: doc.id));
    notifyListeners();
  }

  // Edit product in Firestore
  Future<void> editProduct(String id, Product newProduct) async {
    await FirebaseFirestore.instance.collection('products').doc(id).update({
      'name': newProduct.name,
      'price': newProduct.price,
      'imageUrl': newProduct.imageUrl,
      'size': newProduct.size,
      'color': newProduct.color,
      'brand': newProduct.brand,
      'description': newProduct.description,
      'category': newProduct.category,
      'isFeatured': newProduct.isFeatured,
    });
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = newProduct;
      notifyListeners();
    }
  }

  // Delete product from Firestore
  Future<void> deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}