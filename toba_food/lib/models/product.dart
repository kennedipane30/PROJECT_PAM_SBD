// lib/models/product.dart

class Product {
  final int id;
  final String namaProduk;
  final double harga; // ✅ DOUBLE!
  final String? deskripsi;
  final String? gambar;
  final String umkmNama;
  final String kategori;
  final int stok;
  final int? sellerId;

  Product({
    required this.id,
    required this.namaProduk,
    required this.harga,
    this.deskripsi,
    this.gambar,
    required this.umkmNama,
    required this.kategori,
    required this.stok,
    this.sellerId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Helper untuk parsing yang aman
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    // Ambil nama UMKM
    String umkmNama = 'Mitra UMKM';
    if (json['umkm'] != null) {
      if (json['umkm']['nama_usaha'] != null) {
        umkmNama = json['umkm']['nama_usaha'];
      } else if (json['umkm']['nama_toko'] != null) {
        umkmNama = json['umkm']['nama_toko'];
      }
    }

    // 🔍 DEBUG: Print untuk cek data
    print('🔍 Parsing Product: ${json['nama_produk']}');
    print('   Harga dari API: ${json['harga']} (${json['harga'].runtimeType})');

    final product = Product(
      id: parseInt(json['id']),
      namaProduk: json['nama_produk'] ?? 'Produk Tanpa Nama',
      harga: parseDouble(json['harga']), // ✅ Parse jadi double
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      umkmNama: umkmNama,
      kategori: json['kategori'] ?? 'Umum',
      stok: parseInt(json['stok']),
      sellerId: json['umkm_profile_id'] != null
          ? parseInt(json['umkm_profile_id'])
          : null,
    );

    print('   ✅ Harga parsed: ${product.harga}');
    return product;
  }

  // Helper method untuk convert ke Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_produk': namaProduk,
      'harga': harga,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'umkm_nama': umkmNama,
      'kategori': kategori,
      'stok': stok,
      'umkm_profile_id': sellerId,
    };
  }
}
