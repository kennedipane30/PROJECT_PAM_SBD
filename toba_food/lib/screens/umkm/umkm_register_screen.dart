import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/umkm_service.dart';

class UmkmRegisterScreen extends StatefulWidget {
  const UmkmRegisterScreen({super.key});

  @override
  State<UmkmRegisterScreen> createState() => _UmkmRegisterScreenState();
}

class _UmkmRegisterScreenState extends State<UmkmRegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  File? _fotoKtp;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  late AnimationController _pulseController;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _fotoKtp = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative top handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentGreen, secondaryGreen],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Ambil Foto KTP",
              style: TextStyle(
                color: darkGreen,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: "Kamera",
                  gradient: [accentGreen, secondaryGreen],
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceButton(
                  icon: Icons.photo_library_rounded,
                  label: "Galeri",
                  gradient: [primaryGreen, darkGreen],
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: secondaryGreen,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fotoKtp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Foto KTP wajib diupload!"),
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
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await UmkmService().registerUmkm(
        _namaController.text,
        _alamatController.text,
        _fotoKtp!,
      );

      if (success) {
        if (!mounted) return;
        _showSuccessDialog();
      } else {
        throw Exception("Gagal mendaftar");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text("Terjadi kesalahan: $e")),
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentGreen.withOpacity(0.2),
                    secondaryGreen.withOpacity(0.2)
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: accentGreen, size: 60),
            ),
            SizedBox(height: 20),
            Text(
              "Pendaftaran Berhasil!",
              style: TextStyle(
                color: darkGreen,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Data Anda sedang diverifikasi oleh Admin. Mohon tunggu persetujuan sebelum mulai berjualan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryGreen,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentGreen, secondaryGreen],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: accentGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Text(
                    "OK, Saya Mengerti",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                                "Daftar Mitra UMKM",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: darkGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Mulai berjualan bersama kami",
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info Card
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6).withOpacity(0.4),
                                    Color(0xFF2563EB).withOpacity(0.4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF3B82F6),
                                            Color(0xFF2563EB)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF3B82F6)
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Lengkapi data usaha Anda untuk mulai berjualan di Toba Food.",
                                        style: TextStyle(
                                          color: secondaryGreen,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 28),

                            // Form Container
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    lightGreen.withOpacity(0.6),
                                    secondaryGreen.withOpacity(0.6),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nama Usaha
                                    _buildLabel("Nama Usaha"),
                                    _buildTextField(
                                      controller: _namaController,
                                      hint: "Contoh: Rumah Makan Toba",
                                      icon: Icons.store_mall_directory_rounded,
                                      iconGradient: [
                                        accentGreen,
                                        secondaryGreen
                                      ],
                                    ),
                                    SizedBox(height: 20),

                                    // Alamat
                                    _buildLabel("Alamat Lengkap"),
                                    _buildTextField(
                                      controller: _alamatController,
                                      hint: "Jln. Sisingamangaraja No. 12...",
                                      icon: Icons.location_on_rounded,
                                      iconGradient: [primaryGreen, darkGreen],
                                      maxLines: 3,
                                    ),
                                    SizedBox(height: 20),

                                    // Upload KTP
                                    _buildLabel("Foto KTP (Identitas)"),
                                    GestureDetector(
                                      onTap: () => _showImageSourceDialog(),
                                      child: Container(
                                        height: 200,
                                        padding: EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _fotoKtp != null
                                                ? [accentGreen, secondaryGreen]
                                                : [
                                                    lightGreen.withOpacity(0.5),
                                                    secondaryGreen
                                                        .withOpacity(0.5),
                                                  ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _fotoKtp != null
                                                  ? accentGreen.withOpacity(0.3)
                                                  : lightGreen.withOpacity(0.2),
                                              blurRadius: 20,
                                              offset: Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: cream,
                                            borderRadius:
                                                BorderRadius.circular(17),
                                          ),
                                          child: _fotoKtp != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(17),
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      Image.file(_fotoKtp!,
                                                          fit: BoxFit.cover),
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.3),
                                                              Colors
                                                                  .transparent,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 12,
                                                        right: 12,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                accentGreen,
                                                                secondaryGreen
                                                              ],
                                                            ),
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: accentGreen
                                                                    .withOpacity(
                                                                        0.4),
                                                                blurRadius: 15,
                                                                offset: Offset(
                                                                    0, 4),
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
                                                )
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            accentGreen
                                                                .withOpacity(
                                                                    0.15),
                                                            secondaryGreen
                                                                .withOpacity(
                                                                    0.15),
                                                          ],
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .add_a_photo_rounded,
                                                        color: primaryGreen,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      "Tap untuk upload KTP",
                                                      style: TextStyle(
                                                        color: secondaryGreen,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
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
                                    primaryGreen,
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
                                                Colors.white),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _submitForm,
                                        borderRadius: BorderRadius.circular(18),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                "DAFTAR SEKARANG",
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        text,
        style: TextStyle(
          color: darkGreen,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required List<Color> iconGradient,
    int maxLines = 1,
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
        maxLines: maxLines,
        style: TextStyle(
          color: darkGreen,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Tidak boleh kosong" : null,
        decoration: InputDecoration(
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
          hintText: hint,
          hintStyle: TextStyle(
            color: secondaryGreen.withOpacity(0.5),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
