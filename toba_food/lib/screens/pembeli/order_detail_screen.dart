import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  late String _currentStatus;

  // Green Nature Palette - Modern & Elegant (dari login_screen)
  final Color primaryGreen = Color(0xFF3D5A4A);
  final Color secondaryGreen = Color(0xFF6B8E7C);
  final Color lightGreen = Color(0xFFA8C5B5);
  final Color accentGreen = Color(0xFF8FBC8F);
  final Color cream = Color(0xFFF5F1E8);
  final Color darkGreen = Color(0xFF2C3E37);

  // Ganti IP ini jika pakai HP Fisik (misal 192.168.x.x)
  final String _imageBaseUrl = "http://10.0.2.2:8000/storage/";

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order['status'];
  }

  // --- FUNGSI SELESAIKAN PESANAN ---
  void _handleCompleteOrder() async {
    setState(() => _isLoading = true);

    try {
      bool success = await _orderService.completeOrder(widget.order['id']);

      setState(() => _isLoading = false);

      if (success) {
        setState(() {
          _currentStatus = 'completed';
        });

        if (mounted) _showRatingDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal update status"),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // --- FUNGSI RATING ---
  void _showRatingDialog() {
    int rating = 5;
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentGreen, secondaryGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentGreen.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child:
                        Icon(Icons.check_circle, color: Colors.white, size: 40),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Pesanan Selesai!",
                    style: TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Beri penilaian produk:",
                    style: TextStyle(
                      color: secondaryGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  // Bintang Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () =>
                            setDialogState(() => rating = index + 1),
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Color(0xFFFFB800),
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: lightGreen, width: 1.5),
                    ),
                    child: TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: TextStyle(color: darkGreen),
                      decoration: InputDecoration(
                        hintText: "Tulis ulasan...",
                        hintStyle:
                            TextStyle(color: secondaryGreen.withOpacity(0.5)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Nanti Saja",
                    style: TextStyle(
                      color: secondaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, secondaryGreen],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: accentGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Kirim",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      var items = widget.order['items'] as List;
                      if (items.isNotEmpty) {
                        await _orderService.submitReview(
                            widget.order['id'],
                            items[0]['product_id'],
                            rating,
                            commentController.text);
                      }
                      Navigator.pop(ctx);
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Ulasan terkirim!"),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    var items = widget.order['items'] as List;

    bool showButton =
        _currentStatus == 'shipped' || _currentStatus == 'dikirim';

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(
          "Rincian Pesanan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS INFO dengan Design Modern
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(_currentStatus).withOpacity(0.6),
                    _getStatusColor(_currentStatus).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(_currentStatus).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(_currentStatus),
                            _getStatusColor(_currentStatus).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStatusIcon(_currentStatus),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status Pesanan",
                            style: TextStyle(
                              color: secondaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getStatusLabel(_currentStatus),
                            style: TextStyle(
                              color: darkGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 28),

            // Header Section
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentGreen, secondaryGreen],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Produk Dibeli",
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // LIST BARANG dengan Design Card Modern
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                var item = items[i];
                var product = item['product'];

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        lightGreen.withOpacity(0.4),
                        secondaryGreen.withOpacity(0.4)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // Gambar Produk dengan Border Gradient
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentGreen, secondaryGreen],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 70,
                              height: 70,
                              color: cream,
                              child:
                                  (product != null && product['gambar'] != null)
                                      ? Image.network(
                                          "$_imageBaseUrl${product['gambar']}",
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Icon(
                                            Icons.broken_image,
                                            color: lightGreen,
                                          ),
                                        )
                                      : Icon(Icons.fastfood,
                                          color: lightGreen, size: 30),
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        // Info Nama & Harga
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product?['nama_produk'] ?? 'Produk Dihapus',
                                style: TextStyle(
                                  color: darkGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: lightGreen, width: 1),
                                ),
                                child: Text(
                                  "${item['jumlah']} x ${formatCurrency.format(double.tryParse(item['harga_satuan'].toString()) ?? 0)}",
                                  style: TextStyle(
                                    color: secondaryGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Decorative Divider
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            lightGreen.withOpacity(0.3),
                            lightGreen,
                            lightGreen.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentGreen, primaryGreen],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            lightGreen.withOpacity(0.3),
                            lightGreen,
                            lightGreen.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TOTAL HARGA dengan Card Modern
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentGreen.withOpacity(0.6),
                    primaryGreen.withOpacity(0.6)
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentGreen.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Pembayaran",
                      style: TextStyle(
                        color: secondaryGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentGreen.withOpacity(0.15),
                            secondaryGreen.withOpacity(0.15)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        formatCurrency.format(double.tryParse(
                                widget.order['total_harga'].toString()) ??
                            0),
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),

      // TOMBOL KONFIRMASI dengan Gradient Green
      bottomNavigationBar: showButton
          ? Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(
                        color: lightGreen.withOpacity(0.3), width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Container(
                height: 54,
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
                      blurRadius: 20,
                      offset: Offset(0, 8),
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
                  onPressed: _isLoading ? null : _handleCompleteOrder,
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              "Pesanan Diterima & Selesai",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'pending') return Color(0xFFD97706);
    if (status == 'dikirim' || status == 'shipped') return Color(0xFF2563EB);
    if (status == 'selesai' || status == 'completed') return accentGreen;
    return secondaryGreen;
  }

  IconData _getStatusIcon(String status) {
    if (status == 'pending') return Icons.schedule;
    if (status == 'dikirim' || status == 'shipped') return Icons.local_shipping;
    if (status == 'selesai' || status == 'completed') return Icons.check_circle;
    return Icons.info_outline;
  }

  String _getStatusLabel(String status) {
    if (status == 'pending') return 'MENUNGGU';
    if (status == 'dikirim' || status == 'shipped') return 'DALAM PENGIRIMAN';
    if (status == 'selesai' || status == 'completed') return 'SELESAI';
    return status.toUpperCase();
  }
}
