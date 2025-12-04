import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UmkmService {
  // Ganti URL ini sesuai kebutuhan:
  // Jika pakai Emulator Android Studio: http://10.0.2.2:8000/api
  // Jika pakai HP fisik (USB Debugging): http://192.168.x.x:8000/api (sesuai IP Laptop)
  final String baseUrl = "http://10.0.2.2:8000/api"; 

  // Helper untuk ambil token
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. Cek Status UMKM (Approved/Pending/Rejected/Not Registered)
  Future<Map<String, dynamic>> checkStatus() async {
    String? token = await _getToken();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/umkm/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Jika error, anggap belum daftar atau ada masalah koneksi
        return {'status': 'error', 'message': 'Gagal mengambil status'};
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // 2. Register UMKM dengan Upload Foto KTP
  Future<bool> registerUmkm(String nama, String alamat, File fotoKtp) async {
    String? token = await _getToken();
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/umkm/register'));
      
      // Header Authorization
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Field Data
      request.fields['nama_usaha'] = nama;
      request.fields['alamat_usaha'] = alamat;
      
      // File Data
      request.files.add(await http.MultipartFile.fromPath('foto_ktp', fotoKtp.path));

      // Kirim Request
      var response = await request.send();

      // Cek response stream
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        // Debugging: Baca respons error jika ada
        final respStr = await response.stream.bytesToString();
        print("Error Register: $respStr");
        return false;
      }
    } catch (e) {
      print("Exception Register: $e");
      return false;
    }
  }
}