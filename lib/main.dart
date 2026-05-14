import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'services/navigation_service.dart';

// IMPORTA TUS PANTALLAS
import 'package:apppeydar/ui/login.dart';
import 'package:apppeydar/ui/menuAdm.dart';
import 'package:apppeydar/ui/ADM-verpedidos.dart';
import 'package:apppeydar/ui/iniciocliente.dart';
import 'package:apppeydar/ui/pedidoscliente.dart';
import 'package:apppeydar/ui/realizarpedido.dart';
import 'package:apppeydar/ui/clientesADM.dart';
import 'package:apppeydar/ui/admCrearusuario.dart';
import 'package:apppeydar/ui/reportes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase (para notificaciones push)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Supabase
  await Supabase.initialize(
    url: 'https://eudhhvqymgohsckxmkbi.supabase.co',
    anonKey: 'sb_publishable_ZyRxAa5cMhMKoqL6bYpgqQ_GWfQnObW',
  );

  // 3. Inicializar FCM
  await FcmService.init();

  runApp(const PeydarApp());
}

class PeydarApp extends StatelessWidget {
  const PeydarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
        '/admin/crear-admin': (context) => const RegistrarUsuarioScreen(modoAdmin: true),
        '/cliente': (context) => const InicioCliente(),
        '/cliente/pedido': (context) => const RealizarPedidoPage(),
        '/cliente/mis-pedidos': (context) => const MisPedidosPage(),
        '/admin/reportes': (context) => const ReportesScreen(),
      },
    );
  }
}