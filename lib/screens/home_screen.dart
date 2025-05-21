import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'auth/register_screen.dart';
import 'cart_screen.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C23), // Dim, techy dark blue/gray
        elevation: 2,
        title: Row(
          children: [
            Icon(Icons.devices_other, color: Color(0xFF00D1FF)), // Neon blue accent
            const SizedBox(width: 8),
            Text('TechHub', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: TextField(
              style: const TextStyle(color: Color(0xFF00D1FF)),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: Color(0xFF6C7A89)),
                filled: true,
                fillColor: Color(0xFF232A34), // Dim input background
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00D1FF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF14171C), // Dim background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner image at the top
              Container(
                width: double.infinity,
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(Color(0xFF181C23).withOpacity(0.7), BlendMode.darken),
                    child: Image.asset(
                      'assets/banners/techhubnexus.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Welcome, \u0000A0${user.displayName ?? 'Tech Hub User'}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00D1FF),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                "Browse Categories",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00D1FF)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _categoryCard('assets/brand_logos/apple.jpg', "Apple", "iPhone, iPad", Color(0xFF00D1FF)),
                  _categoryCard('assets/brand_logos/asus.jpg', "Asus", "Laptops, Phones", Color(0xFF8F00FF)),
                  _categoryCard('assets/brand_logos/lenovo.jpg', "Lenovo", "Laptops, Tablets", Color(0xFF00FFB0)),
                  _categoryCard('assets/brand_logos/xiomi.jpg', "Xiaomi", "Phones, Tablets", Color(0xFFFF005C)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Products",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00D1FF)),
                  ),
                  DropdownButton<String>(
                    dropdownColor: Color(0xFF232A34),
                    value: 'Newest',
                    style: const TextStyle(color: Color(0xFF00D1FF)),
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(value: 'Newest', child: Text('Newest', style: TextStyle(color: Color(0xFF00D1FF)))),
                      DropdownMenuItem(value: 'Popular', child: Text('Popular', style: TextStyle(color: Color(0xFF8F00FF)))),
                    ],
                    onChanged: (value) {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<ProductProvider>(
                builder: (context, productProvider, _) {
                  final featured = productProvider.featuredProducts;
                  if (featured.isEmpty) {
                    return const Center(
                      child: Text('No featured products.', style: TextStyle(color: Color(0xFF6C7A89))),
                    );
                  }
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featured.length,
                      itemBuilder: (context, index) {
                        final product = featured[index];
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF232A34),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (product.imageUrl.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(product.imageUrl, height: 100, fit: BoxFit.contain),
                                ),
                              Text(product.name, style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF181C23),
        selectedItemColor: const Color(0xFF00D1FF),
        unselectedItemColor: const Color(0xFF6C7A89),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: 0, // Always Home for now
        onTap: (index) {
          if (index == 0) return; // Already on Home
          if (index == 1) {
            // TODO: Navigate to Shop/Products screen
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          } else if (index == 3) {
            if (user == null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            }
          }
        },
      ),
    );
  }

  Widget _categoryCard(String imagePath, String title, String subtitle, Color accentColor) {
    return Container(
      width: 150,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF232A34),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: accentColor,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Color(0xFF6C7A89), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _productCard(String name, String imagePath, Color accentColor) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF232A34),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          Text(name, style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
