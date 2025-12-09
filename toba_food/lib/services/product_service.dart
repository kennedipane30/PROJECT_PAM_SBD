import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/product.dart';

class ProductService {
  // ========================================================
  // 1. GET ALL PRODUCTS
  // ========================================================
  Future<List<Product>> getProducts() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/products');

      final response = await http.get(
        url,
        headers: {"Accept": "application/json"},
      );

      print("🔍 GET Products Status: ${response.statusCode}");
      print("🔍 GET Products Body: ${response.body}");

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❌ Error getProducts: $e");
      return [];
    }
  }

  // ========================================================
  // 2. ADD PRODUCT
  // ========================================================
  Future<bool> addProduct({
    required String nama,
    required String harga,
    required String stok,
    required String deskripsi,
    required String kategori,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse('${ApiConfig.baseUrl}/products');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Hapus format seperti "25.000" → "25000"
      String hargaBersih = harga.replaceAll('.', '').replaceAll(',', '');

      request.fields['nama_produk'] = nama;
      request.fields['harga'] = hargaBersih;
      request.fields['stok'] = stok;
      request.fields['deskripsi'] = deskripsi;
      request.fields['kategori'] = kategori;

      if (imageFile != null && imageFile.existsSync()) {
        request.files
            .add(await http.MultipartFile.fromPath('gambar', imageFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🔍 ADD Product Code: ${response.statusCode}");
      print("🔍 ADD Product Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("❌ Error addProduct: $e");
      return false;
    }
  }

  // ========================================================
  // 3. DELETE PRODUCT
  // ========================================================
  Future<bool> deleteProduct(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${ApiConfig.baseUrl}/products/$id');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("🔍 DELETE Product Status: ${response.statusCode}");
      print("🔍 DELETE Product Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Gagal hapus: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error deleteProduct: $e");
      return false;
    }
  }

  // ========================================================
  // 4. UPDATE PRODUCT
  // ========================================================
  Future<bool> updateProduct(
    int id,
    Map<String, String> data,
    File? imageFile,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // PUT dengan multipart harus memakai POST + _method=PUT
      final uri = Uri.parse('${ApiConfig.baseUrl}/products/$id?_method=PUT');

      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Jika field harga di-edit → hapus titik/koma
      if (data.containsKey('harga')) {
        data['harga'] = data['harga']!.replaceAll('.', '').replaceAll(',', '');
      }

      request.fields.addAll(data);

      if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('gambar', imageFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("🔍 UPDATE Product Status: ${response.statusCode}");
      print("🔍 UPDATE Product Body: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Gagal update: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error updateProduct: $e");
      return false;
    }
  }
}
///welllll