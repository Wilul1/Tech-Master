import 'package:flutter/material.dart';

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
    final Color bgColor = const Color(0xFFF4F8FB); // Light tech background
    final Color cardColor = Colors.white;
    final Color accent = const Color(0xFF3ABEFF); // Tech blue
    final Color headerColor = const Color(0xFF232B3A); // Slightly dark for header
    final Color textColor = const Color(0xFF232B3A);
    final Color subTextColor = Colors.grey[600]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      backgroundColor: bgColor,
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty.', style: TextStyle(color: Colors.black54)))
          : Column(
              children: [
                // Table header
                Container(
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Row(
                    children: const [
                      SizedBox(width: 80), // For image
                      Expanded(flex: 2, child: Text('Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))),
                      Expanded(child: Text('Size', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))),
                      Expanded(child: Text('Color', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))),
                      Expanded(child: Text('Price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))),
                      Expanded(child: Text('Qty', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))),
                      Expanded(child: Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1))),
                      SizedBox(width: 40), // For remove button
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: Row(
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(item["image"], width: 70, height: 70, fit: BoxFit.cover),
                            ),
                            // Product name/details
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["name"], style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text('Tech product', style: TextStyle(color: subTextColor, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            // Size
                            Expanded(
                              child: Text(item["size"], style: TextStyle(color: subTextColor)),
                            ),
                            // Color
                            Expanded(
                              child: Text(item["color"], style: TextStyle(color: subTextColor)),
                            ),
                            // Price
                            Expanded(
                              child: Text('${item["price"]}', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                            ),
                            // Quantity stepper
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle, color: accent.withOpacity(0.7), size: 22),
                                    onPressed: () => updateQuantity(index, -1),
                                  ),
                                  Text('${item["quantity"]}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: Icon(Icons.add_circle, color: accent, size: 22),
                                    onPressed: () => updateQuantity(index, 1),
                                  ),
                                ],
                              ),
                            ),
                            // Total
                            Expanded(
                              child: Text('${item["price"] * item["quantity"]}', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                            ),
                            // Remove button
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => removeItem(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Coupon code and summary
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: 'Coupon Code',
                                hintStyle: TextStyle(color: subTextColor),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (val) => couponCode = val,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: applyCoupon,
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Subtotal: $subtotal', style: TextStyle(color: textColor)),
                                Text('Shipping: $shipping', style: TextStyle(color: textColor)),
                                const SizedBox(height: 8),
                                Text('Grand Total: $grandTotal', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          // TODO: Implement checkout logic
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proceeding to checkout...')));
                        },
                        child: const Text('PROCEED TO CHECKOUT'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 