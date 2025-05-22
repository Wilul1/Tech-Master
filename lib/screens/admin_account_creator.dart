import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AdminAccountCreator extends StatefulWidget {
  const AdminAccountCreator({Key? key}) : super(key: key);

  @override
  State<AdminAccountCreator> createState() => _AdminAccountCreatorState();
}

class _AdminAccountCreatorState extends State<AdminAccountCreator> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  String? _message;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() { _loading = true; _message = null; });
    final user = await _authService.registerWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() {
      _loading = false;
      _message = user != null ? 'Admin account created!' : 'Failed to create admin account.';
    });
    if (user != null) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Admin Account')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Admin Email'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 24),
                if (_message != null) ...[
                  Text(_message!, style: TextStyle(color: _message!.contains('created') ? Colors.green : Colors.red)),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _loading ? null : () {
                    if (_formKey.currentState!.validate()) _register();
                  },
                  child: _loading ? const CircularProgressIndicator() : const Text('Create Admin'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
