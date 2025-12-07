import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/product.dart';

class ProductService {
  
  // 1. FUNGSI GET PRODUCTS (TIDAK DIUBAH)
  Future<List<Product>> getProducts() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/products');
      
      final response = await http.get(url, headers: {
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error getProducts: $e");
      return [];
    }
  }

  // 2. FUNGSI ADD PRODUCT (TIDAK DIUBAH)
  Future<bool> addProduct({
    required String nama,
    required String harga,
    required String stok,
    required String deskripsi,
    required String kategori,
    File? imageFile,
  }) async {
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('${ApiConfig.baseUrl}/products'); 
    
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // --- FIX: BERSIHKAN FORMAT HARGA ---
    // Mengubah "25.000" menjadi "25000" agar diterima Laravel (numeric)
    String hargaBersih = harga.replaceAll('.', '').replaceAll(',', '');
    
    request.fields['nama_produk'] = nama;
    request.fields['harga']       = hargaBersih; // Kirim yang bersih
    request.fields['stok']        = stok;
    request.fields['deskripsi']   = deskripsi;
    request.fields['kategori']    = kategori;

    if (imageFile != null && imageFile.existsSync()) {
      request.files.add(await http.MultipartFile.fromPath(
        'gambar', 
        imageFile.path,
      ));
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Debugging: Lihat pesan error asli dari Laravel di Terminal
      print("--- SERVER RESPONSE ---");
      print("Code: ${response.statusCode}");
      print("Body: ${response.body}"); 

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error Upload Exception: $e");
      return false;
    }
  }

  // --- 3. FUNGSI DELETE PRODUCT (BARU - UNTUK MENGATASI ERROR HOMESCREEN) ---
  Future<bool> deleteProduct(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${ApiConfig.baseUrl}/products/$id');

      final response = await http.delete(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal hapus produk: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error deleteProduct: $e");
      return false;
    }
  }

  // --- 4. FUNGSI UPDATE PRODUCT (BARU - UNTUK EDIT PRODUCT SCREEN) ---
  Future<bool> updateProduct(int id, Map<String, String> data, File? imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Trik Laravel: Gunakan POST dengan parameter _method=PUT agar bisa upload file saat update
      final uri = Uri.parse('${ApiConfig.baseUrl}/products/$id?_method=PUT');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Bersihkan harga jika ada di dalam data
      if (data.containsKey('harga')) {
        data['harga'] = data['harga']!.replaceAll('.', '').replaceAll(',', '');
      }

      // Masukkan semua data teks ke fields
      request.fields.addAll(data);

      // Jika ada gambar baru, masukkan ke files
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('gambar', imageFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Gagal update produk: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updateProduct: $e");
      return false;
    }
  }
}