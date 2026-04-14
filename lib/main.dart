import 'package:flutter/material.dart';
import 'ui/login.dart';
import 'ui/menuAdm.dart';
import 'ui/iniciocliente.dart';

void main() {
  runApp(const PeydarApp());
}

class PeydarApp extends StatelessWidget {
  const PeydarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PEYDAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003A93),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login':   (context) => const LoginPage(),
        '/admin':   (context) => const MenuAdm(),
        '/cliente': (context) => const InicioCliente(),
      },
    );
  }
}