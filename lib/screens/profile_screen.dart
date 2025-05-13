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
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF23252B),
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
                      color: const Color(0xFF23252B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Profile Avatar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
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
                                  color: Colors.grey,
                                ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement change photo
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                          ),
                          child: const Text('Change Photo', style: TextStyle(color: Colors.blueAccent)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@${user?.displayName ?? 'username'}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
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
                      color: const Color(0xFF23252B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration('First Name'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration('Last Name'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bioController,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            decoration: _inputDecoration('Bio'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _gender,
                                  dropdownColor: const Color(0xFF23252B),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration('Gender'),
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(color: Colors.white))),
                                    DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(color: Colors.white))),
                                    DropdownMenuItem(value: 'Other', child: Text('Other', style: TextStyle(color: Colors.white))),
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
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration('Birthday').copyWith(
                                    suffixIcon: Icon(Icons.calendar_today, color: Colors.white54),
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
                                              primary: Colors.blueAccent,
                                              onPrimary: Colors.white,
                                              surface: Color(0xFF23252B),
                                              onSurface: Colors.white,
                                            ),
                                            dialogBackgroundColor: const Color(0xFF181A20),
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
                                activeColor: Colors.blueAccent,
                              ),
                              const Text('Register as Seller', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Save changes
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
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
                color: const Color(0xFF23252B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFF181A20)),
                    columns: const [
                      DataColumn(label: Text('Date', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Type', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Amount', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Description', style: TextStyle(color: Colors.white))),
                    ],
                    rows: const [
                      // Example row
                      DataRow(cells: [
                        DataCell(Text('05/13/2025', style: TextStyle(color: Colors.white70))),
                        DataCell(Text('Purchase', style: TextStyle(color: Colors.white70))),
                        DataCell(Text('1000', style: TextStyle(color: Colors.white70))),
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
    );
  }
}
