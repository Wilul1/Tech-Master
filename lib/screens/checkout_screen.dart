import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/product.dart';
import 'admin_panel.dart';
import 'admin_account_creator.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double shipping;
  const CheckoutScreen({Key? key, required this.cartItems, required this.shipping}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _aptController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalController = TextEditingController();
  String? _shippingMethod = 'Standard';
  String? _paymentMethod = 'GCash';
  String _promoCode = '';
  bool _adminCreated = false;
  String _lastOrderId = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _aptController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  double get subtotal => widget.cartItems.fold(0, (sum, item) => sum + (item["price"] * item["quantity"]));
  double get shipping => widget.shipping;
  double get total => subtotal + shipping;

  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders');
    List<dynamic> orders = ordersJson != null ? jsonDecode(ordersJson) : [];
    final List<Product> products = widget.cartItems.map((item) => Product(
      id: item['id']?.toString() ?? '',
      name: item['name'] ?? '',
      brand: item['brand'] ?? '',
      price: (item['price'] ?? 0).toDouble(),
      imageUrl: item['image'] ?? '',
      description: item['description'] ?? '',
      category: item['category'] ?? '',
      size: item['size'] ?? '',
      color: item['color'] ?? '',
    )).toList();
    final order = {
      'id': _lastOrderId,
      'date': DateTime.now().toIso8601String(),
      'products': products.map((p) => {
        'id': p.id,
        'name': p.name,
        'brand': p.brand,
        'price': p.price,
        'imageUrl': p.imageUrl,
        'description': p.description,
        'category': p.category,
        'size': p.size,
        'color': p.color,
      }).toList(),
      'total': total,
      'status': 'Processing',
    };
    orders.insert(0, order);
    await prefs.setString('orders', jsonEncode(orders));
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF14171C);
    final Color cardColor = const Color(0xFF232A34);
    final Color accent = const Color(0xFF00D1FF);
    final Color textColor = Colors.white;
    final Color subTextColor = const Color(0xFF6C7A89);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Color(0xFF00D1FF))),
        backgroundColor: const Color(0xFF181C23),
        iconTheme: const IconThemeData(color: Color(0xFF00D1FF)),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Color(0xFF00D1FF)),
            tooltip: 'Admin Panel',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
              );
            },
          ),
          if (!_adminCreated)
            IconButton(
              icon: const Icon(Icons.person_add, color: Color(0xFF00D1FF)),
              tooltip: 'Create Admin Account',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminAccountCreator()),
                );
                if (result == true) {
                  setState(() {
                    _adminCreated = true;
                  });
                }
              },
            ),
        ],
      ),
      backgroundColor: const Color(0xFF14171C),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                color: const Color(0xFF232A34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 12,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.shopping_bag, size: 48, color: Color(0xFF00D1FF)),
                              const SizedBox(height: 8),
                              Text('Checkout', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00D1FF))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('First Name'),
                                validator: (val) => val == null || val.isEmpty ? 'Enter first name' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Last Name'),
                                validator: (val) => val == null || val.isEmpty ? 'Enter last name' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Address'),
                          validator: (val) => val == null || val.isEmpty ? 'Enter address' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('City'),
                                validator: (val) => val == null || val.isEmpty ? 'Enter city' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _provinceController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Province'),
                                validator: (val) => val == null || val.isEmpty ? 'Enter province' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _postalController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration('Postal Code'),
                                validator: (val) => val == null || val.isEmpty ? 'Enter postal code' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _shippingMethod,
                                dropdownColor: const Color(0xFF232A34),
                                style: const TextStyle(color: Color(0xFF00D1FF)),
                                decoration: _inputDecoration('Shipping'),
                                items: const [
                                  DropdownMenuItem(value: 'Standard', child: Text('Standard - ₱20', style: TextStyle(color: Color(0xFF00D1FF)))),
                                  DropdownMenuItem(value: 'Express', child: Text('Express - ₱50', style: TextStyle(color: Color(0xFF00D1FF)))),
                                ],
                                onChanged: (val) => setState(() => _shippingMethod = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          dropdownColor: const Color(0xFF232A34),
                          style: const TextStyle(color: Color(0xFF00D1FF)),
                          decoration: _inputDecoration('Payment Method'),
                          items: const [
                            DropdownMenuItem(value: 'GCash', child: Text('GCash', style: TextStyle(color: Color(0xFF00D1FF)))),
                            DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card', style: TextStyle(color: Color(0xFF00D1FF)))),
                            DropdownMenuItem(value: 'Cash on Delivery', child: Text('Cash on Delivery', style: TextStyle(color: Color(0xFF00D1FF)))),
                          ],
                          onChanged: (val) => setState(() => _paymentMethod = val),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Promo code'),
                          onChanged: (val) => setState(() => _promoCode = val),
                        ),
                        const SizedBox(height: 24),
                        _orderSummary(cardColor, accent, textColor, subTextColor),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final orderId = DateTime.now().millisecondsSinceEpoch.toString();
                                _lastOrderId = orderId;
                                await _saveOrder();
                                final estimatedDelivery = _shippingMethod == 'Express'
                                    ? 'in 1-2 days'
                                    : 'in 3-5 days';
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OrderConfirmationScreen(
                                      orderId: orderId,
                                      estimatedDelivery: estimatedDelivery,
                                    ),
                                  ),
                                );
                              }
                            },
                            label: const Text('PLACE ORDER'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderSummary(Color cardColor, Color accent, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.white)),
              Text('₱$subtotal', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping', style: TextStyle(color: Colors.white)),
              Text('₱$shipping', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.white24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('₱$total', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF00D1FF)),
      filled: true,
      fillColor: const Color(0xFF181C23),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF232A34)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF00D1FF)),
      ),
      hintStyle: const TextStyle(color: Color(0xFF6C7A89)),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final String estimatedDelivery;
  const OrderConfirmationScreen({Key? key, required this.orderId, required this.estimatedDelivery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14171C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            color: const Color(0xFF232A34),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00D1FF), size: 64),
                  const SizedBox(height: 16),
                  const Text('Thank you for your purchase!', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text('Order ID: ', style: TextStyle(color: Colors.white70)),
                      Text(orderId, style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping, color: Colors.white70),
                      const SizedBox(width: 8),
                      const Text('Estimated delivery: ', style: TextStyle(color: Colors.white70)),
                      Text(estimatedDelivery, style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D1FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Back to Home'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00D1FF)),
                          foregroundColor: const Color(0xFF00D1FF),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          // TODO: Implement View My Orders navigation
                        },
                        child: const Text('View My Orders'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
