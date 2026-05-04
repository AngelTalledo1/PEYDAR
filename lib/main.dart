import 'package:flutter/material.dart';
import 'package:apppeydar/ui/login.dart';
import 'package:apppeydar/ui/menuAdm.dart';
import 'package:apppeydar/ui/ADM-verpedidos.dart';
import 'package:apppeydar/ui/iniciocliente.dart';
import 'package:apppeydar/ui/pedidoscliente.dart';
import 'package:apppeydar/ui/realizarpedido.dart';
import 'package:apppeydar/ui/clientesADM.dart';
import 'package:apppeydar/ui/admCrearusuario.dart';

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
        '/login': (context) => const LoginPage(),
        '/admin': (context) => const MenuAdm(),
        '/admin/clientes': (context) => const DirectorioClientesScreen(),
        '/admin/pedidos': (context) => const GestionPedidosScreen(),
        '/admin/crear-usuario': (context) => const RegistrarUsuarioScreen(),
        '/cliente': (context) => const InicioCliente(),
        '/cliente/pedido': (context) => const RealizarPedidoPage(),
        '/cliente/mis-pedidos': (context) => const MisPedidosPage(),
      },
    );
  }
}