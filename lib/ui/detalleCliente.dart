import 'package:flutter/material.dart';

void main() {
  runApp(const PeydarAdminApp());
}

class PeydarAdminApp extends StatelessWidget {
  const PeydarAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'sans-serif'),
      home: const PerfilClienteInfoScreen(),
    );
  }
}

class PerfilClienteInfoScreen extends StatelessWidget {
  const PerfilClienteInfoScreen({super.key});

  // Colores corporativos PEYDAR
  final Color primaryBlue = const Color(0xFF003DA5);
  final Color backgroundGrey = const Color(0xFFF8FAFC);
  final Color textNavy = const Color(0xFF002855);
  final Color cyanAccent = const Color(0xFF4DD0E1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () {},
        ),
        title: Text('Gestión de Clientes', 
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        // Foto del admin eliminada de los actions
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN DE INFORMACIÓN PERSONAL (Sin foto)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ricardo Alarcón', 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textNavy)),
                      _buildBadge('ACTIVO', Colors.green.shade50, Colors.green.shade700),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.badge_outlined, 'DNI', '32.455.901'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.phone_android, 'TELÉFONO', '+54 9 11 5822-4910'),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.email_outlined, 'TIPO', 'CLIENTE PREMIUM'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // TARJETA DE MÉTRICAS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [primaryBlue, const Color(0xFF002855)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text('RESUMEN DE ACTIVIDAD', 
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  const Text('48 Pedidos Totales', 
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Última interacción: hace 3 días', 
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // HISTORIAL DE PEDIDOS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Historial Reciente', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textNavy)),
                Icon(Icons.filter_list, color: textNavy, size: 20),
              ],
            ),
            const SizedBox(height: 15),
            _buildOrderTile('Orden #8812', '24 OCT', ['2 Azules', '1 Celeste'], 'Entregado', Colors.green),
            _buildOrderTile('Orden #8744', '15 OCT', ['4 Azules'], 'Entregado', Colors.green),
            _buildOrderTile('Orden #8621', '30 SEP', ['2 Azules', '2 Celestes'], 'Cancelado', Colors.red),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(value, style: TextStyle(color: textNavy, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildOrderTile(String title, String date, List<String> items, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)),
              const SizedBox(height: 4),
              Text(items.join(', '), style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'PEDIDOS'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'CLIENTES'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'REPORTES'),
      ],
    );
  }
}