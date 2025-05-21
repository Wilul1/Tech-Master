import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mock cart items
  List<Map<String, dynamic>> cartItems = [
    {
      "name": "Laptop",
      "price": 1200.0,
      "quantity": 1,
      "image": "https://via.placeholder.com/80",
      "size": "15\"",
      "color": "Grey"
    },
    {
      "name": "Tablet",
      "price": 600.0,
      "quantity": 2,
      "image": "https://via.placeholder.com/80",
      "size": "10\"",
      "color": "Black"
    },
  ];

  String couponCode = "";
  double shipping = 20.0; // Placeholder shipping

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item["price"] * item["quantity"]);
  double get grandTotal => subtotal + shipping;

  void updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]["quantity"] += change;
      if (cartItems[index]["quantity"] < 1) cartItems[index]["quantity"] = 1;
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void applyCoupon() {
    // Placeholder: you can add real coupon logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coupon "$couponCode" applied! (not really)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart', style: TextStyle(color: Color(0xFF00D1FF))),
        backgroundColor: const Color(0xFF181C23),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFF14171C),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty.', style: TextStyle(color: Colors.white54)))
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return isWide
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cart Items List
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF232A34),
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
                                    Row(
                                      children: [
                                        const Text('Shopping Cart', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 22, fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Text('${cartItems.length} Items', style: const TextStyle(color: Color(0xFF6C7A89), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...cartItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF181C23),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(item["image"], width: 60, height: 60, fit: BoxFit.cover),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item["name"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                                  Text('Size: ${item["size"]}  Color: ${item["color"]}', style: const TextStyle(color: Color(0xFF6C7A89), fontSize: 12)),
                                                  TextButton(
                                                    onPressed: () => removeItem(index),
                                                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                                    child: const Text('Remove'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.remove, color: Color(0xFF00D1FF)),
                                                  onPressed: () => updateQuantity(index, -1),
                                                ),
                                                Text('${item["quantity"]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                IconButton(
                                                  icon: Icon(Icons.add, color: Color(0xFF00D1FF)),
                                                  onPressed: () => updateQuantity(index, 1),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            Text('₱${item["price"]}', style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 16),
                                            Text('₱${item["price"] * item["quantity"]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF00D1FF)),
                                      child: const Text('Continue Shopping'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Order Summary
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF232A34),
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
                                        const Text('Items', style: TextStyle(color: Colors.white)),
                                        Text('${cartItems.length}', style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Shipping', style: TextStyle(color: Colors.white)),
                                        DropdownButton<double>(
                                          value: shipping,
                                          dropdownColor: const Color(0xFF232A34),
                                          style: const TextStyle(color: Color(0xFF00D1FF)),
                                          underline: Container(),
                                          items: const [
                                            DropdownMenuItem(value: 20.0, child: Text('Standard - ₱20', style: TextStyle(color: Color(0xFF00D1FF)))),
                                            DropdownMenuItem(value: 50.0, child: Text('Express - ₱50', style: TextStyle(color: Color(0xFF00D1FF)))),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) setState(() => shipping = val);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Promo code',
                                        hintStyle: const TextStyle(color: Color(0xFF6C7A89)),
                                        filled: true,
                                        fillColor: const Color(0xFF181C23),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (val) => couponCode = val,
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00D1FF),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: applyCoupon,
                                        child: const Text('Apply'),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(color: Colors.white24),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Cost', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        Text('₱$grandTotal', style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 18)),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00D1FF),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const CheckoutScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text('CHECKOUT'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Cart Items List
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF232A34),
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
                                    Row(
                                      children: [
                                        const Text('Shopping Cart', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 22, fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Text('${cartItems.length} Items', style: const TextStyle(color: Color(0xFF6C7A89), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ...cartItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF181C23),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(item["image"], width: 60, height: 60, fit: BoxFit.cover),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item["name"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                                  Text('Size: ${item["size"]}  Color: ${item["color"]}', style: const TextStyle(color: Color(0xFF6C7A89), fontSize: 12)),
                                                  TextButton(
                                                    onPressed: () => removeItem(index),
                                                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                                    child: const Text('Remove'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.remove, color: Color(0xFF00D1FF)),
                                                  onPressed: () => updateQuantity(index, -1),
                                                ),
                                                Text('${item["quantity"]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                IconButton(
                                                  icon: Icon(Icons.add, color: Color(0xFF00D1FF)),
                                                  onPressed: () => updateQuantity(index, 1),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            Text('₱${item["price"]}', style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 16),
                                            Text('₱${item["price"] * item["quantity"]}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF00D1FF)),
                                      child: const Text('Continue Shopping'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Order Summary
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF232A34),
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
                                        const Text('Items', style: TextStyle(color: Colors.white)),
                                        Text('${cartItems.length}', style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Shipping', style: TextStyle(color: Colors.white)),
                                        DropdownButton<double>(
                                          value: shipping,
                                          dropdownColor: const Color(0xFF232A34),
                                          style: const TextStyle(color: Color(0xFF00D1FF)),
                                          underline: Container(),
                                          items: const [
                                            DropdownMenuItem(value: 20.0, child: Text('Standard - ₱20', style: TextStyle(color: Color(0xFF00D1FF)))),
                                            DropdownMenuItem(value: 50.0, child: Text('Express - ₱50', style: TextStyle(color: Color(0xFF00D1FF)))),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) setState(() => shipping = val);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: 'Promo code',
                                        hintStyle: const TextStyle(color: Color(0xFF6C7A89)),
                                        filled: true,
                                        fillColor: const Color(0xFF181C23),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (val) => couponCode = val,
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00D1FF),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: applyCoupon,
                                        child: const Text('Apply'),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(color: Colors.white24),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Cost', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        Text('₱$grandTotal', style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 18)),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00D1FF),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const CheckoutScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text('CHECKOUT'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              },
            ),
    );
  }
}