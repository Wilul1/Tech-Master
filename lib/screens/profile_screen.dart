import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../models/product.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _birthdayController = TextEditingController(); // Persistent controller for birthday
  String? _gender;
  DateTime? _birthday;
  File? _profileImage;
  List<OrderModel> _orders = [];
  String? _paymentMethod = 'GCash';
  List<Map<String, String>> _paymentMethods = [];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadOrders();
    _loadPaymentMethods();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('profile_firstName') ?? '';
      _lastNameController.text = prefs.getString('profile_lastName') ?? '';
      _bioController.text = prefs.getString('profile_bio') ?? '';
      _gender = prefs.getString('profile_gender');
      final birthdayString = prefs.getString('profile_birthday');
      if (birthdayString != null && birthdayString.isNotEmpty) {
        _birthday = DateTime.tryParse(birthdayString);
        if (_birthday != null) {
          _birthdayController.text = '${_birthday!.month}/${_birthday!.day}/${_birthday!.year}';
        }
      }
      final imagePath = prefs.getString('profile_image');
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_firstName', _firstNameController.text);
    await prefs.setString('profile_lastName', _lastNameController.text);
    await prefs.setString('profile_bio', _bioController.text);
    await prefs.setString('profile_gender', _gender ?? '');
    await prefs.setString('profile_birthday', _birthday?.toIso8601String() ?? '');
    await prefs.setString('profile_image', _profileImage?.path ?? '');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path); // Save image path immediately
    }
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString('orders');
    if (ordersJson != null) {
      final List<dynamic> decoded = jsonDecode(ordersJson);
      setState(() {
        _orders = decoded.map((e) => OrderModel(
          id: e['id'],
          date: DateTime.parse(e['date']),
          products: (e['products'] as List).map((p) => Product(
            id: p['id'],
            name: p['name'],
            brand: p['brand'],
            price: p['price'],
            imageUrl: p['imageUrl'],
            description: p['description'],
            category: p['category'],
            size: p['size'] ?? '',
            color: p['color'] ?? '',
          )).toList(),
          total: e['total'],
          status: e['status'],
        )).toList();
      });
    }
  }

  Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final methodsJson = prefs.getString('payment_methods');
    if (methodsJson != null) {
      setState(() {
        _paymentMethods = List<Map<String, String>>.from(jsonDecode(methodsJson));
      });
    }
  }

  Future<void> _savePaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_methods', jsonEncode(_paymentMethods));
  }

  void _showPaymentMethodsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String cardNumber = '';
        String cardHolder = '';
        String expiry = '';
        String cvv = '';
        String selectedType = _paymentMethod ?? 'GCash';
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: const Color(0xFF232A34),
            title: const Text('Payment Methods', style: TextStyle(color: Color(0xFF00D1FF))),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'GCash',
                          groupValue: selectedType,
                          activeColor: const Color(0xFF00D1FF),
                          title: const Text('GCash', style: TextStyle(color: Color(0xFF00D1FF))),
                          onChanged: (val) {
                            setState(() {
                              selectedType = val!;
                              _paymentMethod = val;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          value: 'Credit Card',
                          groupValue: selectedType,
                          activeColor: const Color(0xFF00D1FF),
                          title: const Text('Card', style: TextStyle(color: Color(0xFF00D1FF))),
                          onChanged: (val) {
                            setState(() {
                              selectedType = val!;
                              _paymentMethod = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (selectedType == 'Credit Card')
                    Column(
                      children: [
                        if (_paymentMethods.isEmpty)
                          const Text('No cards added.', style: TextStyle(color: Colors.white)),
                        if (_paymentMethods.isNotEmpty)
                          ..._paymentMethods.asMap().entries.map((entry) => ListTile(
                                leading: const Icon(Icons.credit_card, color: Color(0xFF00D1FF)),
                                title: Text('**** **** **** ${entry.value['number']?.substring(entry.value['number']!.length - 4) ?? ''}', style: const TextStyle(color: Colors.white)),
                                subtitle: Text('${entry.value['holder']}  |  Exp: ${entry.value['expiry']}', style: const TextStyle(color: Color(0xFF6C7A89))),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      _paymentMethods.removeAt(entry.key);
                                    });
                                    _savePaymentMethods();
                                  },
                                ),
                                onTap: () {
                                  cardNumber = entry.value['number'] ?? '';
                                  cardHolder = entry.value['holder'] ?? '';
                                  expiry = entry.value['expiry'] ?? '';
                                  cvv = entry.value['cvv'] ?? '';
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF232A34),
                                      title: const Text('Edit Card', style: TextStyle(color: Color(0xFF00D1FF))),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: TextEditingController(text: cardNumber),
                                            style: const TextStyle(color: Colors.white),
                                            decoration: const InputDecoration(labelText: 'Card Number', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                                            onChanged: (val) => cardNumber = val,
                                          ),
                                          TextField(
                                            controller: TextEditingController(text: cardHolder),
                                            style: const TextStyle(color: Colors.white),
                                            decoration: const InputDecoration(labelText: 'Card Holder', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                                            onChanged: (val) => cardHolder = val,
                                          ),
                                          TextField(
                                            controller: TextEditingController(text: expiry),
                                            style: const TextStyle(color: Colors.white),
                                            decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                                            onChanged: (val) => expiry = val,
                                          ),
                                          TextField(
                                            controller: TextEditingController(text: cvv),
                                            style: const TextStyle(color: Colors.white),
                                            decoration: const InputDecoration(labelText: 'CVV', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                                            onChanged: (val) => cvv = val,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF00D1FF))),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D1FF)),
                                          onPressed: () {
                                            setState(() {
                                              _paymentMethods[entry.key] = {
                                                'number': cardNumber,
                                                'holder': cardHolder,
                                                'expiry': expiry,
                                                'cvv': cvv,
                                              };
                                            });
                                            _savePaymentMethods();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, color: Color(0xFF00D1FF)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF232A34), foregroundColor: Color(0xFF00D1FF), side: const BorderSide(color: Color(0xFF00D1FF))),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF232A34),
                                title: const Text('Add Card', style: TextStyle(color: Color(0xFF00D1FF))),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(labelText: 'Card Number', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                                      onChanged: (val) => cardNumber = val,
                                    ),
                                    TextField(
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(labelText: 'Card Holder', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                                      onChanged: (val) => cardHolder = val,
                                    ),
                                    TextField(
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                                      onChanged: (val) => expiry = val,
                                    ),
                                    TextField(
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(labelText: 'CVV', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                                      onChanged: (val) => cvv = val,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF00D1FF))),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D1FF)),
                                    onPressed: () {
                                      if (cardNumber.isNotEmpty && cardHolder.isNotEmpty && expiry.isNotEmpty && cvv.isNotEmpty) {
                                        setState(() {
                                          _paymentMethods.add({
                                            'number': cardNumber,
                                            'holder': cardHolder,
                                            'expiry': expiry,
                                            'cvv': cvv,
                                          });
                                        });
                                        _savePaymentMethods();
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Add Card'),
                                  ),
                                ],
                              ),
                            );
                          },
                          label: const Text('Add Card'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close', style: TextStyle(color: Color(0xFF00D1FF))),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      backgroundColor: const Color(0xFF14171C),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Color(0xFF00D1FF))),
        backgroundColor: const Color(0xFF181C23),
        iconTheme: const IconThemeData(color: Color(0xFF00D1FF)),
        elevation: 2,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView( // <-- Fix overflow by wrapping with scroll view
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture and Email
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: const Color(0xFF00D1FF),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null) as ImageProvider<Object>?,
                    child: (_profileImage == null && (user?.photoUrl == null))
                        ? const Icon(Icons.person, size: 54, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '@${user?.email ?? 'example.com'}',
                    style: const TextStyle(color: Color(0xFF00D1FF), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _pickImage,
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF00D1FF))),
                    child: const Text('Edit Profile', style: TextStyle(color: Color(0xFF00D1FF))),
                  ),
                  const SizedBox(height: 32),
                  // Menu List
                  Container(
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
                      children: [
                        _profileMenuItem(context, Icons.shopping_bag, 'My Orders', onTap: () {/* TODO: Navigate to orders */}),
                        _profileMenuItem(context, Icons.favorite_border, 'Wishlist', onTap: () {/* TODO: Wishlist */}),
                        _profileMenuItem(context, Icons.credit_card, 'Payment Methods', onTap: () => _showPaymentMethodsDialog(context)),
                        _profileMenuItem(context, Icons.local_shipping, 'Shipping Address', onTap: () {/* TODO: Shipping Address */}),
                        _profileMenuItem(context, Icons.notifications_none, 'Notifications', onTap: () {/* TODO: Notifications */}),
                        _profileMenuItem(context, Icons.help_outline, 'Help & Support', onTap: () {/* TODO: Help & Support */}),
                        _profileMenuItem(context, Icons.logout, 'Logout', onTap: () async {
                          await Provider.of<AuthProvider>(context, listen: false).signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        }, isLogout: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileMenuItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap, bool isLogout = false}) {
    return InkWell(
      onTap: isLogout || onTap != null
          ? onTap
          : () {
              if (title == 'My Orders') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF232A34),
                    title: const Text('My Orders', style: TextStyle(color: Color(0xFF00D1FF))),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: _orders.isEmpty
                          ? const Text('No orders yet.', style: TextStyle(color: Colors.white))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return ListTile(
                                  title: Text('Order #${order.id}', style: const TextStyle(color: Colors.white)),
                                  subtitle: Text('Total: ₱${order.total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00D1FF))),
                                  trailing: Text(order.status, style: const TextStyle(color: Color(0xFF6C7A89))),
                                );
                              },
                            ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close', style: TextStyle(color: Color(0xFF00D1FF))),
                      ),
                    ],
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF232A34),
                    title: Text(title, style: const TextStyle(color: Color(0xFF00D1FF))),
                    content: const Text('This feature is coming soon!', style: TextStyle(color: Colors.white)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close', style: TextStyle(color: Color(0xFF00D1FF))),
                      ),
                    ],
                  ),
                );
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isLogout ? Colors.transparent : const Color(0xFF232A34)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.redAccent : const Color(0xFF00D1FF)),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isLogout ? Colors.redAccent : Colors.white,
                  fontSize: 16,
                  fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF6C7A89)),
          ],
        ),
      ),
    );
  }
}
