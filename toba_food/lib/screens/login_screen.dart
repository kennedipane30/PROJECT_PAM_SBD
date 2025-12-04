import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  void _login() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email dan Password tidak boleh kosong"),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).login(_emailController.text, _passController.text);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF3D5A4A),
          content: Text("Login Gagal! Periksa Email/Password."),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Green Nature Palette - Modern & Elegant
    final Color primaryGreen = Color(0xFF3D5A4A);
    final Color secondaryGreen = Color(0xFF6B8E7C);
    final Color lightGreen = Color(0xFFA8C5B5);
    final Color accentGreen = Color(0xFF8FBC8F);
    final Color cream = Color(0xFFF5F1E8);
    final Color darkGreen = Color(0xFF2C3E37);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),

                // --- LOGO dengan Efek Nature Modern ---
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, secondaryGreen, primaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.3),
                        blurRadius: 25,
                        offset: Offset(0, 8),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 45,
                        color: Colors.white,
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.restaurant,
                            size: 16,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // --- BRAND NAME Modern ---
                Text(
                  "TOBA FOOD",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                    letterSpacing: 2.5,
                    shadows: [
                      Shadow(
                        color: accentGreen.withOpacity(0.3),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, secondaryGreen],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.25),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    "Nikmati Cita Rasa Toba",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // --- CARD FORM dengan Green Border ---
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 400),
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, secondaryGreen, primaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.3),
                        blurRadius: 25,
                        offset: Offset(0, 12),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        // Dekorasi Nature Ornament
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accentGreen, secondaryGreen],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accentGreen, primaryGreen],
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
                                  colors: [secondaryGreen, accentGreen],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 28),

                        // --- INPUT EMAIL ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: lightGreen,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: lightGreen.withOpacity(0.15),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: primaryGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon: Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [accentGreen, secondaryGreen],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.email_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18),

                        // --- INPUT PASSWORD ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: lightGreen,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: lightGreen.withOpacity(0.15),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _passController,
                            obscureText: _obscureText,
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: primaryGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon: Container(
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryGreen, darkGreen],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
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
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 28),

                        // --- TOMBOL LOGIN ---
                        _isLoading
                            ? Container(
                                height: 54,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      accentGreen,
                                    ),
                                    strokeWidth: 3,
                                  ),
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
                                      primaryGreen,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentGreen.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    "MASUK",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),

                        // Dekorasi Nature Ornament bawah
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accentGreen, secondaryGreen],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accentGreen, primaryGreen],
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
                                  colors: [secondaryGreen, accentGreen],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 28),

                // --- TOMBOL DAFTAR ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun? ",
                      style: TextStyle(
                        color: darkGreen.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentGreen, secondaryGreen],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accentGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          "Daftar Sekarang",
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
    );
  }
}
