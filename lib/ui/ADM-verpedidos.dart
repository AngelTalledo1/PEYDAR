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
      home: const GestionPedidosScreen(),
    );
  }
}

class GestionPedidosScreen extends StatelessWidget {
  const GestionPedidosScreen({super.key});

  // Colores corporativos
  final Color primaryBlue = const Color(0xFF003DA5);
  final Color backgroundGrey = const Color(0xFFF8FAFC);
  final Color textNavy = const Color(0xFF002855);

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
        title: Text('Pedidos', 
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestión de Pedidos', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textNavy)),
            const SizedBox(height: 8),
            const Text('Visualiza y gestiona las solicitudes de tus clientes en tiempo real.', 
              style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 25),

            // BUSCADOR
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por ID o nombre de cliente...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // LISTA DE PEDIDOS (Sin fotos de clientes)
            _buildOrderCard(
              name: 'Alejandro Martínez',
              id: '#WF-9821',
              products: '3 Recargas Azul (20L)',
              time: 'Hoy, 10:45 AM',
              status: 'EN CAMINO',
              statusColor: Colors.lightBlue.shade300,
              actionLabel: 'Detalles',
            ),
            _buildOrderCard(
              name: 'Elena Rodriguez',
              id: '#WF-9820',
              products: '2 Botellones Premium, 1 Dispensador',
              time: 'Hoy, 09:12 AM',
              status: 'PENDIENTE',
              statusColor: Colors.grey.shade400,
              actionLabel: 'Asignar',
            ),
            _buildOrderCard(
              name: 'Sofía Valenzuela',
              id: '#WF-9818',
              products: '5 Recargas Azul (20L)',
              time: 'Ayer, 18:30 PM',
              status: 'ENTREGADO',
              statusColor: Colors.green.shade400,
              actionLabel: 'Ver Recibo',
            ),
            _buildOrderCard(
              name: 'Roberto Gómez',
              id: '#WF-9815',
              products: '1 Pack 500ml (24u)',
              time: 'Ayer, 14:15 PM',
              status: 'CANCELADO',
              statusColor: Colors.red.shade300,
              actionLabel: 'Sin Acción',
            ),
            _buildOrderCard(
              name: 'Carlos Ruiz',
              id: '#WF-9812',
              products: '4 Recargas Azul (20L)',
              time: 'Ayer, 11:20 AM',
              status: 'EN CAMINO',
              statusColor: Colors.lightBlue.shade300,
              actionLabel: 'Detalles',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildOrderCard({
    required String name,
    required String id,
    required String products,
    required String time,
    required String status,
    required Color statusColor,
    required String actionLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icono en lugar de foto
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.person_outline, color: primaryBlue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textNavy)),
                    Text('ID: $id', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              // Etiqueta de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('PRODUCTOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(products, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textNavy)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Text(
                actionLabel,
                style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'ORDERS'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'CLIENTS'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'REPORTS'),
      ],
    );
  }
}