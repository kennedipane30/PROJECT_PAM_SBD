import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/product_service.dart';
import '../services/umkm_service.dart';
import '../models/product.dart';
import 'umkm/add_product_screen.dart';
import 'login_screen.dart';
import 'pembeli/product_detail_screen.dart';
import 'umkm/umkm_register_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // --- STATE NAVIGASI ---
  int _selectedIndex = 0; // 0: Home, 1: Profil, 2: Notifikasi

  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late AnimationController _pulseController;
  late AnimationController _shineController;

  // Ganti IP sesuai konfigurasi
  final String _imageBaseUrl = "http://10.0.2.2:8000/storage/";

  // Green Nature Palette
  final Color primaryGreen = Color(0xFF3D5A4A);
  final Color secondaryGreen = Color(0xFF6B8E7C);
  final Color lightGreen = Color(0xFFA8C5B5);
  final Color accentGreen = Color(0xFF8FBC8F);
  final Color cream = Color(0xFFF5F1E8);
  final Color darkGreen = Color(0xFF2C3E37);

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    // Animations
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
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      var products = await ProductService().getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- LOGIKA HANDLE UMKM ---
  Future<void> _handleJualProduk() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: lightGreen),
          ),
          child: CircularProgressIndicator(color: accentGreen),
        ),
      ),
    );

    try {
      final result = await UmkmService().checkStatus();
      if (!mounted) return;
      Navigator.pop(context);

      String status = result['status'];

      if (status == 'approved') {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddProductScreen()),
        );
        _fetchProducts();
      } else if (status == 'not_registered') {
        _showCustomDialog(
            title: "Belum Terdaftar",
            message:
                "Anda belum terdaftar sebagai Mitra UMKM. Silakan lengkapi data usaha Anda.",
            isError: false,
            onConfirm: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UmkmRegisterScreen()),
              );
            },
            confirmText: "DAFTAR SEKARANG");
      } else if (status == 'pending') {
        _showCustomDialog(
          title: "Dalam Peninjauan",
          message: "Pendaftaran UMKM Anda sedang diverifikasi Admin.",
          isError: false,
        );
      } else if (status == 'rejected') {
        String alasan = result['data']['alasan_penolakan'] ?? '-';
        _showCustomDialog(
          title: "Pengajuan Ditolak",
          message: "Maaf, pengajuan UMKM Anda ditolak.\nAlasan: $alasan",
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showCustomDialog(
        title: "Gagal Terhubung",
        message: "Periksa koneksi internet.\nError: $e",
        isError: true,
      );
    }
  }

  void _showCustomDialog({
    required String title,
    required String message,
    required bool isError,
    VoidCallback? onConfirm,
    String confirmText = "OK",
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError ? Colors.red : accentGreen,
            ),
            SizedBox(width: 10),
            Text(title,
                style: TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: TextStyle(color: secondaryGreen)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (onConfirm != null) onConfirm();
            },
            child: Text(
              confirmText,
              style: TextStyle(
                color: accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((product) {
      return product.namaProduk
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          product.umkmNama.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(auth, formatCurrency),
          ProfileScreen(),
          NotificationScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: lightGreen.withOpacity(0.3), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: lightGreen.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: accentGreen,
          unselectedItemColor: secondaryGreen.withOpacity(0.5),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profil'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_rounded), label: 'Notifikasi'),
          ],
        ),
      ),
    );
  }

  // --- ISI HALAMAN HOME ---
  Widget _buildHomeContent(AuthProvider auth, NumberFormat formatCurrency) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            cream.withOpacity(0.3),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Background Animation
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Positioned(
                  top: -100,
                  right: -100 + (_pulseController.value * 20),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentGreen
                              .withOpacity(0.15 * _pulseController.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            Column(
              children: [
                // Header & Search
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: lightGreen.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Row Logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [accentGreen, secondaryGreen],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentGreen.withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("🍃",
                                            style: TextStyle(fontSize: 20)),
                                        SizedBox(width: 8),
                                        Text(
                                          "TOBA FOOD",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Halo, ${auth.user?.name ?? 'Sahabat Toba'}! 👋",
                                    style: TextStyle(
                                      color: secondaryGreen,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Search Field
                        Container(
                          decoration: BoxDecoration(
                            color: cream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: lightGreen),
                          ),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            style: TextStyle(color: darkGreen),
                            decoration: InputDecoration(
                              hintText: "Cari makanan lezat...",
                              hintStyle: TextStyle(
                                  color: secondaryGreen.withOpacity(0.5)),
                              prefixIcon:
                                  Icon(Icons.search, color: accentGreen),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List Produk
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchProducts,
                    color: accentGreen,
                    child: _isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: accentGreen),
                                SizedBox(height: 16),
                                Text(
                                  "Memuat produk...",
                                  style: TextStyle(color: secondaryGreen),
                                ),
                              ],
                            ),
                          )
                        : _filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(30),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            lightGreen.withOpacity(0.2),
                                            lightGreen.withOpacity(0.05),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.restaurant_menu,
                                        size: 60,
                                        color: secondaryGreen,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "Produk tidak ditemukan",
                                      style: TextStyle(
                                        color: secondaryGreen,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
                                itemCount: _filteredProducts.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                ),
                                itemBuilder: (ctx, i) {
                                  final product = _filteredProducts[i];
                                  return _buildProductCard(
                                    product,
                                    product.gambar != null
                                        ? "$_imageBaseUrl${product.gambar}"
                                        : null,
                                    double.tryParse(product.harga.toString()) ??
                                        0,
                                    formatCurrency,
                                    auth,
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),

            // FAB Jual Produk (Hanya Seller)
            if (auth.user?.role == 'seller')
              Positioned(
                bottom: 35,
                right: 25,
                child: InkWell(
                  onTap: _handleJualProduk,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentGreen, secondaryGreen, primaryGreen],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: accentGreen.withOpacity(0.5),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Jual Produk",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildProductCard(Product product, String? imageUrl, double harga,
      NumberFormat formatCurrency, AuthProvider auth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lightGreen),
          boxShadow: [
            BoxShadow(
              color: lightGreen.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  width: double.infinity,
                  color: cream,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Icon(
                            Icons.broken_image,
                            color: secondaryGreen.withOpacity(0.3),
                            size: 40,
                          ),
                        )
                      : Icon(
                          Icons.fastfood,
                          color: secondaryGreen.withOpacity(0.3),
                          size: 40,
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.namaProduk,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.umkmNama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryGreen,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Text(
                      formatCurrency.format(harga),
                      style: TextStyle(
                        color: accentGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
