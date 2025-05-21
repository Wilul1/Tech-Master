import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

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
      ),
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Shipping Address', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                style: TextStyle(color: textColor),
                                decoration: _inputDecoration('First Name'),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                style: TextStyle(color: textColor),
                                decoration: _inputDecoration('Last Name'),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          style: TextStyle(color: textColor),
                          decoration: _inputDecoration('Street Address'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _aptController,
                          style: TextStyle(color: textColor),
                          decoration: _inputDecoration('Apt / Suite / Unit (Optional)'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                style: TextStyle(color: textColor),
                                decoration: _inputDecoration('City'),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _provinceController,
                                style: TextStyle(color: textColor),
                                decoration: _inputDecoration('Province'),
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _postalController,
                          style: TextStyle(color: textColor),
                          decoration: _inputDecoration('Postal Code'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text('Shipping Method', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                        DropdownButtonFormField<String>(
                          value: _shippingMethod,
                          dropdownColor: cardColor,
                          style: TextStyle(color: accent),
                          decoration: _inputDecoration('Select Shipping'),
                          items: const [
                            DropdownMenuItem(value: 'Standard', child: Text('Standard - ₱20', style: TextStyle(color: Color(0xFF00D1FF)))),
                            DropdownMenuItem(value: 'Express', child: Text('Express - ₱50', style: TextStyle(color: Color(0xFF00D1FF)))),
                          ],
                          onChanged: (val) => setState(() => _shippingMethod = val),
                        ),
                        const SizedBox(height: 24),
                        const Text('Payment Method', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                        DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          dropdownColor: cardColor,
                          style: TextStyle(color: accent),
                          decoration: _inputDecoration('Select Payment'),
                          items: const [
                            DropdownMenuItem(value: 'GCash', child: Text('GCash', style: TextStyle(color: Color(0xFF00D1FF)))),
                            DropdownMenuItem(value: 'PayMaya', child: Text('PayMaya', style: TextStyle(color: Color(0xFF00D1FF)))),
                            DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card', style: TextStyle(color: Color(0xFF00D1FF)))),
                            DropdownMenuItem(value: 'Cash on Delivery', child: Text('Cash on Delivery', style: TextStyle(color: Color(0xFF00D1FF)))),
                          ],
                          onChanged: (val) => setState(() => _paymentMethod = val),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          style: TextStyle(color: textColor),
                          decoration: _inputDecoration('Promo Code'),
                          onChanged: (val) => setState(() => _promoCode = val),
                        ),
                        const SizedBox(height: 24),
                        _orderSummary(cardColor, accent, textColor, subTextColor),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed!')));
                              }
                            },
                            child: const Text('PLACE ORDER'),
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
    double subtotal = 1800.0; // Example subtotal
    double shipping = _shippingMethod == 'Express' ? 50.0 : 20.0;
    double total = subtotal + shipping;
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
