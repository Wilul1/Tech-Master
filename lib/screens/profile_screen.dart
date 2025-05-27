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
import 'admin_panel.dart';

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
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalController = TextEditingController();
  final _phoneController = TextEditingController(); // Controller for phone number
  String? _gender;
  DateTime? _birthday;
  File? _profileImage;
  List<OrderModel> _orders = [];
  String? _paymentMethod = 'GCash';
  List<Map<String, String>> _paymentMethods = [];
  List<Map<String, dynamic>> _wishlist = [];
  List<String> _notifications = [];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalController.dispose();
    _phoneController.dispose(); // Dispose phone controller
    super.dispose();
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
      _addressController.text = prefs.getString('profile_address') ?? '';
      _cityController.text = prefs.getString('profile_city') ?? '';
      _provinceController.text = prefs.getString('profile_province') ?? '';
      _postalController.text = prefs.getString('profile_postal') ?? '';
      _phoneController.text = prefs.getString('profile_phone') ?? ''; // Load phone number
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
    await prefs.setString('profile_address', _addressController.text);
    await prefs.setString('profile_city', _cityController.text);
    await prefs.setString('profile_province', _provinceController.text);
    await prefs.setString('profile_postal', _postalController.text);
    await prefs.setString('profile_phone', _phoneController.text); // Save phone number
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

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistJson = prefs.getString('wishlist');
    if (wishlistJson != null) {
      setState(() {
        _wishlist = List<Map<String, dynamic>>.from(jsonDecode(wishlistJson));
      });
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wishlist', jsonEncode(_wishlist));
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notifJson = prefs.getString('notifications');
    if (notifJson != null) {
      setState(() {
        _notifications = List<String>.from(jsonDecode(notifJson));
      });
    } else {
      // Demo notifications
      setState(() {
        _notifications = [
          'Your order #12345 has shipped!',
          'Flash Sale: Up to 50% off on select tech!',
          'Welcome to Tech Hub Nexus!'
        ];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadOrders();
    _loadPaymentMethods();
    _loadWishlist();
    _loadNotifications();
  }

  Future<void> _showPaymentMethodsDialog(BuildContext context) async {
    await showDialog(
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.credit_card, color: Color(0xFF00D1FF)),
                SizedBox(width: 10),
                Text('Payment Methods', style: TextStyle(color: Color(0xFF00D1FF))),
              ],
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181C23),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            value: 'GCash',
                            groupValue: selectedType,
                            activeColor: const Color(0xFF00D1FF),
                            title: Row(
                              children: [
                                Image.asset('assets/brand_logos/gcash.png', width: 28, height: 28, errorBuilder: (_, __, ___) => Icon(Icons.account_balance_wallet, color: Color(0xFF00D1FF))),
                                const SizedBox(width: 8),
                                const Text('GCash', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                              ],
                            ),
                            subtitle: const Text('Pay instantly with your GCash wallet', style: TextStyle(color: Color(0xFF6C7A89), fontSize: 12)),
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
                            title: Row(
                              children: [
                                Icon(Icons.credit_card, color: Color(0xFF00D1FF)),
                                const SizedBox(width: 8),
                                const Text('Card', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                              ],
                            ),
                            subtitle: const Text('Visa, MasterCard, JCB, Amex', style: TextStyle(color: Color(0xFF6C7A89), fontSize: 12)),
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
                  ),
                  const SizedBox(height: 18),
                  if (selectedType == 'GCash')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181C23),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF00D1FF)),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('You will be redirected to GCash for secure payment.', style: TextStyle(color: Color(0xFF6C7A89), fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  if (selectedType == 'Credit Card')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_paymentMethods.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181C23),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFF00D1FF)),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text('No cards added yet. Add a card to pay with Visa, MasterCard, JCB, or Amex.', style: TextStyle(color: Color(0xFF6C7A89), fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        if (_paymentMethods.isNotEmpty)
                          ..._paymentMethods.asMap().entries.map((entry) => Card(
                                color: const Color(0xFF181C23),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: Icon(Icons.credit_card, color: Color(0xFF00D1FF)),
                                  title: Text('**** **** **** ${entry.value['number']?.substring(entry.value['number']!.length - 4) ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  subtitle: Text('${entry.value['holder']}  |  Exp: ${entry.value['expiry']}', style: const TextStyle(color: Color(0xFF6C7A89))),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Color(0xFF00D1FF)),
                                        tooltip: 'Edit',
                                        onPressed: () {
                                          cardNumber = entry.value['number'] ?? '';
                                          cardHolder = entry.value['holder'] ?? '';
                                          expiry = entry.value['expiry'] ?? '';
                                          cvv = entry.value['cvv'] ?? '';
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: const Color(0xFF232A34),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        tooltip: 'Remove',
                                        onPressed: () {
                                          setState(() {
                                            _paymentMethods.removeAt(entry.key);
                                          });
                                          _savePaymentMethods();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, color: Color(0xFF00D1FF)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF232A34),
                              foregroundColor: Color(0xFF00D1FF),
                              side: const BorderSide(color: Color(0xFF00D1FF)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF232A34),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Your card details are securely stored and encrypted. Only you can manage your cards.', style: TextStyle(color: Color(0xFF6C7A89), fontSize: 12), textAlign: TextAlign.center),
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

  void _showShippingAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final _shippingAddressController = TextEditingController(text: _addressController.text);
        final _cityControllerDialog = TextEditingController(text: _cityController.text);
        final _provinceControllerDialog = TextEditingController(text: _provinceController.text);
        final _postalControllerDialog = TextEditingController(text: _postalController.text);
        return AlertDialog(
          backgroundColor: const Color(0xFF232A34),
          title: const Text('Shipping Address', style: TextStyle(color: Color(0xFF00D1FF))),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _shippingAddressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Address', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                ),
                TextField(
                  controller: _cityControllerDialog,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'City', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                ),
                TextField(
                  controller: _provinceControllerDialog,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Province', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                ),
                TextField(
                  controller: _postalControllerDialog,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Postal Code', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                ),
              ],
            ),
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
                  _addressController.text = _shippingAddressController.text;
                  _cityController.text = _cityControllerDialog.text;
                  _provinceController.text = _provinceControllerDialog.text;
                  _postalController.text = _postalControllerDialog.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF232A34),
        title: const Text('Help & Support', style: TextStyle(color: Color(0xFF00D1FF))),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('For assistance, contact us:', style: TextStyle(color: Colors.white)),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.email, color: Color(0xFF00D1FF)),
                  SizedBox(width: 8),
                  Text('support@techhubnexus.com', style: TextStyle(color: Color(0xFF00D1FF))),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, color: Color(0xFF00D1FF)),
                  SizedBox(width: 8),
                  Text('+63 912 345 6789', style: TextStyle(color: Color(0xFF00D1FF))),
                ],
              ),
              SizedBox(height: 16),
              Text('You can also reach us via the in-app chat or FAQ section.', style: TextStyle(color: Color(0xFF6C7A89))),
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
  }

  void _showWishlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF232A34),
        title: const Text('Wishlist', style: TextStyle(color: Color(0xFF00D1FF))),
        content: SizedBox(
          width: 350,
          child: _wishlist.isEmpty
              ? const Text('Your wishlist is empty.', style: TextStyle(color: Colors.white))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _wishlist.length,
                  itemBuilder: (context, index) {
                    final item = _wishlist[index];
                    return ListTile(
                      leading: item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty
                          ? Image.network(item['imageUrl'], width: 40, height: 40, fit: BoxFit.cover)
                          : const Icon(Icons.favorite, color: Color(0xFF00D1FF)),
                      title: Text(item['name'] ?? '', style: const TextStyle(color: Colors.white)),
                      subtitle: Text(item['brand'] ?? '', style: const TextStyle(color: Color(0xFF6C7A89))),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _wishlist.removeAt(index);
                          });
                          _saveWishlist();
                        },
                      ),
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
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF232A34),
        title: const Text('Notifications', style: TextStyle(color: Color(0xFF00D1FF))),
        content: SizedBox(
          width: 350,
          child: _notifications.isEmpty
              ? const Text('No notifications yet.', style: TextStyle(color: Colors.white))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.notifications, color: Color(0xFF00D1FF)),
                    title: Text(_notifications[index], style: const TextStyle(color: Colors.white)),
                  ),
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
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    String? selectedGender = _gender; // Local variable for gender
    DateTime? selectedBirthday = _birthday; // Local variable for birthday

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Use StatefulBuilder to update dialog content
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF232A34),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Edit Profile', style: TextStyle(color: Color(0xFF00D1FF))),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey, // Reuse the existing form key
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'First Name', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Last Name', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bioController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Bio', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        labelStyle: TextStyle(color: Color(0xFF00D1FF)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF232A34)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00D1FF)),
                        ),
                      ),
                      dropdownColor: const Color(0xFF181C23),
                      style: const TextStyle(color: Colors.white),
                      items: ['Male', 'Female', 'Other', 'Prefer not to say'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedGender = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Birthday Picker
                    TextFormField(
                      controller: _birthdayController, // Use the persistent controller
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Birthday (MM/DD/YYYY)',
                        labelStyle: TextStyle(color: Color(0xFF00D1FF)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF232A34)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00D1FF)),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedBirthday ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF00D1FF), // Header background color
                                  onPrimary: Colors.black, // Header text color
                                  onSurface: Colors.white, // Calendar text color
                                  surface: Color(0xFF232A34), // Calendar background color
                                ),
                                dialogBackgroundColor: const Color(0xFF181C23), // Dialog background
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedBirthday = pickedDate;
                            _birthdayController.text = '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';
                          });
                        }
                      },
                    ),
                     const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController, // Phone number field
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Address', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'City', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _provinceController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Province', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                    ),
                     const SizedBox(height: 12),
                    TextFormField(
                      controller: _postalController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Postal Code', labelStyle: TextStyle(color: Color(0xFF00D1FF))),
                       keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF00D1FF))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D1FF)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Update state variables from local dialog variables
                    setState(() {
                       _gender = selectedGender;
                       _birthday = selectedBirthday;
                    });
                    await _saveProfile();
                    if(mounted) Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
     // Reload profile data after dialog is closed
    _loadProfile();
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
                        _profileMenuItem(
                          context,
                          user?.email == 'admin@techhub.com' ? Icons.admin_panel_settings : Icons.person,
                          user?.email == 'admin@techhub.com' ? 'Admin Panel' : 'Profile',
                          onTap: () {
                            if (user?.email == 'admin@techhub.com') {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                              );
                            } else {
                              _showEditProfileDialog(context);
                            }
                          },
                        ),
                        _profileMenuItem(context, Icons.shopping_bag, 'My Orders', onTap: () {/* TODO: Navigate to orders */}),
                        _profileMenuItem(context, Icons.favorite_border, 'Wishlist', onTap: () => _showWishlistDialog(context)),
                        _profileMenuItem(context, Icons.credit_card, 'Payment Methods', onTap: () => _showPaymentMethodsDialog(context)),
                        _profileMenuItem(context, Icons.local_shipping, 'Shipping Address', onTap: () => _showShippingAddressDialog(context)),
                        _profileMenuItem(context, Icons.notifications_none, 'Notifications', onTap: () => _showNotificationsDialog(context)),
                        _profileMenuItem(context, Icons.help_outline, 'Help & Support', onTap: () => _showHelpSupportDialog(context)),
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
              if (title == 'Profile') {
                // Show profile basic info dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF232A34),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Basic Information', style: TextStyle(color: Color(0xFF00D1FF))),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          _buildInfoRow('First Name:', _firstNameController.text),
                          _buildInfoRow('Last Name:', _lastNameController.text),
                          _buildInfoRow('Email:', Provider.of<AuthProvider>(context, listen: false).user?.email ?? ''),
                          _buildInfoRow('Phone Number:', _phoneController.text),
                          _buildInfoRow('Gender:', _gender ?? ''),
                          _buildInfoRow('Birthday:', _birthdayController.text),
                          _buildInfoRow('Address:', _addressController.text),
                          _buildInfoRow('City:', _cityController.text),
                          _buildInfoRow('Province:', _provinceController.text),
                          _buildInfoRow('Postal Code:', _postalController.text),
                          _buildInfoRow('Bio:', _bioController.text),
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
              } else if (title == 'My Orders') {
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
              } else if (onTap == null) {
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Adjust width as needed
            child: Text('$label', style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value.isNotEmpty ? value : 'N/A', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
