import 'package:flutter/material.dart';
import 'product.dart';

class OrderModel {
  final String id;
  final DateTime date;
  final List<Product> products;
  final double total;
  final String status;

  OrderModel({
    required this.id,
    required this.date,
    required this.products,
    required this.total,
    required this.status,
  });
}
