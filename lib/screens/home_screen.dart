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
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3ABEFF),
        elevation: 2,
        title: Row(
          children: [
            Icon(Icons.devices_other, color: Colors.white),
            const SizedBox(width: 8),
            Text('TechHub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: TextField(
              style: const TextStyle(color: Color(0xFF232B3A)),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: Colors.black38),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3ABEFF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.shopping_cart, color: Colors.white), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          }),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF3ABEFF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFFF4F8FB),
                    child: user?.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              user!.photoUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 30,
                            color: Color(0xFFA259FF),
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.displayName ?? 'Tech Hub User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF3ABEFF)),
              title: const Text('Home', style: TextStyle(color: Color(0xFF232B3A))),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Color(0xFF3ABEFF)),
              title: const Text('My Cart', style: TextStyle(color: Color(0xFF232B3A))),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cart feature coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Color(0xFFA259FF)),
              title: const Text('Wishlist', style: TextStyle(color: Color(0xFF232B3A))),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wishlist feature coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFFA3FF12)),
              title: const Text('My Profile', style: TextStyle(color: Color(0xFF232B3A))),
              onTap: () {
                Navigator.pop(context);
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
              },
            ),
            const Divider(color: Color(0xFF3ABEFF)),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFF3B30)),
              title: const Text('Logout', style: TextStyle(color: Color(0xFF232B3A))),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.signOut();
              },
            ),
          ],
        ),
      ),
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
                  child: Image.asset(
                    'assets/banners/techhubnexus.png',
                    fit: BoxFit.cover,
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
                      color: Color(0xFF3ABEFF),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const Text(
                "Browse Categories",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3ABEFF)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _categoryCard('assets/brand_logos/apple.jpg', "Apple", "iPhone, iPad", Color(0xFF3ABEFF)),
                  _categoryCard('assets/brand_logos/asus.jpg', "Asus", "Laptops, Phones", Color(0xFFA259FF)),
                  _categoryCard('assets/brand_logos/lenovo.jpg', "Lenovo", "Laptops, Tablets", Color(0xFFA3FF12)),
                  _categoryCard('assets/brand_logos/xiomi.jpg', "Xiaomi", "Phones, Tablets", Color(0xFFFF3B30)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Products",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3ABEFF)),
                  ),
                  DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value: 'Newest',
                    style: const TextStyle(color: Color(0xFF3ABEFF)),
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(value: 'Newest', child: Text('Newest', style: TextStyle(color: Color(0xFF3ABEFF)))),
                      DropdownMenuItem(value: 'Popular', child: Text('Popular', style: TextStyle(color: Color(0xFFA259FF)))),
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
                      child: Text('No featured products.', style: TextStyle(color: Colors.black54)),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (product.imageUrl.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(product.imageUrl, height: 100, fit: BoxFit.contain),
                                ),
                              Text(product.name, style: const TextStyle(color: Color(0xFF3ABEFF), fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _categoryCard(String imagePath, String title, String subtitle, Color accentColor) {
    return Container(
      width: 150,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
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
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _productCard(String name, String imagePath, Color accentColor) {
    return Container(
      width: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
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
