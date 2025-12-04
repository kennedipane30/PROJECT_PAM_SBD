import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;

  const CheckoutScreen({super.key, required this.product});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  // State
  String _paymentMethod = 'cod'; // Default value (Sesuai Backend)
  int _qty = 1;
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

  void _updateQty(bool increment) {
    setState(() {
      if (increment) {
        _qty++;
      } else {
        if (_qty > 1) _qty--;
      }
    });
  }

  void _uploadBukti() {
    setState(() {
      // Simulasi upload file
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

  // ==============================================================
  // [MODIFIED] FUNGSI SUBMIT ORDER
  // Menambahkan pengiriman metode_pembayaran ke Service
  // ==============================================================
  void _submitOrder() async {
    // 1. Validasi Alamat
    if (_alamatController.text.trim().isEmpty) {
      _showSnackError("Mohon isi alamat pengiriman lengkap.");
      return;
    }

    // 2. Validasi Data Transfer
    if (_paymentMethod == 'transfer') {
      if (_namaPengirimController.text.isEmpty ||
          _noRekController.text.isEmpty) {
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
      int targetUmkmId = widget.product.sellerId ?? 1;

      // Format Items sesuai permintaan Laravel
      List<Map<String, dynamic>> items = [
        {
          "product_id": widget.product.id,
          "jumlah": _qty,
        }
      ];

      // [PENTING]
      // Pastikan Anda juga mengupdate file 'order_service.dart' Anda
      // agar menerima parameter paymentMethod & alamat.
      // Jika OrderService belum diupdate, error mungkin tetap ada.
      bool success = await OrderService().checkout(
        umkmId: targetUmkmId,
        items: items,
        paymentMethod: _paymentMethod, // <--- INI WAJIB DIKIRIM (cod/transfer)
        alamat: _alamatController.text, // <--- Dikirim untuk disimpan
      );

      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading

      if (success) {
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
                gradient: LinearGradient(
                  colors: [accentGreen, secondaryGreen],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 15),
            Text("Pesanan Berhasil!",
                style: TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 24)),
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
              gradient: LinearGradient(
                colors: [accentGreen, secondaryGreen],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Tutup Dialog
                Navigator.of(context).pop(); // Kembali ke Home/Detail
              },
              child: const Text("OK",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
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
        backgroundColor: Colors.redAccent, // Ubah merah biar kelihatan error
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // [MODIFIED] Pastikan parsing harga aman dari null/string kosong
    double hargaSatuan = 0;
    try {
      hargaSatuan = double.parse(widget.product.harga.toString());
    } catch (e) {
      hargaSatuan = 0;
    }

    double subtotalBarang = hargaSatuan * _qty;
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
              // Background Animation
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
                                .withOpacity(0.15 * _pulseController.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Main Column
              Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      children: [
                        Container(
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
                        const SizedBox(width: 16),
                        Text("Checkout",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: darkGreen)),
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
                          // 1. DETAIL PRODUK
                          Text("Detail Pesanan",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: lightGreen, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: accentGreen.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: cream,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: lightGreen, width: 1.5),
                                        image: (widget.product.gambar != null)
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  "http://10.0.2.2:8000/storage/${widget.product.gambar}",
                                                ),
                                                fit: BoxFit.cover,
                                                onError: (e, s) {},
                                              )
                                            : null,
                                      ),
                                      child: widget.product.gambar == null
                                          ? Icon(Icons.restaurant,
                                              color: secondaryGreen, size: 40)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.product.namaProduk,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: darkGreen,
                                                  fontSize: 18)),
                                          const SizedBox(height: 4),
                                          Text(
                                              formatCurrency
                                                  .format(hargaSatuan),
                                              style: TextStyle(
                                                  color: accentGreen,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(color: lightGreen, height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Jumlah Beli",
                                        style: TextStyle(
                                            color: darkGreen,
                                            fontWeight: FontWeight.w600)),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: cream,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: lightGreen, width: 1.5)),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove,
                                                color: secondaryGreen,
                                                size: 18),
                                            onPressed: () => _updateQty(false),
                                          ),
                                          Text("$_qty",
                                              style: TextStyle(
                                                  color: darkGreen,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          IconButton(
                                            icon: Icon(Icons.add,
                                                color: secondaryGreen,
                                                size: 18),
                                            onPressed: () => _updateQty(true),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 2. ALAMAT (INPUT TEXT)
                          Text("Alamat Pengiriman",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen)),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _alamatController,
                            label: "Masukkan alamat lengkap...",
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 24),

                          // 3. PEMBAYARAN (RADIO BUTTON)
                          Text("Metode Pembayaran",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen)),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: lightGreen, width: 1.5),
                            ),
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: Text("COD (Bayar di Tempat)",
                                      style: TextStyle(
                                          color: darkGreen,
                                          fontWeight: FontWeight.w600)),
                                  value: 'cod',
                                  groupValue: _paymentMethod,
                                  activeColor: accentGreen,
                                  onChanged: (val) =>
                                      setState(() => _paymentMethod = val!),
                                ),
                                Divider(height: 1, color: lightGreen),
                                RadioListTile<String>(
                                  title: Text("Transfer Bank",
                                      style: TextStyle(
                                          color: darkGreen,
                                          fontWeight: FontWeight.w600)),
                                  value: 'transfer',
                                  groupValue: _paymentMethod,
                                  activeColor: accentGreen,
                                  onChanged: (val) =>
                                      setState(() => _paymentMethod = val!),
                                ),
                              ],
                            ),
                          ),

                          // 4. FORM TRANSFER (JIKA DIPILIH)
                          if (_paymentMethod == 'transfer') ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border:
                                    Border.all(color: accentGreen, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentGreen.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cream,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: lightGreen),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.account_balance,
                                            color: secondaryGreen, size: 20),
                                        const SizedBox(width: 10),
                                        Text("BCA 1234567890 a.n Toba Food",
                                            style: TextStyle(
                                                color: darkGreen,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                      controller: _namaPengirimController,
                                      label: 'Nama Pengirim',
                                      icon: Icons.person_outline),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                      controller: _noRekController,
                                      label: 'No. Rekening',
                                      icon:
                                          Icons.account_balance_wallet_outlined,
                                      keyboardType: TextInputType.number),
                                  const SizedBox(height: 20),
                                  Text("Bukti Transfer",
                                      style: TextStyle(
                                          color: darkGreen,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _uploadBukti,
                                    child: Container(
                                      height: 120,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: cream,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: _namaFileBukti != null
                                                  ? accentGreen
                                                  : lightGreen,
                                              width: 2)),
                                      child: _namaFileBukti == null
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                  Icon(
                                                      Icons.camera_alt_outlined,
                                                      color: secondaryGreen,
                                                      size: 40),
                                                  const SizedBox(height: 8),
                                                  Text("Tap upload bukti",
                                                      style: TextStyle(
                                                          color: secondaryGreen,
                                                          fontWeight:
                                                              FontWeight.w600))
                                                ])
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                  Icon(Icons.check_circle,
                                                      color: accentGreen,
                                                      size: 40),
                                                  const SizedBox(height: 8),
                                                  Text("Bukti Terpilih",
                                                      style: TextStyle(
                                                          color: accentGreen,
                                                          fontWeight:
                                                              FontWeight.w600))
                                                ]),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // 5. CATATAN
                          Text("Catatan",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen)),
                          const SizedBox(height: 10),
                          _buildTextField(
                              controller: _catatanController,
                              label: 'Pesan opsional...',
                              icon: Icons.note_alt_outlined),
                          const SizedBox(height: 32),

                          // 6. TOTAL HARGA (FIXED OVERFLOW ERROR)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: lightGreen, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: accentGreen.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Subtotal",
                                          style: TextStyle(
                                              color: secondaryGreen,
                                              fontSize: 15)),
                                      Text(
                                          formatCurrency.format(subtotalBarang),
                                          style: TextStyle(
                                              color: darkGreen,
                                              fontWeight: FontWeight.w600))
                                    ]),
                                const SizedBox(height: 8),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Ongkir",
                                          style: TextStyle(
                                              color: secondaryGreen,
                                              fontSize: 15)),
                                      Text(formatCurrency.format(ongkir),
                                          style: TextStyle(
                                              color: darkGreen,
                                              fontWeight: FontWeight.w600))
                                    ]),
                                Divider(color: lightGreen, height: 24),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total Bayar",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: darkGreen)),
                                      const SizedBox(width: 8),
                                      // [FIX] Mencegah overflow dengan Expanded & FittedBox
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  accentGreen,
                                                  secondaryGreen
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                  formatCurrency.format(total),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // TOMBOL AKSI
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  accentGreen,
                                  secondaryGreen,
                                  primaryGreen
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color: accentGreen.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10))
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _submitOrder,
                                borderRadius: BorderRadius.circular(18),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                          Icons.shopping_cart_checkout_outlined,
                                          color: Colors.white,
                                          size: 24),
                                      SizedBox(width: 12),
                                      Text("Buat Pesanan",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 0.8)),
                                    ],
                                  ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lightGreen, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
            color: darkGreen, fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: secondaryGreen, fontSize: 14),
          prefixIcon: Icon(icon, color: secondaryGreen, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}