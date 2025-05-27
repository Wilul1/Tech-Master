import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // Assuming Supabase is still used for image upload

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: ${e.toString()}')),
      );
    }
  }

  // This function will now show the edit dialog
  void _editProduct(DocumentSnapshot productDoc) {
    print('Attempting to show edit product dialog for ID: ${productDoc.id}'); // Log when function is called
    try {
      showDialog(
        context: context,
        builder: (context) => _EditProductDialog(productDoc: productDoc),
      );
      print('Edit product dialog showDialog called successfully.'); // Log after showDialog
    } catch (e) {
      print('Error showing edit product dialog: $e'); // Log any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error showing edit dialog: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: const Color(0xFF232A34),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final data = product.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Text('Price: ₱${(data['price'] ?? 0.0).toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _editProduct(product), // Call edit function
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteProduct(product.id), // Call delete function
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  final DocumentSnapshot productDoc;

  const _EditProductDialog({Key? key, required this.productDoc}) : super(key: key);

  @override
  __EditProductDialogState createState() => __EditProductDialogState();
}

class __EditProductDialogState extends State<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  File? _pickedImage;
  String? _imageUrl; // To store the existing or new image URL
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    final data = widget.productDoc.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name'] ?? '');
    _descController = TextEditingController(text: data['description'] ?? '');
    _priceController = TextEditingController(text: (data['price'] ?? 0.0).toString());
    _imageUrl = data['imageUrl']; // Store existing image URL
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    print('Attempting to pick image for edit...');
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
        print('Image picked successfully for edit: ${pickedFile.path}');
        setState(() {
          _pickedImage = File(pickedFile.path);
          _imageUrl = null; // Clear existing URL if a new image is picked
          print('_pickedImage set for edit: ${_pickedImage != null}');
        });
      } else {
        print('Image picking cancelled or failed for edit.');
      }
    } catch (e) {
      print('Error picking image for edit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> _uploadImage(File image) async {
    print('Attempting to upload image for edit...');
    try {
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session == null) {
        print('User not authenticated with Supabase for image upload (edit).');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication required to upload images')),
          );
        }
        return null;
      }

      final String fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

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

      final String publicUrl = supabase.Supabase.instance.client.storage
          .from('product-images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading image to Supabase (edit): ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: ${e.toString()}')),
        );
      }
      return null;
    }
  }

  Future<void> _updateProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    String? finalImageUrl = _imageUrl; // Start with the existing URL

    // If a new image is picked, upload it
    if (_pickedImage != null) {
      print('New image picked for edit, uploading...');
      finalImageUrl = await _uploadImage(_pickedImage!);
      if (finalImageUrl == null) {
        setState(() => _isLoading = false);
        return; // Stop if upload fails
      }
       print('New image uploaded successfully. URL: $finalImageUrl');
    }

    try {
      final updatedProductData = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'imageUrl': finalImageUrl, // Use the final image URL
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update the product in Firestore
      await _firestore.collection('products').doc(widget.productDoc.id).update(updatedProductData);

      print('Product updated in Firestore successfully.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.pop(context); // Close the dialog
      }
    } catch (e) {
      print('Error updating product in Firestore: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: ${e.toString()}')),
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
                const Text('Edit Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    child: _pickedImage == null // Show picked image if available
                        ? (_imageUrl != null // Otherwise, show existing image if URL is available
                            ? Image.network(_imageUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)))
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Tap to upload image', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ))
                        : Stack(
                            children: [
                              Image.file(_pickedImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: _isLoading ? null : () => setState(() => _pickedImage = null), // Allow removing the newly picked image
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
                    onPressed: _isLoading ? null : _updateProduct, // Call update product function
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2), // Show loading indicator while saving
                          )
                        : const Text('Save Changes'), // Button text
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