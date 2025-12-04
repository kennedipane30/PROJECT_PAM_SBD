import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descController = TextEditingController();

  // Variabel Tambahan
  String _selectedCategory = 'Makanan';
  File? _selectedImage;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late AnimationController _shineController;

  // List Kategori
  final List<String> _categories = [
    'Makanan',
    'Minuman',
    'Cemilan',
    'Bahan Baku',
  ];

  // Green Nature Palette - Modern & Elegant
  final Color primaryGreen = Color(0xFF3D5A4A);
  final Color secondaryGreen = Color(0xFF6B8E7C);
  final Color lightGreen = Color(0xFFA8C5B5);
  final Color accentGreen = Color(0xFF8FBC8F);
  final Color cream = Color(0xFFF5F1E8);
  final Color darkGreen = Color(0xFF2C3E37);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shineController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Fungsi Pilih Gambar
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi Submit
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success = await ProductService().addProduct(
      nama: _nameController.text,
      harga: _priceController.text,
      stok: _stockController.text,
      deskripsi: _descController.text,
      kategori: _selectedCategory,
      imageFile: _selectedImage,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Produk berhasil ditambahkan!"),
            ],
          ),
          backgroundColor: accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.all(20),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Gagal menambahkan produk"),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cream,
              Colors.white,
              cream,
              lightGreen.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated Background Glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Positioned(
                    top: -150,
                    left: -100 + (_pulseController.value * 30),
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accentGreen
                                .withOpacity(0.2 * _pulseController.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Main Content
              Column(
                children: [
                  // Custom Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      children: [
                        // Back Button
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentGreen, secondaryGreen],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: accentGreen.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(15),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tambah Produk",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: darkGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Isi detail produk baru",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Image Picker Card
                            Container(
                              height: 220,
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _selectedImage != null
                                      ? [accentGreen, secondaryGreen]
                                      : [
                                          lightGreen.withOpacity(0.5),
                                          secondaryGreen.withOpacity(0.5)
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: _selectedImage != null
                                        ? accentGreen.withOpacity(0.3)
                                        : lightGreen.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _pickImage,
                                    borderRadius: BorderRadius.circular(21),
                                    child: Stack(
                                      children: [
                                        if (_selectedImage != null)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(21),
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              child: Image.file(
                                                _selectedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        else
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(24),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        accentGreen
                                                            .withOpacity(0.15),
                                                        secondaryGreen
                                                            .withOpacity(0.15),
                                                      ],
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .add_photo_alternate_rounded,
                                                    size: 48,
                                                    color: primaryGreen,
                                                  ),
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  "Pilih Gambar Produk",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkGreen,
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                Text(
                                                  "Tap untuk memilih dari galeri",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: secondaryGreen,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        // Edit badge when image selected
                                        if (_selectedImage != null)
                                          Positioned(
                                            top: 16,
                                            right: 16,
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    accentGreen,
                                                    secondaryGreen
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: accentGreen
                                                        .withOpacity(0.4),
                                                    blurRadius: 15,
                                                    offset: Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.edit_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Form Fields Container
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    lightGreen.withOpacity(0.6),
                                    secondaryGreen.withOpacity(0.6)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: lightGreen.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(21),
                                ),
                                child: Column(
                                  children: [
                                    // Decorative top
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                accentGreen,
                                                secondaryGreen
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                accentGreen,
                                                primaryGreen
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          width: 40,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                secondaryGreen,
                                                accentGreen
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 24),

                                    // Nama Produk
                                    _buildTextField(
                                      controller: _nameController,
                                      label: 'Nama Produk',
                                      icon: Icons.shopping_bag_outlined,
                                      iconGradient: [
                                        accentGreen,
                                        secondaryGreen
                                      ],
                                    ),
                                    SizedBox(height: 16),

                                    // Harga & Stok Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _priceController,
                                            label: 'Harga',
                                            icon: Icons.attach_money_rounded,
                                            iconGradient: [
                                              primaryGreen,
                                              darkGreen
                                            ],
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: _buildTextField(
                                            controller: _stockController,
                                            label: 'Stok',
                                            icon: Icons.inventory_2_outlined,
                                            iconGradient: [
                                              Color(0xFF2563EB),
                                              Color(0xFF1D4ED8)
                                            ],
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),

                                    // Kategori Dropdown
                                    Container(
                                      decoration: BoxDecoration(
                                        color: cream,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: lightGreen,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedCategory,
                                        dropdownColor: Colors.white,
                                        decoration: InputDecoration(
                                          labelText: 'Kategori',
                                          labelStyle: TextStyle(
                                            color: secondaryGreen,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          prefixIcon: Container(
                                            margin: EdgeInsets.all(12),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFF59E0B),
                                                  Color(0xFFD97706)
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0xFFF59E0B)
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.category_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 18,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: darkGreen,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items:
                                            _categories.map((String category) {
                                          return DropdownMenuItem(
                                            value: category,
                                            child: Text(
                                              category,
                                              style: TextStyle(
                                                color: darkGreen,
                                                fontSize: 14,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() =>
                                              _selectedCategory = newValue!);
                                        },
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: secondaryGreen,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),

                                    // Deskripsi
                                    Container(
                                      decoration: BoxDecoration(
                                        color: cream,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: lightGreen,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _descController,
                                        maxLines: 4,
                                        style: TextStyle(
                                          color: darkGreen,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Deskripsi',
                                          labelStyle: TextStyle(
                                            color: secondaryGreen,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          alignLabelWithHint: true,
                                          prefixIcon: Container(
                                            margin: EdgeInsets.all(12),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF8B5CF6),
                                                  Color(0xFF7C3AED)
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0xFF8B5CF6)
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.description_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 18,
                                          ),
                                        ),
                                        validator: (val) =>
                                            val!.isEmpty ? 'Wajib diisi' : null,
                                      ),
                                    ),
                                    SizedBox(height: 24),

                                    // Decorative bottom
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                accentGreen,
                                                secondaryGreen
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                accentGreen,
                                                primaryGreen
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          width: 40,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                secondaryGreen,
                                                accentGreen
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 28),

                            // Submit Button
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentGreen,
                                    secondaryGreen,
                                    primaryGreen
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentGreen.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _submit,
                                        borderRadius: BorderRadius.circular(18),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cloud_upload_outlined,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                "SIMPAN PRODUK",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget - Custom TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<Color> iconGradient,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: lightGreen,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: darkGreen,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: secondaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: iconGradient),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: iconGradient[0].withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }
}
