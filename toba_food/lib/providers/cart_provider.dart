import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  // Hitung jumlah item di keranjang (untuk badge notifikasi)
  int get itemCount => _items.length;

  // Hitung total harga
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      // Pastikan harga produk di-parse dengan benar ke double
      double harga = double.tryParse(cartItem.product.harga.toString()) ?? 0;
      total += harga * cartItem.quantity;
    });
    return total;
  }

  // Tambah ke keranjang
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Jika produk sudah ada, tambah jumlahnya
      _items.update(
        product.id,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      // Jika belum ada, masukkan baru
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: 1),
      );
    }
    notifyListeners();
  }

  // Kurangi jumlah atau hapus item
  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items.update(
          productId,
          (existing) => CartItem(
              product: existing.product, quantity: existing.quantity - 1));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Hapus item sepenuhnya dari keranjang
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Bersihkan keranjang (setelah checkout)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}