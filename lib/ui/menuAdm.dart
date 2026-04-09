import 'package:flutter/material.dart';

void main() {
  runApp(const PeydarAdminApp());
}

class PeydarAdminApp extends StatelessWidget {
  const PeydarAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PEYDAR Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Colores de identidad visual PEYDAR
  static const Color primaryBlue = Color(0xFF003DA5); 
  static const Color welcomeBlue = Color(0xFF0D47A1); 
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF001F4F);
  static const Color textLight = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Tarjeta de bienvenida proporcional al texto
            _buildCompactWelcomeCard(),
            const SizedBox(height: 24),
            
            // Sección de Acceso a Módulos
            _buildActionCard(
              icon: Icons.shopping_cart_outlined,
              iconColor: const Color(0xFF3F51B5),
              title: 'Ver pedidos',
              description: 'Gestiona órdenes entrantes, estados de entrega y facturación en tiempo real.',
              actionText: 'Acceder ahora',
            ),
            _buildActionCard(
              icon: Icons.people_outline,
              iconColor: const Color(0xFF00ACC1),
              title: 'Ver clientes',
              description: 'Visualiza tu base de usuarios, preferencias de suscripción y perfiles de contacto.',
              actionText: 'Explorar lista',
            ),
            _buildActionCard(
              icon: Icons.bar_chart_outlined,
              iconColor: const Color(0xFF009688),
              title: 'Ver reportes',
              description: 'Analiza métricas de ventas, rendimiento de rutas y proyecciones de demanda mensual.',
              actionText: 'Ver análisis',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: primaryBlue),
        onPressed: () {},
      ),
      title: const Text(
        'Panel de Control',
        style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildCompactWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: welcomeBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: welcomeBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido de nuevo, Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tu panel de control está listo para gestionar los servicios de hoy.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String actionText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: textLight, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                actionText,
                style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward, color: primaryBlue, size: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Panel'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reportes'),
        ],
      ),
    );
  }
}