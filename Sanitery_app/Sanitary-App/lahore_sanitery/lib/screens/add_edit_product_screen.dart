import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../services/product_repository.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? existingProduct;

  const AddEditProductScreen({super.key, this.existingProduct});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  final TextEditingController _customCategoryController =
      TextEditingController();

  String? _selectedCategory;
  bool _showCustomCategoryField = false;
  String? _pickedImagePath;
  String? _existingImagePath;
  bool _isSavingImage = false;

  bool get _isEditing => widget.existingProduct != null;

  static const List<String> _defaultCategories = [
    'Pipes',
    'Nuts & Bolts',
    'Taps',
    'Fittings',
    'Valves',
    'Tools',
  ];

  @override
  void initState() {
    super.initState();
    final product = widget.existingProduct;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    _selectedCategory = product?.category;
    _existingImagePath = product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  /// Union of the default 6 categories and any custom categories the
  /// client has already created on other products, so the dropdown
  /// always shows everything currently in use plus the standard set.
  List<String> _buildCategoryOptions() {
    final existing = ProductRepository().getAllCategories();
    final combined = <String>{..._defaultCategories, ...existing};
    final sorted = combined.toList()..sort();
    return sorted;
  }

  Future<void> _showImageSourceOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    await _pickImage(source);
  }

  /// FIX: image_picker returns a path inside the app's CACHE
  /// directory, which Android is free to wipe at any time to free up
  /// space (this is exactly what happened to the client's photos).
  /// This copies the picked file into the app's permanent DOCUMENTS
  /// directory, which Android does not clear automatically, and
  /// gives it a unique name so multiple products never collide.
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() => _isSavingImage = true);

      final appDir = await getApplicationDocumentsDirectory();
      final extension = picked.path.split('.').last;
      final permanentFileName = '${const Uuid().v4()}.$extension';
      final permanentFile = await File(picked.path)
          .copy('${appDir.path}/$permanentFileName');

      setState(() {
        _pickedImagePath = permanentFile.path;
        _isSavingImage = false;
      });
    } catch (e) {
      setState(() => _isSavingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Could not open camera. Check camera permission in phone settings.'
                  : 'Could not save the photo. Please try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final finalCategory = _showCustomCategoryField
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    if (finalCategory == null || finalCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a category')),
      );
      return;
    }

    final finalImagePath = _pickedImagePath ?? _existingImagePath ?? '';

    final repository = ProductRepository();
    final product = Product(
      id: widget.existingProduct?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      category: finalCategory,
      price: double.parse(_priceController.text.trim()),
      imagePath: finalImagePath,
      aliases: widget.existingProduct?.aliases ?? [],
      lastUpdated: DateTime.now(),
    );

    if (_isEditing) {
      await repository.updateProduct(product);
    } else {
      await repository.addProduct(product);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${widget.existingProduct!.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ProductRepository().deleteProduct(widget.existingProduct!.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget _buildImagePreview() {
    if (_isSavingImage) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_pickedImagePath != null) {
      return Image.file(File(_pickedImagePath!), fit: BoxFit.cover);
    }
    if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      if (_existingImagePath!.startsWith('http')) {
        return Image.network(
          _existingImagePath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _missingImagePlaceholder(),
        );
      }
      return Image.file(
        File(_existingImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _missingImagePlaceholder(),
      );
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tap to take or choose a photo',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _missingImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Original photo missing —\ntap to add a new one',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryOptions = _buildCategoryOptions();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Product Image',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isSavingImage ? null : _showImageSourceOptions,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Product Name',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Product name is required'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Enter product title',
                  suffixIcon: const Icon(Icons.mic, color: Colors.blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Category',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (!_showCustomCategoryField)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: categoryOptions
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  decoration: InputDecoration(
                    hintText: 'Select category',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (_showCustomCategoryField)
                TextFormField(
                  controller: _customCategoryController,
                  autofocus: true,
                  validator: (value) {
                    if (!_showCustomCategoryField) return null;
                    return (value == null || value.trim().isEmpty)
                        ? 'Enter a category name'
                        : null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter new category name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showCustomCategoryField = !_showCustomCategoryField;
                    if (_showCustomCategoryField) {
                      _selectedCategory = null;
                    } else {
                      _customCategoryController.clear();
                    }
                  });
                },
                icon: Icon(
                  _showCustomCategoryField ? Icons.list : Icons.add,
                  size: 18,
                ),
                label: Text(
                  _showCustomCategoryField
                      ? 'Choose from existing categories'
                      : 'Add a new category',
                ),
              ),
              const SizedBox(height: 12),
              const Text('Price (PKR)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Rs. 0.00',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSavingImage ? null : _saveProduct,
                  child:
                      const Text('Save Product', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}