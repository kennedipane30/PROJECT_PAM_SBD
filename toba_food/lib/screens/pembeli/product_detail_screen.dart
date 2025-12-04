import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import 'checkout_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Setup URL Gambar
    final String imageBaseUrl = "http://10.0.2.2:8000/storage/";
    String? imageUrl;
    if (product.gambar != null && product.gambar!.isNotEmpty) {
      imageUrl = "$imageBaseUrl${product.gambar}";
    }

    // Green Nature Palette - Modern & Elegant
    final Color primaryGreen = Color(0xFF3D5A4A);
    final Color secondaryGreen = Color(0xFF6B8E7C);
    final Color lightGreen = Color(0xFFA8C5B5);
    final Color accentGreen = Color(0xFF8FBC8F);
    final Color cream = Color(0xFFF5F1E8);
    final Color darkGreen = Color(0xFF2C3E37);

    return Scaffold(
      backgroundColor: cream,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentGreen, secondaryGreen],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentGreen.withOpacity(0.4),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: IconButton(
              icon: Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Fitur berbagi segera hadir!"),
                    backgroundColor: accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR BESAR dengan Gradient Overlay
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        darkGreen.withOpacity(0.2),
                        cream,
                      ],
                    ),
                  ),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) => Container(
                            color: cream,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          lightGreen.withOpacity(0.3),
                                          secondaryGreen.withOpacity(0.2)
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 60,
                                      color: secondaryGreen,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Gagal memuat gambar",
                                    style: TextStyle(
                                      color: secondaryGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: cream,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    lightGreen.withOpacity(0.3),
                                    secondaryGreen.withOpacity(0.2)
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.restaurant,
                                size: 100,
                                color: secondaryGreen,
                              ),
                            ),
                          ),
                        ),
                ),
                // Gradient Overlay Bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          cream,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. CONTENT DETAIL dengan Card Style
            Container(
              padding: EdgeInsets.all(2),
              margin: EdgeInsets.symmetric(horizontal: 20),
              transform: Matrix4.translationValues(0.0, -30.0, 0.0),
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
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nature Decoration
                    _buildNatureDecoration(
                        accentGreen, secondaryGreen, primaryGreen),
                    SizedBox(height: 20),

                    // Nama Toko dengan Icon
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: lightGreen, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentGreen, secondaryGreen],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.storefront,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            product.umkmNama,
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Nama Produk
                    Text(
                      product.namaProduk,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: darkGreen,
                        height: 1.3,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Harga dengan Background Gradient
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentGreen, secondaryGreen, primaryGreen],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentGreen.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            formatCurrency.format(
                              double.tryParse(product.harga.toString()) ?? 0,
                            ),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Divider dengan Nature Decoration
                    _buildNatureDecoration(
                        accentGreen, secondaryGreen, primaryGreen),
                    SizedBox(height: 20),

                    // Label Deskripsi
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentGreen, primaryGreen],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Deskripsi Produk",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Deskripsi
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: lightGreen, width: 1.5),
                      ),
                      child: Text(
                        product.deskripsi ?? "Tidak ada deskripsi.",
                        style: TextStyle(
                          color: secondaryGreen,
                          height: 1.6,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Nature Decoration Bottom
                    _buildNatureDecoration(
                        accentGreen, secondaryGreen, primaryGreen),
                  ],
                ),
              ),
            ),

            SizedBox(height: 100), // Space untuk bottom bar
          ],
        ),
      ),

      // 3. BOTTOM BAR dengan Green Gradient
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: accentGreen.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
          border: Border(
            top: BorderSide(color: lightGreen.withOpacity(0.3), width: 1),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Tombol Keranjang
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: accentGreen, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: cream,
                  boxShadow: [
                    BoxShadow(
                      color: accentGreen.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: primaryGreen,
                    size: 26,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Ditambahkan ke keranjang!"),
                          ],
                        ),
                        backgroundColor: accentGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12),

              // Tombol Beli Sekarang
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, secondaryGreen, primaryGreen],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CheckoutScreen(product: product),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Beli Sekarang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
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
    );
  }

  Widget _buildNatureDecoration(Color color1, Color color2, Color color3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
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
              colors: [color1, color3],
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
              colors: [color2, color1],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
