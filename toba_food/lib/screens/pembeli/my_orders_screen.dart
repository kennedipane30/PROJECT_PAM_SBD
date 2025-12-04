import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/order_service.dart';
import 'order_detail_screen.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<dynamic>> _myOrders;

  // Green Nature Palette - Modern & Elegant (dari login_screen)
  final Color primaryGreen = Color(0xFF3D5A4A);
  final Color secondaryGreen = Color(0xFF6B8E7C);
  final Color lightGreen = Color(0xFFA8C5B5);
  final Color accentGreen = Color(0xFF8FBC8F);
  final Color cream = Color(0xFFF5F1E8);
  final Color darkGreen = Color(0xFF2C3E37);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _myOrders = _orderService.getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: Text(
          "Pesanan Saya",
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
      body: FutureBuilder<List<dynamic>>(
        future: _myOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                strokeWidth: 3,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: primaryGreen, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "Gagal memuat data",
                    style: TextStyle(color: darkGreen, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentGreen.withOpacity(0.2),
                          secondaryGreen.withOpacity(0.1)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: primaryGreen,
                      size: 60,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Belum ada pesanan",
                    style: TextStyle(
                      color: secondaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Pesanan Anda akan muncul di sini",
                    style: TextStyle(
                      color: lightGreen,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            color: accentGreen,
            backgroundColor: Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var order = snapshot.data![index];

                // Ambil info produk pertama untuk preview
                var firstItem = (order['items'] as List).isNotEmpty
                    ? order['items'][0]
                    : null;
                String productName = firstItem != null
                    ? firstItem['product']['nama_produk']
                    : 'Item dihapus';

                return GestureDetector(
                  onTap: () async {
                    bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(order: order),
                      ),
                    );

                    if (result == true) {
                      _refresh();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentGreen.withOpacity(0.6),
                          secondaryGreen.withOpacity(0.6)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: accentGreen.withOpacity(0.2),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card: ID & Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [accentGreen, secondaryGreen],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Order #${order['id']}",
                                    style: TextStyle(
                                      color: darkGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              _buildStatusBadge(order['status']),
                            ],
                          ),

                          // Decorative divider
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
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
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Container(
                                    width: 6,
                                    height: 6,
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

                          // Body Card: Produk & Total
                          Row(
                            children: [
                              // Icon Produk
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cream,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: lightGreen.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.restaurant_menu,
                                  color: primaryGreen,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productName,
                                      style: TextStyle(
                                        color: darkGreen,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        letterSpacing: 0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accentGreen.withOpacity(0.15),
                                            secondaryGreen.withOpacity(0.15)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        formatCurrency.format(double.tryParse(
                                                order['total_harga']
                                                    .toString()) ??
                                            0),
                                        style: TextStyle(
                                          color: primaryGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accentGreen.withOpacity(0.2),
                                      secondaryGreen.withOpacity(0.2)
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),

                          // Tanggal
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: lightGreen,
                              ),
                              SizedBox(width: 6),
                              Text(
                                order['created_at'] != null
                                    ? order['created_at']
                                        .toString()
                                        .substring(0, 10)
                                    : '-',
                                style: TextStyle(
                                  color: secondaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper untuk warna status dengan tema green nature
  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    String label;

    switch (status) {
      case 'pending':
        color = Color(0xFFD97706); // Warm orange
        bgColor = Color(0xFFFEF3C7);
        label = 'Menunggu';
        break;
      case 'shipped':
      case 'dikirim':
        color = Color(0xFF2563EB); // Blue
        bgColor = Color(0xFFDBEAFE);
        label = 'Dikirim';
        break;
      case 'completed':
      case 'selesai':
        color = accentGreen;
        bgColor = accentGreen.withOpacity(0.15);
        label = 'Selesai';
        break;
      default:
        color = secondaryGreen;
        bgColor = lightGreen.withOpacity(0.2);
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
