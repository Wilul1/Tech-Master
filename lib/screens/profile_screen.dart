import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'auth/login_screen.dart';

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
  bool _registerAsSeller = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3ABEFF),
        iconTheme: const IconThemeData(color: Colors.white),
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
                      children: [
                        // Profile Avatar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF3ABEFF),
                          child: user?.photoUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    user!.photoUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement change photo
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF3ABEFF)),
                          ),
                          child: const Text('Change Photo', style: TextStyle(color: Color(0xFF3ABEFF))),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@${user?.displayName ?? 'username'}',
                          style: const TextStyle(color: Color(0xFF232B3A), fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF3ABEFF),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Edit Profile', style: TextStyle(color: Color(0xFF232B3A), fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  style: const TextStyle(color: Color(0xFF232B3A)),
                                  decoration: _inputDecoration('First Name').copyWith(
                                    fillColor: Color(0xFFF4F8FB),
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  style: const TextStyle(color: Color(0xFF232B3A)),
                                  decoration: _inputDecoration('Last Name').copyWith(
                                    fillColor: Color(0xFFF4F8FB),
                                    filled: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bioController,
                            style: const TextStyle(color: Color(0xFF232B3A)),
                            maxLines: 3,
                            decoration: _inputDecoration('Bio').copyWith(
                              fillColor: Color(0xFFF4F8FB),
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _gender,
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(color: Color(0xFF232B3A)),
                                  decoration: _inputDecoration('Gender').copyWith(
                                    fillColor: Color(0xFFF4F8FB),
                                    filled: true,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(color: Color(0xFF232B3A)))),
                                    DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(color: Color(0xFF232B3A)))),
                                    DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(color: Color(0xFF232B3A)))),
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
                                  style: const TextStyle(color: Color(0xFF232B3A)),
                                  decoration: _inputDecoration('Birthday').copyWith(
                                    suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF232B3A)),
                                    fillColor: Color(0xFFF4F8FB),
                                    filled: true,
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
                                          data: ThemeData.light().copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: Color(0xFF3ABEFF),
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Color(0xFF232B3A),
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _registerAsSeller,
                                onChanged: (val) {
                                  setState(() {
                                    _registerAsSeller = val ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF3ABEFF),
                              ),
                              const Text('Register as Seller', style: TextStyle(color: Color(0xFF232B3A))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Save changes
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3ABEFF),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transaction History', style: TextStyle(color: Color(0xFF232B3A), fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF4F8FB)),
                    columns: const [
                      DataColumn(label: Text('Date', style: TextStyle(color: Color(0xFF232B3A)))),
                      DataColumn(label: Text('Type', style: TextStyle(color: Color(0xFF232B3A)))),
                      DataColumn(label: Text('Amount', style: TextStyle(color: Color(0xFF232B3A)))),
                      DataColumn(label: Text('Description', style: TextStyle(color: Color(0xFF232B3A)))),
                    ],
                    rows: const [
                      // Example row
                      DataRow(cells: [
                        DataCell(Text('05/13/2025', style: TextStyle(color: Colors.black54))),
                        DataCell(Text('Purchase', style: TextStyle(color: Colors.black54))),
                        DataCell(Text('1000', style: TextStyle(color: Colors.black54))),
                        DataCell(Text('Bought iPhone 14', style: TextStyle(color: Colors.black54))),
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
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF23252B),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
      hintStyle: const TextStyle(color: Colors.white54),
    );
  }
}
