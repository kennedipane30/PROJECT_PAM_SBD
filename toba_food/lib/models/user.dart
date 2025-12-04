class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 'buyer' atau 'seller'
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.createdAt,
  });

  // Factory untuk membuat User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'buyer',
      createdAt: json['created_at'],
    );
  }

  // Convert User ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'created_at': createdAt,
    };
  }

  // Helper method untuk cek apakah user adalah seller
  bool get isSeller => role == 'seller';

  // Helper method untuk cek apakah user adalah buyer
  bool get isBuyer => role == 'buyer';
}
