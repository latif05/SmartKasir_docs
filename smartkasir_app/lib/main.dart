import 'package:flutter/material.dart';
import 'package:smartkasir_app/data/local_db.dart';
import 'package:smartkasir_app/screens/login_screen.dart';
import 'package:smartkasir_app/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB.db;
  await AuthService.ensureInitialized();

  runApp(const SmartKasirApp());
}

class SmartKasirApp extends StatelessWidget {
  const SmartKasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartKasir',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartKasir - Dashboard')),
      body: const Center(child: Text('Welcome to SmartKasir (MVP scaffold)')),
    );
  }
}
