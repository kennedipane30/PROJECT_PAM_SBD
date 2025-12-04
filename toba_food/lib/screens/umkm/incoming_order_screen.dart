import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class IncomingOrderScreen extends StatefulWidget {
  @override
  _IncomingOrderScreenState createState() => _IncomingOrderScreenState();
}

class _IncomingOrderScreenState extends State<IncomingOrderScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<dynamic>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _orderService.getIncomingOrders();
    });
  }

  void _handleShipOrder(int orderId) async {
    bool success = await _orderService.shipOrder(orderId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pesanan Dikirim!")));
      _refreshOrders(); // Refresh list agar order yg dikirim hilang/update status
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memproses pesanan")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pesanan Masuk (UMKM)")),
      body: FutureBuilder<List<dynamic>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("Tidak ada pesanan baru"));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var order = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Order #${order['id']} - Rp ${order['total_harga']}"),
                  subtitle: Text("Status: ${order['status']}"),
                  trailing: order['status'] == 'pending' || order['status'] == 'paid'
                      ? ElevatedButton(
                          onPressed: () => _handleShipOrder(order['id']),
                          child: Text("Kirim Barang"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        )
                      : Text(order['status']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}