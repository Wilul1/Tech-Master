import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get featuredProducts => _products.where((p) => p.isFeatured).toList();

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }

  void editProduct(String id, Product newProduct) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = newProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
} 