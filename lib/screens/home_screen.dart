import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'auth/register_screen.dart';
import 'cart_screen.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'package:flutter/physics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    // Determine if admin
    final isAdmin = user != null && user.email == 'admin@techhub.com';

    // Hardcoded featured products for demo
    final List<Product> demoFeatured = [
      Product(
        id: 'demo1',
        name: 'ASUS e410',
        price: 24999,
        imageUrl: 'assets/featured_products/asuse410.jpg',
        size: '14"',
        color: 'Blue',
        brand: 'ASUS',
        description: 'Affordable and portable ASUS laptop',
        category: 'Laptops',
        isFeatured: true,
      ),
      Product(
        id: 'demo2',
        name: 'iPhone 12',
        price: 39999,
        imageUrl: 'assets/featured_products/iphone12.jpg',
        size: '6.1"',
        color: 'Black',
        brand: 'Apple',
        description: 'Apple iPhone 12 smartphone',
        category: 'Phones',
        isFeatured: true,
      ),
      Product(
        id: 'demo3',
        name: 'iPhone 15',
        price: 59999,
        imageUrl: 'assets/featured_products/iphone15.jpg',
        size: '6.1"',
        color: 'Blue',
        brand: 'Apple',
        description: 'Latest Apple iPhone 15',
        category: 'Phones',
        isFeatured: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF14171C),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF232A34),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Icon(Icons.devices_other, color: Color(0xFF00D1FF)),
                  const SizedBox(width: 8),
                  const Text('TechHub', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 22)),
                  const Spacer(),
                  SizedBox(
                    width: 320,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: const TextStyle(color: Color(0xFF6C7A89)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF00D1FF)),
                        filled: true,
                        fillColor: const Color(0xFF181C23),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Profile or Dashboard icon (admin only)
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.dashboard, color: Color(0xFF00D1FF)),
                      tooltip: 'Admin Dashboard',
                      onPressed: () {
                        Navigator.of(context).pushNamed('/admin');
                      },
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.person, color: Color(0xFF00D1FF)),
                      tooltip: 'Profile',
                      onPressed: () {
                        Navigator.of(context).pushNamed('/profile');
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
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
                          _categoryCard('assets/brand_logos/apple.jpg', "Apple", "iPhone, iPad", Color(0xFF00D1FF), context),
                          _categoryCard('assets/brand_logos/asus.jpg', "Asus", "Laptops, Phones", Color(0xFF8F00FF), context),
                          _categoryCard('assets/brand_logos/lenovo.jpg', "Lenovo", "Laptops, Tablets", Color(0xFF00FFB0), context),
                          _categoryCard('assets/brand_logos/xiaomi.jpg', "Xiaomi", "Phones, Tablets", Color(0xFFFF005C), context),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Featured Products section
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
                          final allProducts = productProvider.products;
                          final featured = productProvider.featuredProducts.isNotEmpty
                              ? productProvider.featuredProducts
                              : demoFeatured;
                          final filtered = _searchQuery.isEmpty
                              ? featured
                              : allProducts.where((p) =>
                              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                  p.color.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                  p.size.toLowerCase().contains(_searchQuery.toLowerCase())
                          ).toList();
                          final showList = _searchQuery.isNotEmpty ? filtered : featured;
                          if (_searchQuery.isNotEmpty && filtered.isEmpty) {
                            return const Center(child: Text('No products found.', style: TextStyle(color: Color(0xFF6C7A89))));
                          }
                          return SizedBox(
                            height: 220,
                            child: AnimatedBuilder(
                              animation: _slideController,
                              builder: (context, child) {
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: showList.length,
                                  itemBuilder: (context, index) {
                                    final product = showList[index];
                                    Widget imageWidget;
                                    if (product.imageUrl.startsWith('assets/')) {
                                      imageWidget = Hero(
                                        tag: 'product_${product.id}',
                                        child: Image.asset(product.imageUrl, height: 100, fit: BoxFit.contain),
                                      );
                                    } else if (product.imageUrl.isNotEmpty) {
                                      imageWidget = Hero(
                                        tag: 'product_${product.id}',
                                        child: Image.network(product.imageUrl, height: 100, fit: BoxFit.contain),
                                      );
                                    } else {
                                      imageWidget = const Icon(Icons.image, size: 100, color: Color(0xFF6C7A89));
                                    }
                                    final slide = Tween<Offset>(
                                      begin: Offset(0.2 * (index + 1), 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: _slideController,
                                      curve: Interval(0, 1, curve: Curves.easeOutCubic),
                                    ));
                                    return SlideTransition(
                                      position: slide,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              transitionDuration: const Duration(milliseconds: 500),
                                              pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
                                                opacity: animation,
                                                child: _ProductDetailPage(product: product),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
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
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: imageWidget,
                                              ),
                                              Text(product.name, style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF181C23),
        selectedItemColor: const Color(0xFF00D1FF),
        unselectedItemColor: const Color(0xFF6C7A89),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: isAdmin
                ? const Icon(Icons.dashboard)
                : const Icon(Icons.account_circle),
            label: isAdmin ? 'Dashboard' : 'Account',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            // TODO: Navigate to Shop/Products screen
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          } else if (index == 3) {
            if (isAdmin) {
              Navigator.of(context).pushNamed('/admin');
            } else if (user == null) {
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

  void _openCategory(BuildContext context, String brand) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CategoryProductListScreen(brand: brand),
      ),
    );
  }

  Widget _categoryCard(String imagePath, String title, String subtitle, Color accentColor, BuildContext context) {
    return GestureDetector(
      onTap: () => _openCategory(context, title),
      child: Container(
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
      ),
    );
  }
}

class _CategoryProductListScreen extends StatelessWidget {
  final String brand;
  const _CategoryProductListScreen({required this.brand});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF00D1FF);
    return Scaffold(
      appBar: AppBar(
        title: Text('$brand Products', style: const TextStyle(color: Color(0xFF00D1FF))),
        backgroundColor: const Color(0xFF181C23),
        iconTheme: const IconThemeData(color: Color(0xFF00D1FF)),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFF14171C),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          // Filter products by brand/category name in product name (case-insensitive)
          final products = productProvider.products.where((p) => p.name.toLowerCase().contains(brand.toLowerCase())).toList();
          if (products.isEmpty) {
            return Center(
              child: Text('No products found for $brand.', style: const TextStyle(color: Color(0xFF6C7A89))),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                color: const Color(0xFF232A34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: product.imageUrl.startsWith('assets/')
                      ? Image.asset(product.imageUrl, width: 48, height: 48, fit: BoxFit.cover)
                      : (product.imageUrl.isNotEmpty
                      ? Image.network(product.imageUrl, width: 48, height: 48, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 48, color: Color(0xFF6C7A89))),
                  title: Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('₱${product.price}', style: TextStyle(color: accent)),
                  trailing: Icon(Icons.arrow_forward_ios, color: accent, size: 18),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF232A34),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => _ProductDetailSheet(product: product),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductDetailSheet extends StatelessWidget {
  final Product product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF00D1FF);
    final purple = const Color(0xFF9B59B6);
    final yellow = const Color(0xFFFFD600);
    final red = const Color(0xFFFF005C);
    final colorOptions = [accent, purple, yellow, red];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF181C23),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: product.imageUrl.startsWith('assets/')
                    ? Image.asset(product.imageUrl, height: 140)
                    : (product.imageUrl.isNotEmpty
                    ? Image.network(product.imageUrl, height: 140)
                    : const Icon(Icons.image, size: 120, color: Color(0xFF6C7A89))),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('₱${product.price}', style: const TextStyle(fontSize: 20, color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Color: ${product.color}', style: const TextStyle(color: Color(0xFF6C7A89))),
            const SizedBox(height: 8),
            Row(
              children: colorOptions.map((c) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Size: ${product.size}', style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                ),
                // Add more size options if needed
              ],
            ),
            const SizedBox(height: 20),
            const Text('Product details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text(
              '• High-end tech product\n• Great value and performance\n• Sleek, modern design',
              style: TextStyle(color: Color(0xFF6C7A89)),
            ),
            const SizedBox(height: 24),
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
                  // TODO: Implement add to cart logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to cart!')),
                  );
                },
                child: const Text('Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New: Product detail page with Hero animation and fade transition
class _ProductDetailPage extends StatelessWidget {
  final Product product;
  const _ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232A34),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181C23),
        iconTheme: const IconThemeData(color: Color(0xFF00D1FF)),
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'product_${product.id}',
                  child: product.imageUrl.startsWith('assets/')
                      ? Image.asset(product.imageUrl, height: 180)
                      : (product.imageUrl.isNotEmpty
                      ? Image.network(product.imageUrl, height: 180)
                      : const Icon(Icons.image, size: 120, color: Color(0xFF6C7A89))),
                ),
                const SizedBox(height: 20),
                Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00D1FF))),
                const SizedBox(height: 8),
                Text('₱${product.price}', style: const TextStyle(fontSize: 22, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Color: ${product.color}', style: const TextStyle(color: Color(0xFF6C7A89))),
                const SizedBox(height: 8),
                Text('Size: ${product.size}', style: const TextStyle(color: Color(0xFF6C7A89))),
                const SizedBox(height: 24),
                const Text('Product details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text(
                  '• High-end tech product\n• Great value and performance\n• Sleek, modern design',
                  style: TextStyle(color: Color(0xFF6C7A89)),
                ),
                const SizedBox(height: 32),
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
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${product.name} added to cart!')),
                      );
                    },
                    child: const Text('Add to cart'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
