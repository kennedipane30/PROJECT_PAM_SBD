import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // [BARU] Import Provider
import '../../models/product.dart';
import '../../providers/cart_provider.dart'; // [BARU] Import CartProvider
import 'checkout_screen.dart';
import 'cart_screen.dart'; // Optional: Jika ingin navigasi ke cart screen

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // [BARU] Panggil CartProvider (listen: false karena hanya untuk aksi klik)
    final cart = Provider.of<CartProvider>(context, listen: false);

    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Setup URL Gambar
    // Ganti IP sesuai konfigurasi backend Anda
    final String imageBaseUrl = "http://10.0.2.2:8000/storage/";
    String? imageUrl;
    if (product.gambar != null && product.gambar!.isNotEmpty) {
      imageUrl = "$imageBaseUrl${product.gambar}";
    }

    // Green Nature Palette
    final Color primaryGreen = const Color(0xFF3D5A4A);
    final Color secondaryGreen = const Color(0xFF6B8E7C);
    final Color lightGreen = const Color(0xFFA8C5B5);
    final Color accentGreen = const Color(0xFF8FBC8F);
    final Color cream = const Color(0xFFF5F1E8);
    final Color darkGreen = const Color(0xFF2C3E37);

    return Scaffold(
      backgroundColor: cream,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentGreen, secondaryGreen],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentGreen.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Fitur berbagi segera hadir!"),
                    backgroundColor: accentGreen,
                    behavior: SnackBarBehavior.floating,
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
            // 1. GAMBAR BESAR
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
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 60,
                                color: secondaryGreen,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: cream,
                          child: Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 100,
                              color: secondaryGreen,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, cream],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. CONTENT DETAIL
            Container(
              padding: const EdgeInsets.all(2),
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNatureDecoration(accentGreen, secondaryGreen, primaryGreen),
                    const SizedBox(height: 20),

                    // Nama Toko
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: lightGreen, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [accentGreen, secondaryGreen]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.storefront, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.umkmNama,
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nama Produk
                    Text(
                      product.namaProduk,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: darkGreen,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Harga
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentGreen, secondaryGreen, primaryGreen],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: accentGreen.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            formatCurrency.format(double.tryParse(product.harga.toString()) ?? 0),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildNatureDecoration(accentGreen, secondaryGreen, primaryGreen),
                    const SizedBox(height: 20),

                    // Deskripsi
                    Row(
                      children: [
                        Container(
                          width: 4, height: 24,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [accentGreen, primaryGreen],
                                begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Deskripsi Produk",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 20),
                    _buildNatureDecoration(accentGreen, secondaryGreen, primaryGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // 3. BOTTOM BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: accentGreen.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border(top: BorderSide(color: lightGreen.withOpacity(0.3), width: 1)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // --- TOMBOL TAMBAH KE KERANJANG (DIUPDATE) ---
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
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: primaryGreen, size: 26),
                  onPressed: () {
                    // [MODIFIKASI 1]: Tambahkan logika add to cart yang sebenarnya
                    cart.addItem(product);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(children: const [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Ditambahkan ke keranjang!"),
                        ]),
                        backgroundColor: accentGreen,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // --- TOMBOL BELI SEKARANG (DIUPDATE) ---
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, secondaryGreen, primaryGreen],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      // [MODIFIKASI 2]: Masukkan ke cart dulu, baru ke checkout
                      cart.addItem(product);

                      // Navigasi ke CheckoutScreen TANPA PARAMETER
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckoutScreen(), // Error hilang di sini
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shopping_bag, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          "Beli Sekarang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
          width: 40, height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color1, color2]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color1, color3]),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40, height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color2, color1]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}