import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedRole = 'buyer';
  bool _isLoading = false;
  bool _obscureText = true;

  // Green Nature Palette - Modern & Elegant
  final Color primaryGreen = Color(0xFF3D5A4A);
  final Color secondaryGreen = Color(0xFF6B8E7C);
  final Color lightGreen = Color(0xFFA8C5B5);
  final Color accentGreen = Color(0xFF8FBC8F);
  final Color cream = Color(0xFFF5F1E8);
  final Color darkGreen = Color(0xFF2C3E37);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      print('═══════════════════════════════════');
      print('📤 DATA REGISTRASI:');
      print('   Nama: ${_nameController.text.trim()}');
      print('   Email: ${_emailController.text.trim()}');
      print('   Phone: ${_phoneController.text.trim()}');
      print('   Role: $_selectedRole');
      print('═══════════════════════════════════');

      bool success = await Provider.of<AuthProvider>(context, listen: false)
          .register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passController.text,
        phone: _phoneController.text.trim(),
        role: _selectedRole,
      )
          .timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw Exception(
            'Koneksi timeout. Periksa koneksi internet atau backend Anda.',
          );
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: accentGreen,
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "✅ Registrasi Berhasil sebagai ${_selectedRole == 'buyer' ? 'Pembeli' : 'Penjual'}!",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          String errorMsg = authProvider.errorMessage ??
              "Registrasi Gagal. Email mungkin sudah dipakai.";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(child: Text(errorMsg)),
                ],
              ),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }

      print("❌ ERROR REGISTER: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[800],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "❌ Registrasi Gagal",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  e.toString().replaceAll('Exception: ', ''),
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  "💡 Tips: Pastikan backend Laravel sudah jalan",
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: lightGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: primaryGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Buat Akun Baru",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 10),

                      // Header Icon
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentGreen, secondaryGreen, primaryGreen],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentGreen.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_alt_1,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),

                      Text(
                        "Mari Bergabung!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Lengkapi data diri Anda di bawah ini",
                        style: TextStyle(
                          color: secondaryGreen,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 30),

                      // Card Form dengan Border Hijau
                      Container(
                        constraints: BoxConstraints(maxWidth: 400),
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentGreen, secondaryGreen, primaryGreen],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: accentGreen.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cream,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ornament Decoration
                              _buildOrnamentDecoration(),
                              SizedBox(height: 24),

                              // Nama Lengkap
                              _buildLabel("Nama Lengkap"),
                              _buildTextField(
                                controller: _nameController,
                                hint: "Contoh: Budi Santoso",
                                icon: Icons.person_outline,
                                iconColor: accentGreen,
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return "Nama wajib diisi";
                                  if (val.length < 3)
                                    return "Nama minimal 3 karakter";
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              // Email
                              _buildLabel("Alamat Email"),
                              _buildTextField(
                                controller: _emailController,
                                hint: "nama@email.com",
                                icon: Icons.email_outlined,
                                iconColor: accentGreen,
                                inputType: TextInputType.emailAddress,
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return "Email wajib diisi";
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(val)) {
                                    return "Format email tidak valid";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              // Nomor HP
                              _buildLabel("Nomor HP / WhatsApp"),
                              _buildTextField(
                                controller: _phoneController,
                                hint: "0812xxxxxxxx",
                                icon: Icons.phone_android_outlined,
                                iconColor: accentGreen,
                                inputType: TextInputType.phone,
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return "Nomor HP wajib diisi";
                                  if (val.length < 10)
                                    return "Nomor HP minimal 10 digit";
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),

                              // Password
                              _buildLabel("Password"),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: lightGreen,
                                    width: 1.5,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _passController,
                                  obscureText: _obscureText,
                                  style: TextStyle(color: darkGreen),
                                  validator: (val) {
                                    if (val == null || val.isEmpty)
                                      return "Password wajib diisi";
                                    if (val.length < 6)
                                      return "Password minimal 6 karakter";
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Minimal 6 karakter",
                                    hintStyle: TextStyle(
                                      color: secondaryGreen.withOpacity(0.5),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.all(10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [primaryGreen, darkGreen],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: secondaryGreen,
                                        size: 22,
                                      ),
                                      onPressed: () => setState(
                                          () => _obscureText = !_obscureText),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Role Dropdown
                              _buildLabel("Daftar Sebagai"),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: lightGreen,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedRole,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: accentGreen,
                                    ),
                                    style: TextStyle(
                                      color: darkGreen,
                                      fontSize: 14,
                                    ),
                                    items: [
                                      DropdownMenuItem(
                                        value: "buyer",
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: accentGreen
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.shopping_bag_outlined,
                                                color: accentGreen,
                                                size: 18,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text("Pembeli (Buyer)"),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "seller",
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: secondaryGreen
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.storefront,
                                                color: secondaryGreen,
                                                size: 18,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text("Penjual / UMKM (Seller)"),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      setState(() => _selectedRole = val!);
                                      print(
                                          '🔄 Role diubah menjadi: $_selectedRole');
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 24),

                              // Button Register
                              _isLoading
                                  ? Center(
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(
                                            color: accentGreen,
                                            strokeWidth: 3,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Sedang memproses...",
                                            style: TextStyle(
                                              color: secondaryGreen,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accentGreen,
                                            secondaryGreen,
                                            primaryGreen
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentGreen.withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _register,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          "DAFTAR SEKARANG",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ),
                                    ),

                              SizedBox(height: 20),
                              _buildOrnamentDecoration(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Link Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sudah punya akun? ",
                            style: TextStyle(
                              color: darkGreen.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accentGreen, secondaryGreen],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                "Masuk Disini",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnamentDecoration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accentGreen, secondaryGreen]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [accentGreen, primaryGreen]),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [secondaryGreen, accentGreen]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: darkGreen,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightGreen, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: TextStyle(color: darkGreen),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: secondaryGreen.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor, secondaryGreen],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }
}
