import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:tech_hub_app/screens/products_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance; // Removed Firebase Storage

  // Product management state
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _pickedImage;
  String? _imageUrl;
  String? _editProductId;
  bool isLoading = false;

  // Add a listener for Firebase Auth state changes
  // Removed Firebase Auth listener as we are transitioning to Supabase Auth
  // void _setupFirebaseAuthListener() {
  //   ...
  // }

  @override
  void initState() {
    super.initState();
    // _setupFirebaseAuthListener(); // Removed call to Firebase listener
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    print('Attempting to upload image...');
    try {
      // Check if user is authenticated with Supabase
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session == null) {
        print('User not authenticated with Supabase');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication required to upload images')),
          );
        }
        return null;
      }
      
      // --- Logging for session details before upload ---
      print('Supabase Session BEFORE upload - User ID: ${session.user.id}');
      print('Supabase Session BEFORE upload - User Role: ${session.user.role}'); // Should be 'authenticated'
      print('Supabase Session BEFORE upload - Access Token: ${session.accessToken}');
      // ---------------------------------------------------

      // Create a unique filename using timestamp
      final String fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Use Supabase Storage
      await supabase.Supabase.instance.client.storage
          .from('product-images')
          .upload(
            fileName,
            image,
            fileOptions: const supabase.FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get the public URL
      final String publicUrl = supabase.Supabase.instance.client.storage
          .from('product-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  Future<void> _addOrEditProduct() async {
    setState(() => isLoading = true);
    try {
      String? imageUrl = _imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _uploadImage(_pickedImage!);
         if (imageUrl == null) {
           // Handle upload failure
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image upload failed.')));
           }
           setState(() => isLoading = false);
           return; // Stop if image upload fails
         }
      }
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (_editProductId == null) {
        await _firestore.collection('products').add(data);
      } else {
        await _firestore.collection('products').doc(_editProductId).update(data);
      }
      _clearProductForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _clearProductForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _pickedImage = null;
    _imageUrl = null;
    _editProductId = null;
    setState(() {});
  }

  Future<void> _editProduct(DocumentSnapshot doc) async {
    _nameController.text = doc['name'] ?? '';
    _descController.text = doc['description'] ?? '';
    _priceController.text = doc['price'].toString();
    _imageUrl = doc['imageUrl'];
    _editProductId = doc.id;
    setState(() {});
  }

  Future<void> _deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  void _logout() async {
    await _auth.signOut();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Listen to Supabase Auth state changes instead of Firebase Auth
    return StreamBuilder<supabase.AuthState>( // Changed to Supabase AuthState
      stream: supabase.Supabase.instance.client.auth.onAuthStateChange, // Changed stream
      builder: (context, snapshot) {
        // Show a loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
           print('AdminPanelScreen: Supabase Auth StreamBuilder connectionState: waiting'); // Added log
          return const Scaffold(
            backgroundColor: Color(0xFF14171C),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if the snapshot has data and the session is not null
         print('AdminPanelScreen: Supabase Auth StreamBuilder hasData: ${snapshot.hasData}'); // Added log
         print('AdminPanelScreen: Supabase Auth StreamBuilder data (AuthState): ${snapshot.data}'); // Added log

        final session = snapshot.data?.session; // Get the session from AuthState

         print('AdminPanelScreen: Supabase Session from stream: ${session}'); // Added log
         print('AdminPanelScreen: Supabase Session User: ${session?.user}'); // Added log

        if (session != null && session.user != null) {
          // If a Supabase user is logged in
          // Check if the logged-in user is an admin by reading their role from Firestore.
          // Note: This check is done on the client-side for UI logic. Server-side rules
          // provide the actual security enforcement.
          // We will need a FutureBuilder here to asynchronously get the user's role.
          // TODO: Replace Firestore user role check with Supabase Database user role check later
          return FutureBuilder<Map<String, dynamic>?>( // Changed generic type to Map<String, dynamic>? for Supabase query
            future: supabase.Supabase.instance.client // Use Supabase client
                .from('users')
                .select('role') // Select only the role
                .eq('id', session.user!.id) // Filter by user ID
                .maybeSingle(), // Use maybeSingle for the result
            builder: (context, userDocSnapshot) {
              // Show loading while fetching user role
              if (userDocSnapshot.connectionState == ConnectionState.waiting) {
                print('AdminPanelScreen: FutureBuilder connectionState: waiting');
                return const Scaffold(
                  backgroundColor: Color(0xFF14171C),
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Print the state of the snapshot
              print('AdminPanelScreen: FutureBuilder hasData: ${userDocSnapshot.hasData}');
               // Access data directly from snapshot.data
              print('AdminPanelScreen: Fetched user data from Supabase: ${userDocSnapshot.data}'); // Updated log


              // Check if user data exists and has the admin role
              // Modified check for Supabase query result (Map<String, dynamic>?) 
              final userData = userDocSnapshot.data; // snapshot.data is the Map directly
              final isAdmin = userDocSnapshot.hasData && userData != null && userData['role'] == 'admin'; // Check if data is not null and role is 'admin'

              print('AdminPanelScreen: User data fetched: $userData');
              print('AdminPanelScreen: Is user admin?: ${userData?['role'] == 'admin'}');
              print('AdminPanelScreen: Final isAdmin check: $isAdmin');

              if (isAdmin) {
                // Show the admin panel UI if the user is an admin
                return Scaffold(
                  backgroundColor: const Color(0xFF14171C),
                  appBar: AppBar(
                    title: const Text('Admin Panel'),
                    backgroundColor: const Color(0xFF232A34),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  body: Row(
                    children: [
                      // Sidebar
                      Container(
                        width: 220,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF181C23),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                const SizedBox(width: 18),
                                Image.asset('assets/banners/techhubnexus.png', width: 36, height: 36, errorBuilder: (_, __, ___) => Icon(Icons.dashboard, color: Color(0xFF00D1FF))),
                                const SizedBox(width: 10),
                                const Text('TechHub Admin', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _adminNavItem(Icons.dashboard, 'Dashboard', selected: true),
                            _adminNavItem(Icons.people, 'Users', badge: 12),
                            _adminNavItem(Icons.shopping_bag, 'Products',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProductsScreen()),
                                  );
                                },
                            ),
                            _adminNavItem(Icons.notifications, 'Notifications', badge: 3),
                            _adminNavItem(Icons.settings, 'Settings'),
                            _adminNavItem(Icons.bar_chart, 'Logs & Reports'),
                            // Add Product button (admin only, in sidebar)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.add, color: Color(0xFF00D1FF)),
                                  label: const Text('Add Product', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF232A34),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    side: const BorderSide(color: Color(0xFF00D1FF)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AddProductDialog(),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            _adminNavItem(Icons.logout, 'Logout', onTap: () async {
                              await _auth.signOut();
                              // No need to navigate or set state, StreamBuilder handles it
                            }),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      // Main content - Dashboard View
                      Expanded(
                        child: Container(
                          color: const Color(0xFF181C23),
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
                                    const Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                                    const Spacer(),
                                    SizedBox(
                                      width: 320,
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Search anything... ',
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
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Stack(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.notifications, color: Color(0xFF00D1FF)),
                                          onPressed: () {},
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: Colors.redAccent,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      backgroundColor: const Color(0xFF00D1FF),
                                      child: const Icon(Icons.person, color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Admin', style: TextStyle(color: Colors.white)),
                                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6C7A89)),
                                  ],
                                ),
                              ),
                              // Dashboard cards
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 32,
                                    mainAxisSpacing: 32,
                                    childAspectRatio: 2.2,
                                    children: [
                                      _dashboardCard(Icons.person, 'Total Users', '12,845', '+12.5%', Colors.blue),
                                      _dashboardCard(Icons.people, 'Active Users', '8,932', '+8.2%', Colors.green),
                                      _dashboardCard(Icons.shopping_bag, 'Products', '1,234', '+23.1%', Colors.purple),
                                      _dashboardCard(Icons.attach_money, 'Revenue', '₱1,200,000', '+5.7%', Colors.orange),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // If user document doesn't exist, role is not admin, or fetching failed
                 // Sign out the non-admin user if they somehow reached here
                if (session != null && session.user != null) {
                   // Removed Firebase sign out, using Supabase sign out below
                   // _auth.signOut();
                    print('AdminPanelScreen: User is not admin, signing out from Supabase.'); // Added log
                   supabase.Supabase.instance.client.auth.signOut(); // Use Supabase sign out
                }
                // Show an error message or redirect if needed, for now just show login
                 WidgetsBinding.instance.addPostFrameCallback((_) {
                     ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Access Denied: Not an admin user.')),
                      );
                 });
                return _buildLoginForm(); // Show login form
              }
            },
          );
        }

        // If no Supabase user is logged in, show the login form
        print('AdminPanelScreen: No Supabase session, showing login form.'); // Added log
        return _buildLoginForm();
      },
    );
  }

  // Extracted login form into a separate method for clarity
  Widget _buildLoginForm() {
    return Scaffold(
      backgroundColor: const Color(0xFF14171C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            color: const Color(0xFF181C23),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Admin Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Color(0xFF6C7A89)),
                      filled: true,
                      fillColor: const Color(0xFF232A34),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFF6C7A89)),
                      filled: true,
                      fillColor: const Color(0xFF232A34),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                         // Use Supabase Auth for login
                        try {
                          // Clear Firebase listener if it exists
                          // Note: With full Supabase, the FirebaseAuth listener in initState will be removed later.
                          // For now, ensure it doesn't interfere.

                          print('Attempting Supabase login with email and password...'); // Added log

                          final authResponse = await supabase.Supabase.instance.client.auth.signInWithPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );

                           print('Supabase signInWithPassword response received.'); // Added log
                           if (authResponse.session != null) {
                              print('Supabase login successful. User ID: ${authResponse.session!.user.id}'); // Added log
                              // Supabase Auth state changes will be handled by a new StreamBuilder or listener later
                           } else {
                               print('Supabase signInWithPassword returned NO session. Response: ${authResponse}'); // Added log
                                if (mounted) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Login failed. Please check your credentials.')), // Generic error for no session
                                    );
                                }
                           }

                        } on supabase.AuthException catch (e) {
                          print('Supabase Auth error during login: ${e.message}'); // Added log
                          String message = 'Login failed: ${e.message}';
                           if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)),
                                );
                           }
                        } catch (e) {
                           print('An unexpected error occurred during Supabase login: $e'); // Added log
                           if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(content: Text('An unexpected error occurred: $e')),
                               );
                           }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D1FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  // Add a signup link or button later if needed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _adminNavItem(IconData icon, String label, {bool selected = false, int? badge, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF232A34) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF00D1FF) : Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(color: selected ? const Color(0xFF00D1FF) : Colors.white, fontWeight: FontWeight.w600)),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(IconData icon, String label, String value, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF232A34),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF6C7A89), fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(change, style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  const _AddProductDialog({Key? key}) : super(key: key);

  @override
  __AddProductDialogState createState() => __AddProductDialogState();
}

class __AddProductDialogState extends State<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _pickedImage;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    print('Attempting to pick image...');
    if (_isLoading) return;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('Image picked successfully: ${pickedFile.path}');
        setState(() {
          _pickedImage = File(pickedFile.path);
          print('_pickedImage set: ${_pickedImage != null}');
        });
      } else {
        print('Image picking cancelled or failed.');
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> _uploadImage(File image) async {
    print('Attempting to upload image...');
    try {
      // Check if user is authenticated with Supabase
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session == null) {
        print('User not authenticated with Supabase');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication required to upload images')),
          );
        }
        return null;
      }

      // --- Logging for session details before upload ---
      print('Supabase Session BEFORE upload - User ID: ${session.user.id}');
      print('Supabase Session BEFORE upload - User Role: ${session.user.role}'); // Should be 'authenticated'
      print('Supabase Session BEFORE upload - Access Token: ${session.accessToken}');
      // ---------------------------------------------------

      // Create a unique filename using timestamp
      final String fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Use Supabase Storage
      await supabase.Supabase.instance.client.storage
          .from('product-images')
          .upload(
            fileName,
            image,
            fileOptions: const supabase.FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get the public URL
      final String publicUrl = supabase.Supabase.instance.client.storage
          .from('product-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image to Supabase: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  Future<void> _submitProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    // --- Ensure Supabase session is available before upload ---
    final supabaseClient = supabase.Supabase.instance.client;
    supabase.Session? supabaseSession = supabaseClient.auth.currentSession;

    if (supabaseSession == null) {
       print('Supabase session is null in _submitProduct. Attempting to re-authenticate with Firebase ID token.'); // Added log
       final firebaseUser = FirebaseAuth.instance.currentUser; // Get current Firebase user
       if (firebaseUser != null) {
         try {
            // Force refresh the ID token
            final String? firebaseToken = await firebaseUser.getIdToken(true); // Added `true`
             if (firebaseToken != null) {
                 print('Firebase user found, attempting Supabase sign-in with FRESH ID token in _submitProduct...'); // Updated log
                 // Attempt Supabase sign-in again
                final response = await supabaseClient.auth.signInWithIdToken(
                   idToken: firebaseToken,
                   provider: supabase.OAuthProvider.google,
                 );

                 // Check if session is now available after re-authentication attempt
                 supabaseSession = response.session; // Update supabaseSession variable

                 if (supabaseSession != null) {
                    print('Supabase session successfully established via re-authentication in _submitProduct.'); // Added log
                 } else {
                     print('Supabase re-authentication returned NO session in _submitProduct. Response: ${response}'); // Added log
                 }

             } else {
                print('Firebase user ID token is null during re-authentication attempt.'); // Added log
             }
         } catch (e) {
            print('Error during Supabase re-authentication in _submitProduct: ${e.toString()}'); // Added log
         }

       } else {
          print('No Firebase user found in _submitProduct. Cannot attempt re-authentication.'); // Added log
       }

        // Final check after attempted re-authentication
        if (supabaseSession == null) {
            print('Supabase session is still null after re-authentication attempt. Cannot upload.'); // Added log
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supabase session not active after re-authentication. Please log in again.')),
               );
            }
            setState(() => _isLoading = false);
            return; // Stop the process if session is still null
        }
    }

     print('Supabase session confirmed available in _submitProduct. Proceeding with upload check.'); // Added log
    // ----------------------------------------------------

    String? imageUrl;
    if (_pickedImage != null) {
      print('Image selected, proceeding to upload.'); // Log added
      imageUrl = await _uploadImage(_pickedImage!);
      if (imageUrl == null) {
        // Handle upload failure (message shown in _uploadImage)
        setState(() => _isLoading = false);
        return; // Stop if image upload fails
      }
       print('Image upload successful. URL: $imageUrl'); // Log added
    } else {
       print('No image selected, adding product without image.'); // Log added
    }

    try {
      // Create product data
      final newProduct = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'imageUrl': imageUrl,
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': FirebaseAuth.instance.currentUser?.uid,
      };

      // Add to Firestore
      await _firestore.collection('products').add(newProduct);

      print('Product added to Firestore successfully.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error adding product to Firestore: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a product name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '₱',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Price must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _pickedImage == null
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to upload image', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: _isLoading ? null : () => setState(() => _pickedImage = null),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Product'),
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
