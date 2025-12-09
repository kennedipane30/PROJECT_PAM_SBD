import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// --- IMPORT PROVIDER & SERVICES ---
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../services/umkm_service.dart';
import '../../models/product.dart';

// --- IMPORT LAYAR LAIN ---
import 'pembeli/product_detail_screen.dart';
import 'pembeli/cart_screen.dart';
import 'umkm/add_product_screen.dart';
import 'umkm/EditProductScreen.dart'; // Pastikan nama file sesuai (EditProductScreen.dart atau edit_product_screen.dart)
import 'umkm/umkm_register_screen.dart';
import 'login_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // --- STATE ---
  int _selectedIndex = 0;
  List<Product> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late AnimationController _pulseController;

  // Ganti IP sesuai konfigurasi Anda
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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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

  // --- DELETE LOGIC (SELLER) ---
  Future<void> _confirmDelete(Product product) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Hapus Produk",
            style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
        content: Text(
            "Apakah Anda yakin ingin menghapus '${product.namaProduk}'?",
            style: TextStyle(color: secondaryGreen)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: TextStyle(color: secondaryGreen)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _deleteProduct(product.id);
            },
            child: const Text("Hapus",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(int productId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) =>
          Center(child: CircularProgressIndicator(color: accentGreen)),
    );

    try {
      bool success = await ProductService().deleteProduct(productId);
      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        _fetchProducts();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal menghapus produk")));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // --- EDIT LOGIC (SELLER) ---
  void _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProductScreen(product: product)),
    );
    if (result == true) _fetchProducts();
  }

  // --- HANDLE JUAL (SELLER) ---
  Future<void> _handleJualProduk() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) =>
          Center(child: CircularProgressIndicator(color: accentGreen)),
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
        _showDialogMsg("Belum Terdaftar", "Silakan daftar sebagai Mitra UMKM.",
            () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => UmkmRegisterScreen()));
        });
      } else if (status == 'pending') {
        _showDialogMsg(
            "Dalam Peninjauan", "Pendaftaran Anda sedang diverifikasi.", null);
      } else if (status == 'rejected') {
        _showDialogMsg("Ditolak", "Pengajuan ditolak. Hubungi admin.", null);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _showDialogMsg(String title, String msg, VoidCallback? onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (onConfirm != null) onConfirm();
              },
              child: Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(auth, cart, formatCurrency),
          ProfileScreen(),
          NotificationScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: lightGreen.withOpacity(0.3))),
        boxShadow: [
          BoxShadow(
              color: lightGreen.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -3))
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: accentGreen,
        unselectedItemColor: secondaryGreen.withOpacity(0.5),
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded), label: 'Notifikasi'),
        ],
      ),
    );
  }

  // --- KONTEN HOME UTAMA ---
  Widget _buildHomeContent(
      AuthProvider auth, CartProvider cart, NumberFormat formatCurrency) {
    // Cek Role User
    bool isSeller = auth.user?.role == 'seller';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, cream.withOpacity(0.3), Colors.white],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // --- HEADER & SEARCH ---
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: lightGreen.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ROW: LOGO & KERANJANG
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo & Salam
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        accentGreen,
                                        secondaryGreen
                                      ]),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: const Row(
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
                                              letterSpacing: 3),
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
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),

                            // --- IKON KERANJANG (HANYA PEMBELI) ---
                            // Jika Seller -> Hilang
                            // Jika Pembeli -> Muncul
                            if (!isSeller)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CartScreen()),
                                  );
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: cream,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: lightGreen),
                                      ),
                                      child: Icon(Icons.shopping_cart_outlined,
                                          color: darkGreen, size: 26),
                                    ),
                                    // Badge Jumlah Item
                                    if (cart.itemCount > 0)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            cart.itemCount.toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
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
                              contentPadding: const EdgeInsets.symmetric(
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
                            child:
                                CircularProgressIndicator(color: accentGreen))
                        : _filteredProducts.isEmpty
                            ? Center(
                                child: Text("Produk tidak ditemukan",
                                    style: TextStyle(color: secondaryGreen)))
                            : GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 100),
                                itemCount: _filteredProducts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    product.harga, // ✅ Langsung pakai!
                                    formatCurrency,
                                    auth,
                                    cart,
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),

            // FAB Jual (Hanya Seller)
            if (isSeller)
              Positioned(
                bottom: 35,
                right: 25,
                child: InkWell(
                  onTap: _handleJualProduk,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [accentGreen, secondaryGreen, primaryGreen]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: accentGreen.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Jual Produk",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
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

  // --- CARD PRODUK ---
  Widget _buildProductCard(Product product, String? imageUrl, double harga,
      NumberFormat formatCurrency, AuthProvider auth, CartProvider cart) {
    bool isSeller = auth.user?.role == 'seller';

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product)));
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
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: cream,
                      child: imageUrl != null
                          ? Image.network(imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Icon(
                                  Icons.broken_image,
                                  color: secondaryGreen))
                          : Icon(Icons.fastfood, color: secondaryGreen),
                    ),
                  ),

                  // Menu Edit/Delete (Khusus Seller)
                  if (isSeller)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon:
                              Icon(Icons.more_vert, color: darkGreen, size: 20),
                          onSelected: (val) => val == 'edit'
                              ? _editProduct(product)
                              : _confirmDelete(product),
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'delete', child: Text('Hapus')),
                          ],
                        ),
                      ),
                    ),

                  // Tombol Quick Add to Cart (Khusus Pembeli)
                  if (!isSeller)
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          cart.addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "${product.namaProduk} masuk keranjang!"),
                                duration: Duration(seconds: 1),
                                backgroundColor: primaryGreen),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: accentGreen, shape: BoxShape.circle),
                          child: Icon(Icons.add_shopping_cart,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.namaProduk,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: darkGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(product.umkmNama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: secondaryGreen, fontSize: 12)),
                    const Spacer(),
                    Text(formatCurrency.format(harga),
                        style: TextStyle(
                            color: accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((p) =>
            p.namaProduk.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.umkmNama.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
}
