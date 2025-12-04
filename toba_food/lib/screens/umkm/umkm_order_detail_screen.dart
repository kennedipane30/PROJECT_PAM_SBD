import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';

class UmkmOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const UmkmOrderDetailScreen({super.key, required this.orderId});

  @override
  _UmkmOrderDetailScreenState createState() => _UmkmOrderDetailScreenState();
}

class _UmkmOrderDetailScreenState extends State<UmkmOrderDetailScreen>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;
  bool _isProcessing = false;

  late AnimationController _pulseController;

  // Green Nature Palette - Modern & Elegant (sama dengan AddProductScreen)
  final Color primaryGreen = Color(0xFF3D5A4A);
  final Color secondaryGreen = Color(0xFF6B8E7C);
  final Color lightGreen = Color(0xFFA8C5B5);
  final Color accentGreen = Color(0xFF8FBC8F);
  final Color cream = Color(0xFFF5F1E8);
  final Color darkGreen = Color(0xFF2C3E37);

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _fetchOrderDetail() async {
    var data = await _orderService.getOrderDetail(widget.orderId);
    setState(() {
      _orderData = data;
      _isLoading = false;
    });
  }

  void _handleShipOrder() async {
    setState(() => _isProcessing = true);

    bool success = await _orderService.shipOrder(widget.orderId);

    setState(() => _isProcessing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Pesanan berhasil dikonfirmasi & dikirim!"),
            ],
          ),
          backgroundColor: accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.all(20),
        ),
      );
      _fetchOrderDetail();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text("Gagal memproses pesanan."),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cream,
              Colors.white,
              cream,
              lightGreen.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated Background Glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Positioned(
                    top: -150,
                    right: -100 + (_pulseController.value * 30),
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accentGreen
                                .withOpacity(0.2 * _pulseController.value),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Main Content
              Column(
                children: [
                  // Custom Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Row(
                      children: [
                        // Back Button
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentGreen, secondaryGreen],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: accentGreen.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(15),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Detail Pesanan",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: darkGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Informasi lengkap pesanan",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(accentGreen),
                              strokeWidth: 3,
                            ),
                          )
                        : _orderData == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox_outlined,
                                        size: 80, color: lightGreen),
                                    SizedBox(height: 16),
                                    Text(
                                      "Data tidak ditemukan",
                                      style: TextStyle(
                                        color: secondaryGreen,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // INFO STATUS CARD
                                    Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accentGreen.withOpacity(0.6),
                                            secondaryGreen.withOpacity(0.6)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentGreen.withOpacity(0.2),
                                            blurRadius: 15,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(21),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        accentGreen,
                                                        secondaryGreen
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: accentGreen
                                                            .withOpacity(0.3),
                                                        blurRadius: 10,
                                                        offset: Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.receipt_long_rounded,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Order ID: #${_orderData!['id']}",
                                                        style: TextStyle(
                                                          color: secondaryGreen,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 12,
                                                                vertical: 6),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors:
                                                                _getStatusColors(
                                                                    _orderData![
                                                                        'status']),
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Text(
                                                          _orderData!['status']
                                                              .toString()
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                            letterSpacing: 1,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 16),
                                            Divider(
                                                color: lightGreen
                                                    .withOpacity(0.5)),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .person_outline_rounded,
                                                    color: secondaryGreen,
                                                    size: 20),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Pembeli:",
                                                  style: TextStyle(
                                                    color: secondaryGreen,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  _orderData!['user']['name'],
                                                  style: TextStyle(
                                                    color: darkGreen,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24),

                                    // SECTION TITLE
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                accentGreen,
                                                secondaryGreen
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Barang Dipesan",
                                          style: TextStyle(
                                            color: darkGreen,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),

                                    // LIST BARANG
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: _orderData!['items'].length,
                                      itemBuilder: (context, index) {
                                        var item = _orderData!['items'][index];
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          padding: EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                lightGreen.withOpacity(0.4),
                                                secondaryGreen.withOpacity(0.4)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: cream,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Icon(
                                                    Icons.shopping_bag_outlined,
                                                    color: primaryGreen,
                                                    size: 24,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item['product']
                                                            ['nama_produk'],
                                                        style: TextStyle(
                                                          color: darkGreen,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        "${item['jumlah']} x ${formatCurrency.format(double.parse(item['harga_satuan']))}",
                                                        style: TextStyle(
                                                          color: secondaryGreen,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  formatCurrency.format(
                                                      double.parse(
                                                          item['subtotal'])),
                                                  style: TextStyle(
                                                    color: accentGreen,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(height: 20),

                                    // TOTAL CARD
                                    Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [accentGreen, secondaryGreen],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentGreen.withOpacity(0.3),
                                            blurRadius: 15,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(17),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Total Harga",
                                                  style: TextStyle(
                                                    color: secondaryGreen,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  formatCurrency.format(
                                                      double.parse(_orderData![
                                                          'total_harga'])),
                                                  style: TextStyle(
                                                    color: darkGreen,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    accentGreen,
                                                    secondaryGreen
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Icon(
                                                Icons.payments_rounded,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 30),

                                    // TOMBOL KONFIRMASI
                                    if (_orderData!['status'] == 'pending' ||
                                        _orderData!['status'] == 'paid')
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
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  accentGreen.withOpacity(0.4),
                                              blurRadius: 30,
                                              offset: Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: _isProcessing
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                  strokeWidth: 3,
                                                ),
                                              )
                                            : Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: _handleShipOrder,
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .local_shipping_outlined,
                                                          color: Colors.white,
                                                          size: 26,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          "KONFIRMASI & KIRIM PESANAN",
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: Colors.white,
                                                            letterSpacing: 1.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),

                                    if (_orderData!['status'] == 'dikirim')
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF3B82F6)
                                                  .withOpacity(0.1),
                                              Color(0xFF2563EB)
                                                  .withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: Color(0xFF3B82F6)
                                                .withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF3B82F6)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.hourglass_empty_rounded,
                                                color: Color(0xFF2563EB),
                                                size: 24,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                "Menunggu konfirmasi pembeli",
                                                style: TextStyle(
                                                  color: Color(0xFF2563EB),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
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

  List<Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return [Color(0xFFF59E0B), Color(0xFFD97706)];
      case 'paid':
        return [Color(0xFF3B82F6), Color(0xFF2563EB)];
      case 'dikirim':
        return [Color(0xFF8B5CF6), Color(0xFF7C3AED)];
      case 'selesai':
        return [accentGreen, secondaryGreen];
      default:
        return [secondaryGreen, primaryGreen];
    }
  }
}
