// lib/models/product.dart ← PASTIKAN HANYA ADA SATU FILE INI SAJA!

class Product {
  final int id;
  final String namaProduk;
  final int harga; // PASTI INT!
  final String? deskripsi;
  final String? gambar;
  final String umkmNama;
  final String kategori;
  final int stok;
  final int? sellerId; // kalau butuh buat checkout ke UMKM tertentu

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
    // Helper biar aman dari null / string
    int parseInt(dynamic value) => int.tryParse(value.toString()) ?? 0;

    // Ambil nama UMKM (sesuai response API kamu)
    String umkmNama = 'Mitra UMKM';
    if (json['umkm'] != null && json['umkm']['nama_usaha'] != null) {
      umkmNama = json['umkm']['nama_usaha'];
    } else if (json['umkm'] != null && json['umkm']['nama_toko'] != null) {
      umkmNama = json['umkm']['nama_toko'];
    }

    return Product(
      id: parseInt(json['id']),
      namaProduk: json['nama_produk'] ?? 'Produk Tanpa Nama',
      harga: parseInt(json['harga']), // PASTI jadi int
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      umkmNama: umkmNama,
      kategori: json['kategori'] ?? 'Umum',
      stok: parseInt(json['stok']),
      sellerId: parseInt(json['umkm_profile_id']),
    );
  }
}
