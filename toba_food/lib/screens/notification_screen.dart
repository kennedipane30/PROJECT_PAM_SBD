import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// [BARU] Import halaman detail pesanan UMKM
// Pastikan path-nya sesuai dengan struktur folder Anda
import 'umkm/umkm_order_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  // Green Nature Palette - Modern & Elegant
  final Color primaryGreen = Color(0xFF3D5A4A);
  final Color secondaryGreen = Color(0xFF6B8E7C);
  final Color lightGreen = Color(0xFFA8C5B5);
  final Color accentGreen = Color(0xFF8FBC8F);
  final Color cream = Color(0xFFF5F1E8);
  final Color darkGreen = Color(0xFF2C3E37);

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Sesuaikan IP Address
    final String baseUrl = "http://10.0.2.2:8000/api/notifications";

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _notifications = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error Fetch Notif: $e");
      setState(() => _isLoading = false);
    }
  }

  // Fungsi Helper untuk Navigasi
  void _handleNotificationTap(Map<String, dynamic> notif) {
    // Cek apakah notifikasi ini terkait order
    if (notif['order_id'] != null) {
      // Ambil ID Order
      int orderId = int.tryParse(notif['order_id'].toString()) ?? 0;

      if (orderId != 0) {
        // Navigasi ke Detail Order
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UmkmOrderDetailScreen(
              orderId: orderId,
            ),
          ),
        );
      }
    } else {
      // Jika notifikasi umum (bukan order), bisa tampilkan dialog atau snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Info: ${notif['message']}"),
          backgroundColor: accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Notifikasi",
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
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
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: accentGreen,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Memuat notifikasi...",
                    style: TextStyle(
                      color: secondaryGreen,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              lightGreen.withOpacity(0.3),
                              lightGreen.withOpacity(0.1)
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_none_outlined,
                          size: 80,
                          color: secondaryGreen,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Belum Ada Notifikasi",
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Notifikasi Anda akan muncul di sini",
                        style: TextStyle(
                          color: secondaryGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifications.length,
                  itemBuilder: (ctx, index) {
                    var notif = _notifications[index];

                    // Cek status baca untuk styling
                    bool isRead =
                        notif['is_read'] == 1 || notif['is_read'] == true;

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isRead
                            ? null
                            : LinearGradient(
                                colors: [
                                  accentGreen.withOpacity(0.05),
                                  lightGreen.withOpacity(0.08),
                                ],
                              ),
                        color: isRead ? cream : null,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRead
                              ? lightGreen.withOpacity(0.3)
                              : accentGreen.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: lightGreen.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),

                        // Ikon
                        leading: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isRead
                                  ? [
                                      lightGreen.withOpacity(0.3),
                                      secondaryGreen.withOpacity(0.2)
                                    ]
                                  : [accentGreen, secondaryGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: isRead ? secondaryGreen : Colors.white,
                            size: 24,
                          ),
                        ),

                        // Judul
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                notif['title'] ?? 'Notifikasi',
                                style: TextStyle(
                                  color: darkGreen,
                                  fontWeight: isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: accentGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),

                        // Isi Pesan & Tanggal
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Text(
                              notif['message'] ?? '',
                              style: TextStyle(
                                color: secondaryGreen,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: lightGreen,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  notif['created_at'] != null
                                      ? DateFormat('dd MMM HH:mm').format(
                                          DateTime.parse(notif['created_at']))
                                      : '-',
                                  style: TextStyle(
                                    color: lightGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Trailing Icon
                        trailing: Icon(
                          Icons.chevron_right,
                          color: secondaryGreen,
                          size: 20,
                        ),

                        // [PENTING] Aksi Klik
                        onTap: () => _handleNotificationTap(notif),
                      ),
                    );
                  },
                ),
    );
  }
}
