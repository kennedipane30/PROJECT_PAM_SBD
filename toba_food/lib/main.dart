import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart'; // 1. Tambahkan Import ini
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()), // 2. Tambahkan Provider ini
      ],
      child: MaterialApp(
        title: 'Toba Food',
        debugShowCheckedModeBanner: false, // Opsional: Menghilangkan banner debug
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LoginScreen(),
        routes: {'/login': (ctx) => LoginScreen()},
      ),
    );
  }
}