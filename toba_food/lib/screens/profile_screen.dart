import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'package:toba_food_app/screens/pembeli/my_orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Green Nature Palette
    final Color primaryGreen = Color(0xFF3D5A4A);
    final Color secondaryGreen = Color(0xFF6B8E7C);
    final Color lightGreen = Color(0xFFA8C5B5);
    final Color accentGreen = Color(0xFF8FBC8F);
    final Color cream = Color(0xFFF5F1E8);
    final Color darkGreen = Color(0xFF2C3E37);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section dengan Background Gradasi
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accentGreen, secondaryGreen, primaryGreen],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    // Avatar Section
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: cream,
                        child: Text(
                          user?.name != null
                              ? user!.name![0].toUpperCase()
                              : "U",
                          style: TextStyle(
                            fontSize: 40,
                            color: primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      user?.name ?? "Pengguna",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user?.email ?? "email@contoh.com",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Role Badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        user?.role == 'seller' ? '🏪 Penjual' : '🛒 Pembeli',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // --- MENU SECTIONS ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Menu Utama",
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // 1. Menu Pesanan Saya (Hanya untuk Pembeli)
                    if (auth.user?.role == 'buyer' || auth.user?.role == 'user')
                      _buildMenuTile(
                          icon: Icons.shopping_bag_outlined,
                          title: "Pesanan Saya",
                          subtitle: "Lihat riwayat pesanan",
                          color: accentGreen,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => MyOrderScreen()));
                          }),

                    // 2. Menu Khusus Penjual
                    if (auth.user?.role == 'seller')
                      _buildMenuTile(
                          icon: Icons.store_outlined,
                          title: "Kelola Toko",
                          subtitle: "Pesanan masuk & produk",
                          color: secondaryGreen,
                          onTap: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => IncomingOrderScreen()));
                          }),

                    _buildMenuTile(
                        icon: Icons.settings_outlined,
                        title: "Pengaturan",
                        subtitle: "Atur preferensi aplikasi",
                        color: lightGreen,
                        onTap: () {}),

                    _buildMenuTile(
                        icon: Icons.help_outline,
                        title: "Bantuan & Dukungan",
                        subtitle: "FAQ dan hubungi kami",
                        color: lightGreen,
                        onTap: () {}),

                    SizedBox(height: 20),

                    Divider(color: lightGreen.withOpacity(0.3), thickness: 1),

                    SizedBox(height: 20),

                    // Logout
                    _buildMenuTile(
                        icon: Icons.logout,
                        title: "Keluar",
                        subtitle: "Logout dari akun",
                        color: Colors.red[400]!,
                        onTap: () async {
                          // Tampilkan konfirmasi logout
                          bool confirm = await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        title: Row(
                                          children: [
                                            Icon(Icons.logout,
                                                color: Colors.red[400]),
                                            SizedBox(width: 10),
                                            Text(
                                              "Keluar?",
                                              style: TextStyle(
                                                color: darkGreen,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: Text(
                                          "Anda yakin ingin keluar dari aplikasi?",
                                          style:
                                              TextStyle(color: secondaryGreen),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              "Batal",
                                              style: TextStyle(
                                                color: secondaryGreen,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.red[400]!,
                                                  Colors.red[600]!
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: TextButton(
                                              child: Text(
                                                "Ya, Keluar",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                            ),
                                          ),
                                        ],
                                      )) ??
                              false;

                          if (confirm) {
                            await auth.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen()),
                                (route) => false);
                          }
                        }),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Color(0xFF2C3E37),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFF6B8E7C),
                    fontSize: 12,
                  ),
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: color.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}
