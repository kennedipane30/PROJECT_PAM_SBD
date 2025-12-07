import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;

  File? _newImageFile;
  bool _isLoading = false;

  // Sesuaikan dengan konfigurasi IP Anda
  final String _imageBaseUrl = "http://10.0.2.2:8000/storage/";

  // --- PALET WARNA (Sama seperti Home) ---
  final Color primaryGreen = const Color(0xFF3D5A4A);
  final Color secondaryGreen = const Color(0xFF6B8E7C);
  final Color lightGreen = const Color(0xFFA8C5B5);
  final Color accentGreen = const Color(0xFF8FBC8F);
  final Color cream = const Color(0xFFF5F1E8);
  final Color darkGreen = const Color(0xFF2C3E37);

  @override
  void initState() {
    super.initState();
    // Isi data awal dari produk yang dikirim
    _nameController = TextEditingController(text: widget.product.namaProduk);
    _priceController = TextEditingController(text: widget.product.harga.toString());
    _descController = TextEditingController(text: widget.product.deskripsi);
    _categoryController = TextEditingController(text: widget.product.kategori);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // --- FUNGSI PILIH GAMBAR ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  // --- FUNGSI UPDATE PRODUK ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Panggil Service Update
      // Pastikan ProductService Anda memiliki method: 
      // updateProduct(int id, Map<String, String> data, File? imageFile)
      
      bool success = await ProductService().updateProduct(
        widget.product.id,
        {
          'nama_produk': _nameController.text,
          'harga': _priceController.text,
          'deskripsi': _descController.text,
          'kategori': _categoryController.text,
        },
        _newImageFile, // Kirim file jika ada perubahan, null jika tidak
      );

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        Navigator.pop(context, true); // Kembali ke Home dan trigger refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Produk berhasil diperbarui!"),
            backgroundColor: primaryGreen,
          ),
        );
      } else {
        _showErrorDialog("Gagal memperbarui produk.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Terjadi kesalahan: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error", style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("OK", style: TextStyle(color: primaryGreen)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Produk",
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentGreen))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SECTION GAMBAR ---
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: cream,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: lightGreen),
                              boxShadow: [
                                BoxShadow(
                                  color: lightGreen.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _newImageFile != null
                                  ? Image.file(_newImageFile!, fit: BoxFit.cover)
                                  : (widget.product.gambar != null
                                      ? Image.network(
                                          "$_imageBaseUrl${widget.product.gambar}",
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Icon(
                                              Icons.broken_image,
                                              color: secondaryGreen),
                                        )
                                      : Icon(Icons.add_a_photo,
                                          size: 50, color: secondaryGreen)),
                            ),
                          ),
                          // Tombol Ganti Foto
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: InkWell(
                              onTap: _pickImage,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black26, blurRadius: 4)
                                  ],
                                ),
                                child: Icon(Icons.camera_alt,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // --- FORM FIELDS ---
                    _buildLabel("Nama Produk"),
                    _buildTextField(
                      controller: _nameController,
                      hint: "Contoh: Keripik Pisang",
                      icon: Icons.fastfood_rounded,
                    ),

                    SizedBox(height: 20),
                    _buildLabel("Harga (Rp)"),
                    _buildTextField(
                      controller: _priceController,
                      hint: "Contoh: 15000",
                      icon: Icons.monetization_on_rounded,
                      inputType: TextInputType.number,
                    ),

                    SizedBox(height: 20),
                    _buildLabel("Kategori"),
                    _buildTextField(
                      controller: _categoryController,
                      hint: "Contoh: Makanan Ringan",
                      icon: Icons.category_rounded,
                    ),

                    SizedBox(height: 20),
                    _buildLabel("Deskripsi"),
                    _buildTextField(
                      controller: _descController,
                      hint: "Jelaskan detail produkmu...",
                      icon: Icons.description_rounded,
                      maxLines: 4,
                    ),

                    SizedBox(height: 40),

                    // --- TOMBOL SIMPAN ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentGreen, secondaryGreen, primaryGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: accentGreen.withOpacity(0.4),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "SIMPAN PERUBAHAN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
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
    );
  }

  // --- HELPER WIDGETS ---
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: secondaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cream, // Background cream seperti search bar home
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lightGreen.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: lightGreen.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        style: TextStyle(color: darkGreen, fontWeight: FontWeight.w500),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Kolom ini tidak boleh kosong';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: accentGreen),
          hintText: hint,
          hintStyle: TextStyle(color: secondaryGreen.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}