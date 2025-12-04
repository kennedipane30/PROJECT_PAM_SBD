import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  // GANTI dengan IP komputer Anda jika pakai device fisik
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

// // untuk hp menggunakan kabel data
// static const String _baseUrl = 'http://172.27.81.209:8000/api';






  User? _user;
  String? _token;
  String? errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // ==========================================================
  // FUNGSI REGISTER - SESUAI BACKEND LARAVEL ANDA
  // ==========================================================
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      // ✅ TRIM semua input untuk menghindari whitespace
      final cleanName = name.trim();
      final cleanEmail = email.trim().toLowerCase();
      final cleanPhone = phone.trim();
      final cleanPassword = password.trim();

      print('🔄 Mencoba register ke: $_baseUrl/register');
      print('📤 Data yang dikirim:');
      print('   name: $cleanName');
      print('   email: $cleanEmail');
      print('   phone_number: $cleanPhone');
      print('   role: $role');

      final response = await http
          .post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': cleanName,
          'email': cleanEmail,
          'password': cleanPassword,
          'phone_number': cleanPhone,
          'role': role,
        }),
      )
          .timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout - periksa koneksi internet');
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // ✅ Sesuaikan dengan response Laravel: "access_token" dan "data"
        if (data['access_token'] != null && data['data'] != null) {
          _token = data['access_token'];
          _user = User.fromJson(data['data']);

          // Simpan ke SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          await prefs.setString('user', jsonEncode(data['data']));

          notifyListeners();
          print('✅ Registrasi berhasil dan auto-login!');
          print('   User: ${_user?.name}');
          print('   Role: ${_user?.role}');
        }

        errorMessage = null;
        return true;
      } else {
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Registrasi gagal';

          // Jika ada error validasi dari Laravel
          if (data['errors'] != null) {
            Map<String, dynamic> errors = data['errors'];
            List<String> errorList = [];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.map((e) => e.toString()));
              }
            });
            errorMessage = errorList.join(', ');
          }
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }

        print('❌ Registrasi gagal: $errorMessage');
        return false;
      }
    } on http.ClientException catch (e) {
      print('❌ Network Error: $e');
      errorMessage =
          'Tidak dapat terhubung ke server. Pastikan backend Laravel sudah berjalan.';
      return false;
    } catch (e) {
      print('❌ Unexpected Error: $e');
      errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    }
  }

  // ==========================================================
  // FUNGSI LOGIN - SESUAI BACKEND LARAVEL ANDA
  // ==========================================================
  Future<bool> login(String email, String password) async {
    try {
      // ✅ TRIM dan LOWERCASE email untuk konsistensi
      final cleanEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();

      print('🔄 Mencoba login ke: $_baseUrl/login');
      print('📤 Email: $cleanEmail');
      print('📤 Password length: ${cleanPassword.length}');

      final response = await http
          .post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': cleanEmail,
          'password': cleanPassword,
        }),
      )
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - periksa koneksi internet');
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Sesuaikan dengan response Laravel: "access_token" dan "data"
        if (data['access_token'] == null || data['data'] == null) {
          print('❌ Response tidak lengkap: token atau data null');
          errorMessage = 'Response dari server tidak lengkap';
          return false;
        }

        _token = data['access_token'];
        _user = User.fromJson(data['data']);

        // Simpan ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(data['data']));

        errorMessage = null;
        notifyListeners();

        print('✅ Login berhasil!');
        print('   User: ${_user?.name}');
        print('   Email: ${_user?.email}');
        print('   Role: ${_user?.role}');
        print('   Token: ${_token?.substring(0, 20)}...');

        return true;
      } else if (response.statusCode == 401) {
        errorMessage = 'Email atau password salah';
        print('❌ Login gagal: $errorMessage');
        return false;
      } else if (response.statusCode == 422) {
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Validasi gagal';

          if (data['errors'] != null) {
            Map<String, dynamic> errors = data['errors'];
            List<String> errorList = [];
            errors.forEach((key, value) {
              if (value is List) {
                errorList.addAll(value.map((e) => e.toString()));
              }
            });
            errorMessage = errorList.join(', ');
          }
        } catch (e) {
          errorMessage = 'Data login tidak valid';
        }
        print('❌ Login gagal: $errorMessage');
        return false;
      } else {
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message'] ?? 'Login gagal';
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        print('❌ Login gagal: $errorMessage');
        return false;
      }
    } on http.ClientException catch (e) {
      print('❌ Network Error: $e');
      errorMessage =
          'Tidak dapat terhubung ke server. Pastikan backend sudah jalan.';
      return false;
    } catch (e) {
      print('❌ Unexpected Error: $e');
      errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    }
  }

  // ==========================================================
  // FUNGSI LOAD USER DARI STORAGE (AUTO LOGIN)
  // ==========================================================
  Future<void> loadUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      String? userJson = prefs.getString('user');

      if (_token != null && userJson != null) {
        _user = User.fromJson(jsonDecode(userJson));
        notifyListeners();
        print('✅ User loaded dari storage: ${_user?.name} (${_user?.role})');
      } else {
        print('ℹ️ Tidak ada user tersimpan - perlu login');
      }
    } catch (e) {
      print('❌ Error loading user: $e');
    }
  }

  // ==========================================================
  // FUNGSI LOGOUT
  // ==========================================================
  Future<void> logout() async {
    try {
      // Opsional: Panggil API logout untuk hapus token di server
      if (_token != null) {
        try {
          await http.post(
            Uri.parse('$_baseUrl/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token',
            },
          ).timeout(Duration(seconds: 5));
        } catch (e) {
          print('⚠️ Logout API error (akan tetap logout lokal): $e');
        }
      }

      // Hapus data lokal
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');

      _token = null;
      _user = null;
      errorMessage = null;

      notifyListeners();
      print('✅ Logout berhasil');
    } catch (e) {
      print('❌ Error logout: $e');
    }
  }

  // ==========================================================
  // FUNGSI CHECK CONNECTION (UNTUK DEBUGGING)
  // ==========================================================
  Future<bool> checkConnection() async {
    try {
      print('🔄 Checking connection to: $_baseUrl');

      // Coba hit endpoint register dengan method GET (akan gagal tapi bisa cek connection)
      final response =
          await http.get(Uri.parse(_baseUrl)).timeout(Duration(seconds: 5));

      print('📥 Connection check status: ${response.statusCode}');
      return true; // Kalau tidak error berarti bisa konek
    } catch (e) {
      print('❌ Connection check failed: $e');
      return false;
    }
  }

  // ==========================================================
  // FUNGSI GET USER PROFILE (ME)
  // ==========================================================
  Future<bool> getUserProfile() async {
    if (_token == null) {
      print('❌ Tidak ada token, tidak bisa get profile');
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      ).timeout(Duration(seconds: 10));

      print('📥 Get Profile Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] != null) {
          _user = User.fromJson(data['data']);

          // Update storage
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(data['data']));

          notifyListeners();
          print('✅ Profile updated: ${_user?.name}');
          return true;
        }
      } else if (response.statusCode == 401) {
        print('⚠️ Token expired atau invalid');
        await logout();
        return false;
      }

      return false;
    } catch (e) {
      print('❌ Get profile error: $e');
      return false;
    }
  }
}
