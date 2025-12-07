import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/cart_provider.dart'; // Import CartProvider
import '../../services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  // Hapus parameter 'final Product product' karena kita pakai Data Keranjang
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  
  String _paymentMethod = 'cod';
  String? _namaFileBukti;

  // Controller
  final _namaPengirimController = TextEditingController();
  final _noRekController = TextEditingController();
  final _catatanController = TextEditingController();
  final _alamatController = TextEditingController();

  late AnimationController _pulseController;

  // Green Nature Palette
  final Color primaryGreen = const Color(0xFF3D5A4A);
  final Color secondaryGreen = const Color(0xFF6B8E7C);
  final Color lightGreen = const Color(0xFFA8C5B5);
  final Color accentGreen = const Color(0xFF8FBC8F);
  final Color cream = const Color(0xFFF5F1E8);
  final Color darkGreen = const Color(0xFF2C3E37);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _namaPengirimController.dispose();
    _noRekController.dispose();
    _catatanController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _uploadBukti() {
    setState(() {
      _namaFileBukti = "bukti_tf_${DateTime.now().millisecondsSinceEpoch}.jpg";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Foto bukti transfer berhasil dipilih!"),
        backgroundColor: accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- FUNGSI SUBMIT ORDER (REVISI UTAMA) ---
  void _submitOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    // 1. Validasi Keranjang
    if (cart.items.isEmpty) {
      _showSnackError("Keranjang kosong.");
      return;
    }

    // 2. Validasi Alamat
    if (_alamatController.text.trim().isEmpty) {
      _showSnackError("Mohon isi alamat pengiriman lengkap.");
      return;
    }

    // 3. Validasi Transfer
    if (_paymentMethod == 'transfer') {
      if (_namaPengirimController.text.isEmpty || _noRekController.text.isEmpty) {
        _showSnackError("Harap lengkapi data nama & no rek pengirim.");
        return;
      }
      if (_namaFileBukti == null) {
        _showSnackError("Harap upload bukti transfer.");
        return;
      }
    }

    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: lightGreen, width: 2),
          ),
          child: CircularProgressIndicator(color: accentGreen),
        ),
      ),
    );

    try {
      // Ambil ID UMKM dari produk pertama (Asumsi 1 checkout = 1 UMKM atau Backend handle logic)
      int targetUmkmId = cart.items.values.first.product.sellerId ?? 1;

      // Format Items dari CartProvider ke Format API Laravel
      List<Map<String, dynamic>> itemsPayload = cart.items.values.map((cartItem) {
        return {
          "product_id": cartItem.product.id,
          "jumlah": cartItem.quantity,
        };
      }).toList();

      bool success = await OrderService().checkout(
        umkmId: targetUmkmId,
        items: itemsPayload,
        paymentMethod: _paymentMethod,
        alamat: _alamatController.text,
      );

      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading

      if (success) {
        cart.clear(); // BERSIHKAN KERANJANG SETELAH SUKSES
        _showSuccessDialog();
      } else {
        _showSnackError("Gagal membuat pesanan. Cek koneksi API.");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackError("Terjadi kesalahan: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accentGreen, secondaryGreen]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 15),
            Text("Pesanan Berhasil!",
                style: TextStyle(color: darkGreen, fontWeight: FontWeight.w900, fontSize: 24)),
          ],
        ),
        content: Text(
          "Pesanan via ${_paymentMethod.toUpperCase()} diterima sistem.",
          textAlign: TextAlign.center,
          style: TextStyle(color: secondaryGreen, fontSize: 16),
        ),
        actions: [
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [accentGreen, secondaryGreen]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Tutup Dialog
                Navigator.of(context).pop(); // Kembali ke Cart
                Navigator.of(context).pop(); // Kembali ke Home (opsional)
              },
              child: const Text("OK", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AMBIL DATA DARI PROVIDER
    final cart = Provider.of<CartProvider>(context);
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Hitung Ongkir & Total
    double subtotalBarang = cart.totalAmount;
    double ongkir = 5000;
    double total = subtotalBarang + ongkir;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cream, Colors.white, cream],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background Animation (Sama seperti sebelumnya)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Positioned(
                    top: -150,
                    left: -100 + (_pulseController.value * 30),
                    child: Container(
                      width: 350, height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [accentGreen.withOpacity(0.15 * _pulseController.value), Colors.transparent],
                        ),
                      ),
                    ),
                  );
                },
              ),

              Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [accentGreen, secondaryGreen]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: accentGreen.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text("Checkout", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: darkGreen)),
                      ],
                    ),
                  ),

                  // Scrollable Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          
                          // 1. DETAIL PESANAN (LIST VIEW DARI KERANJANG)
                          Text("Daftar Barang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: lightGreen, width: 1.5),
                              boxShadow: [BoxShadow(color: accentGreen.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              children: cart.items.values.map((item) {
                                double price = double.tryParse(item.product.harga.toString()) ?? 0;
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Gambar Kecil
                                        Container(
                                          width: 50, height: 50,
                                          decoration: BoxDecoration(
                                            color: cream, borderRadius: BorderRadius.circular(10),
                                            image: (item.product.gambar != null)
                                                ? DecorationImage(
                                                    image: NetworkImage("http://10.0.2.2:8000/storage/${item.product.gambar}"),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: item.product.gambar == null ? Icon(Icons.fastfood, size: 30, color: secondaryGreen) : null,
                                        ),
                                        const SizedBox(width: 12),
                                        // Nama & Qty
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.product.namaProduk, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: darkGreen)),
                                              Text("${item.quantity} x ${formatCurrency.format(price)}", style: TextStyle(color: secondaryGreen, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        // Total per item
                                        Text(formatCurrency.format(price * item.quantity), style: TextStyle(fontWeight: FontWeight.bold, color: accentGreen)),
                                      ],
                                    ),
                                    const Divider(),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. ALAMAT (Sama seperti sebelumnya)
                          Text("Alamat Pengiriman", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                          const SizedBox(height: 10),
                          _buildTextField(controller: _alamatController, label: "Masukkan alamat lengkap...", icon: Icons.location_on),
                          const SizedBox(height: 24),

                          // 3. PEMBAYARAN (Sama seperti sebelumnya)
                          Text("Metode Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: lightGreen, width: 1.5)),
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: Text("COD (Bayar di Tempat)", style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600)),
                                  value: 'cod', groupValue: _paymentMethod, activeColor: accentGreen,
                                  onChanged: (val) => setState(() => _paymentMethod = val!),
                                ),
                                Divider(height: 1, color: lightGreen),
                                RadioListTile<String>(
                                  title: Text("Transfer Bank", style: TextStyle(color: darkGreen, fontWeight: FontWeight.w600)),
                                  value: 'transfer', groupValue: _paymentMethod, activeColor: accentGreen,
                                  onChanged: (val) => setState(() => _paymentMethod = val!),
                                ),
                              ],
                            ),
                          ),

                          // 4. FORM TRANSFER (Jika Transfer dipilih)
                          if (_paymentMethod == 'transfer') ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: accentGreen, width: 2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: lightGreen)),
                                    child: Row(children: [
                                        Icon(Icons.account_balance, color: secondaryGreen, size: 20),
                                        const SizedBox(width: 10),
                                        Text("BCA 1234567890 a.n Toba Food", style: TextStyle(color: darkGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(controller: _namaPengirimController, label: 'Nama Pengirim', icon: Icons.person_outline),
                                  const SizedBox(height: 16),
                                  _buildTextField(controller: _noRekController, label: 'No. Rekening', icon: Icons.account_balance_wallet_outlined, keyboardType: TextInputType.number),
                                  const SizedBox(height: 20),
                                  Text("Bukti Transfer", style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _uploadBukti,
                                    child: Container(
                                      height: 120, width: double.infinity,
                                      decoration: BoxDecoration(color: cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: _namaFileBukti != null ? accentGreen : lightGreen, width: 2)),
                                      child: _namaFileBukti == null
                                          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, color: secondaryGreen, size: 40), Text("Tap upload bukti", style: TextStyle(color: secondaryGreen))])
                                          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle, color: accentGreen, size: 40), Text("Bukti Terpilih", style: TextStyle(color: accentGreen))]),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // 5. TOTAL HARGA
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: lightGreen, width: 1.5),
                              boxShadow: [BoxShadow(color: accentGreen.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow("Subtotal", formatCurrency.format(subtotalBarang), secondaryGreen, darkGreen),
                                const SizedBox(height: 8),
                                _buildSummaryRow("Ongkir", formatCurrency.format(ongkir), secondaryGreen, darkGreen),
                                Divider(color: lightGreen, height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: darkGreen)),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(gradient: LinearGradient(colors: [accentGreen, secondaryGreen]), borderRadius: BorderRadius.circular(10)),
                                          child: Text(formatCurrency.format(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // TOMBOL AKSI
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [accentGreen, secondaryGreen, primaryGreen]),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: accentGreen.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _submitOrder,
                                borderRadius: BorderRadius.circular(18),
                                child: Center(
                                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                    Icon(Icons.shopping_cart_checkout_outlined, color: Colors.white, size: 24),
                                    SizedBox(width: 12),
                                    Text("Buat Pesanan", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8)),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildSummaryRow(String label, String value, Color labelColor, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 15)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600))
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: lightGreen, width: 1.5)),
      child: TextField(
        controller: controller, keyboardType: keyboardType,
        style: TextStyle(color: darkGreen, fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label, labelStyle: TextStyle(color: secondaryGreen, fontSize: 14),
          prefixIcon: Icon(icon, color: secondaryGreen, size: 20),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}