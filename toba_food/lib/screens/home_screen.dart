import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// --- IMPORT PROVIDER & SERVICES ---
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../services/umkm_service.dart';
import '../../models/product.dart';

// --- IMPORT LAYAR LAIN ---
// Folder: screens/pembeli/
import 'pembeli/product_detail_screen.dart'; 

// Folder: screens/umkm/
import 'umkm/add_product_screen.dart';
// Perhatikan huruf besar/kecil sesuai nama file di explorer Anda (EditProductScreen.dart)
import 'umkm/EditProductScreen.dart'; 
import 'umkm/umkm_register_screen.dart';

// Folder: screens/ (satu level)
import 'login_screen.dart';
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

  // Ganti IP sesuai konfigurasi backend Laravel Anda
  // Emulator Android pakai 10.0.2.2, Device fisik pakai IP Laptop (misal 192.168.x.x)
  final String _imageBaseUrl = "http://10.0.2.2:8000/storage/";

  // --- PALET WARNA ---
  final Color primaryGreen = const Color(0xFF3D5A4A);
  final Color secondaryGreen = const Color(0xFF6B8E7C);
  final Color lightGreen = const Color(0xFFA8C5B5);
  final Color accentGreen = const Color(0xFF8FBC8F);
  final Color cream = const Color(0xFFF5F1E8);
  final Color darkGreen = const Color(0xFF2C3E37);

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    // Animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
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

  // --- LOGIKA DELETE PRODUK (UMKM) ---
  Future<void> _confirmDelete(Product product) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Hapus Produk", style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus '${product.namaProduk}'?", style: TextStyle(color: secondaryGreen)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: TextStyle(color: secondaryGreen)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog konfirmasi
              await _deleteProduct(product.id);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int productId) async {
    // Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(child: CircularProgressIndicator(color: accentGreen)),
    );

    try {
      // Baris ini tidak akan merah lagi jika LANGKAH 1 sudah dilakukan
      bool success = await ProductService().deleteProduct(productId);
      
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      if (success) {
        _showCustomDialog(
          title: "Berhasil",
          message: "Produk berhasil dihapus.",
          isError: false,
        );
        _fetchProducts(); // Refresh list
      } else {
        _showCustomDialog(
          title: "Gagal",
          message: "Gagal menghapus produk.",
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showCustomDialog(
        title: "Error",
        message: "Terjadi kesalahan: $e",
        isError: true,
      );
    }
  }

  // --- LOGIKA EDIT PRODUK (UMKM) ---
  void _editProduct(Product product) async {
    // Navigasi ke Edit Screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // Pastikan nama class di file EditProductScreen.dart adalah EditProductScreen
        builder: (_) => EditProductScreen(product: product),
      ),
    );

    // Jika berhasil update (return true), refresh home
    if (result == true) {
      _fetchProducts();
    }
  }

  // --- LOGIKA HANDLE JUAL (UMKM/Seller) ---
  Future<void> _handleJualProduk() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
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
            message: "Anda belum terdaftar sebagai Mitra UMKM. Silakan lengkapi data usaha Anda.",
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
            const SizedBox(width: 10),
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
      return product.namaProduk.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.umkmNama.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
              offset: const Offset(0, -3),
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
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Notifikasi'),
          ],
        ),
      ),
    );
  }

  // --- KONTEN HOME ---
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
                          accentGreen.withOpacity(0.15 * _pulseController.value),
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
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [accentGreen, secondaryGreen],
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accentGreen.withOpacity(0.4),
                                          blurRadius: 15,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("🍃", style: TextStyle(fontSize: 20)),
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
                                  const SizedBox(height: 10),
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
                        const SizedBox(height: 20),
                        // Search Field
                        Container(
                          decoration: BoxDecoration(
                            color: cream,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: lightGreen),
                          ),
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            style: TextStyle(color: darkGreen),
                            decoration: InputDecoration(
                              hintText: "Cari makanan lezat...",
                              hintStyle: TextStyle(color: secondaryGreen.withOpacity(0.5)),
                              prefixIcon: Icon(Icons.search, color: accentGreen),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                const SizedBox(height: 16),
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
                                      padding: const EdgeInsets.all(30),
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
                                    const SizedBox(height: 16),
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
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                                itemCount: _filteredProducts.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    double.tryParse(product.harga.toString()) ?? 0,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentGreen, secondaryGreen, primaryGreen],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: accentGreen.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
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

  // --- WIDGET CARD PRODUK ---
  Widget _buildProductCard(Product product, String? imageUrl, double harga,
      NumberFormat formatCurrency, AuthProvider auth) {
    
    // Cek apakah user adalah seller
    bool isSeller = auth.user?.role == 'seller';

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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian Gambar & Menu UMKM
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Gambar
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
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

                  // MENU EDIT/DELETE (Seller Only)
                  if (isSeller)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_vert, color: darkGreen, size: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editProduct(product);
                            } else if (value == 'delete') {
                              _confirmDelete(product);
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue, size: 20),
                                  SizedBox(width: 10),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 10),
                                  Text('Hapus'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Detail Text
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 4),
                    Text(
                      product.umkmNama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryGreen,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
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