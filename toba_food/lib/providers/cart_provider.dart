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

  // Jumlah item untuk badge
  int get itemCount => _items.length;

  // Hitung total tanpa parsing harga
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.harga * cartItem.quantity; // ✅ tanpa parsing!
    });
    return total;
  }

  // Tambah item ke keranjang
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: 1),
      );
    }
    notifyListeners();
  }

  // Kurangi jumlah 1 item
  void removeSingleItem(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Hapus item sepenuhnya
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Bersihkan keranjang (checkout)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
