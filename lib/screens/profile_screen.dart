import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'auth/login_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _gender;
  DateTime? _birthday;
  File? _profileImage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                      children: [
                        // Profile Avatar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF00D1FF),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (user?.photoUrl != null
                                  ? NetworkImage(user!.photoUrl!)
                                  : null) as ImageProvider<Object>?,
                          child: (_profileImage == null && (user?.photoUrl == null))
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _pickImage,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF00D1FF)),
                          ),
                          child: const Text('Change Photo', style: TextStyle(color: Color(0xFF00D1FF))),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@${user?.displayName ?? 'username'}',
                          style: const TextStyle(color: Color(0xFF00D1FF), fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF00D1FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Buyer', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Edit Profile Form
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Edit Profile', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  style: const TextStyle(color: Color(0xFF00D1FF)),
                                  decoration: _inputDecoration('First Name'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  style: const TextStyle(color: Color(0xFF00D1FF)),
                                  decoration: _inputDecoration('Last Name'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bioController,
                            style: const TextStyle(color: Color(0xFF00D1FF)),
                            maxLines: 3,
                            decoration: _inputDecoration('Bio'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _gender,
                                  dropdownColor: const Color(0xFF232A34),
                                  style: const TextStyle(color: Color(0xFF00D1FF)),
                                  decoration: _inputDecoration('Gender'),
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(color: Color(0xFF00D1FF)))),
                                    DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(color: Color(0xFF00D1FF)))),
                                    DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(color: Color(0xFF00D1FF)))),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  style: const TextStyle(color: Color(0xFF00D1FF)),
                                  decoration: _inputDecoration('Birthday').copyWith(
                                    suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF00D1FF)),
                                  ),
                                  controller: TextEditingController(
                                    text: _birthday == null ? '' : '${_birthday!.month}/${_birthday!.day}/${_birthday!.year}',
                                  ),
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.dark().copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: Color(0xFF00D1FF),
                                              onPrimary: Colors.white,
                                              surface: Color(0xFF232A34),
                                              onSurface: Color(0xFF00D1FF),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _birthday = picked;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _saveProfile();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile updated!'),
                                    backgroundColor: Color(0xFF00D1FF),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D1FF),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(160, 40),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Transaction History Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transaction History', style: TextStyle(color: Color(0xFF00D1FF), fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DataTable(
                    headingRowColor: MaterialStateProperty.all(Color(0xFF181C23)),
                    columns: const [
                      DataColumn(label: Text('Date', style: TextStyle(color: Color(0xFF00D1FF)))),
                      DataColumn(label: Text('Type', style: TextStyle(color: Color(0xFF00D1FF)))),
                      DataColumn(label: Text('Amount', style: TextStyle(color: Color(0xFF00D1FF)))),
                      DataColumn(label: Text('Description', style: TextStyle(color: Color(0xFF00D1FF)))),
                    ],
                    rows: const [
                      // Example row
                      DataRow(cells: [
                        DataCell(Text('05/13/2025', style: TextStyle(color: Colors.white70))),
                        DataCell(Text('Purchase', style: TextStyle(color: Colors.white70))),
                        DataCell(Text('1000', style: TextStyle(color: Colors.white70))),
                        DataCell(Text('Bought iPhone 14', style: TextStyle(color: Colors.white70))),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
