import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  // Ganti IP sesuai IP komputer Anda (jika emulator pakai 10.0.2.2)
  final String baseUrl = "http://10.0.2.2:8000/api"; 

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // =================================================================
  // [MODIFIKASI] FUNGSI CHECKOUT
  // Menambahkan parameter paymentMethod & alamat untuk dikirim ke API
  // =================================================================
  Future<bool> checkout({
    required int umkmId,
    required List<Map<String, dynamic>> items,
    required String paymentMethod, // <--- Ditambahkan (cod / transfer)
    required String alamat,        // <--- Ditambahkan
  }) async {
    String token = await _getToken();
    
    try {
      print("\n=== MULAI REQUEST CHECKOUT ===");
      
      // Data yang akan dikirim ke Laravel
      Map<String, dynamic> bodyData = {
        'umkm_id': umkmId,
        'items': items,
        'metode_pembayaran': paymentMethod, // Wajib sesuai validasi Laravel
        'alamat_pengiriman': alamat,        // Opsional tapi berguna
      };

      print("Mengirim Data: ${json.encode(bodyData)}");

      final response = await http.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(bodyData),
      );

      print("Server Response Code: ${response.statusCode}");
      print("Server Response Body: ${response.body}"); 
      print("==============================\n");

      // 201 Created atau 200 OK dianggap sukses
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("FATAL ERROR FLUTTER: $e");
      return false;
    }
  }

  // =================================================================
  // [TETAP] AMBIL DETAIL ORDER (Untuk Fitur Klik Notifikasi)
  // =================================================================
  Future<Map<String, dynamic>?> getOrderDetail(int orderId) async {
    String token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'), 
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      }
      return null;
    } catch (e) {
      print("Error Get Detail: $e");
      return null;
    }
  }

  // --- UMKM ---
  Future<List<dynamic>> getIncomingOrders() async {
    String token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/umkm/orders'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    }
    return [];
  }

  Future<bool> shipOrder(int orderId) async {
    String token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/umkm/orders/$orderId/ship'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  // --- PEMBELI ---
  Future<List<dynamic>> getMyOrders() async {
    String token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/my-orders'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    }
    return [];
  }

  Future<bool> completeOrder(int orderId) async {
    String token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/complete'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<bool> submitReview(int orderId, int productId, int rating, String comment) async {
    String token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'order_id': orderId,
        'product_id': productId,
        'rating': rating,
        'comment': comment
      }),
    );
    return response.statusCode == 200; 
  }
}