class UmkmProfile {
  final int id;
  final String namaUsaha;
  final String statusVerifikasi; // pending, approved, rejected
  final String? alasanPenolakan;

  UmkmProfile({
    required this.id,
    required this.namaUsaha,
    required this.statusVerifikasi,
    this.alasanPenolakan,
  });

  factory UmkmProfile.fromJson(Map<String, dynamic> json) {
    return UmkmProfile(
      id: json['id'],
      namaUsaha: json['nama_usaha'],
      statusVerifikasi: json['status_verifikasi'],
      alasanPenolakan: json['alasan_penolakan'],
    );
  }
}