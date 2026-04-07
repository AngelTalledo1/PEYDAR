import 'package:flutter/material.dart';

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
        fontFamily: 'sans-serif', // Recomiendo usar 'Inter' o 'Poppins' en pubspec.yaml
        useMaterial3: true,
      ),
      home: const MisPedidosScreen(),
    );
  }
}

class MisPedidosScreen extends StatelessWidget {
  const MisPedidosScreen({super.key});

  // Paleta de colores exacta de la imagen
  static const Color primaryBlue = Color(0xFF005BCB);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSectionLabel('PEDIDO EN CURSO'),
            const SizedBox(height: 16),
            _buildActiveOrderCard(),
            const SizedBox(height: 40),
            _buildHistoryHeader(),
            const SizedBox(height: 16),
            _buildHistoryItem(
              title: '5 Recargas ',
              id: 'AF-88219',
              date: '12 Oct, 2023',
              price: '\$42.50',
              status: 'ENTREGADO',
              statusColor: const Color(0xFF22C55E),
              statusBg: const Color(0xFFF0FDF4),
              icon: Icons.water_drop,
              iconColor: const Color(0xFF0891B2),
              iconBg: const Color(0xFFECFEFF),
            ),
            _buildHistoryItem(
              title: '2 Recargas de 20L',
              id: 'AF-87902',
              date: '05 Oct, 2023',
              price: '\$18.00',
              status: 'ENTREGADO',
              statusColor: const Color(0xFF22C55E),
              statusBg: const Color(0xFFF0FDF4),
              icon: Icons.water_drop,
              iconColor: const Color(0xFF0891B2),
              iconBg: const Color(0xFFECFEFF),
            ),
            _buildHistoryItem(
              title: '1 Botellón Extra',
              id: 'AF-87110',
              date: '28 Sep, 2023',
              price: '\$9.00',
              status: 'CANCELADO',
              statusColor: const Color(0xFFEF4444),
              statusBg: const Color(0xFFFEF2F2),
              icon: Icons.block,
              iconColor: const Color(0xFFB91C1C),
              iconBg: const Color(0xFFFEF2F2),
            ),
            const SizedBox(height: 24),
            _buildLoadMoreButton(),
            const SizedBox(height: 100), // Espacio para la barra inferior
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundGrey,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: const Icon(Icons.water_drop, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('PEYDAR', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none, color: Color(0xFF475569)), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mis Pedidos', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: textDark)),
        SizedBox(height: 8),
        Text('Gestiona tus entregas de agua y recargas activas.', style: TextStyle(fontSize: 16, color: textLight)),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), letterSpacing: 1.1));
  }

  Widget _buildActiveOrderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text('En camino', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('3 Recargas de 20L', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const Text('Llega hoy, aprox. 14:30 - 15:00', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: const Text('Ver Mapa', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionLabel('HISTORIAL RECIENTE'),
        Row(
          children: [
            const Text('Filtros', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            const Icon(Icons.filter_list, color: primaryBlue, size: 18),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String title, required String id, required String date,
    required String price, required String status, required Color statusColor,
    required Color statusBg, required IconData icon, required Color iconColor, required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('ID: #$id  •  $date', style: const TextStyle(color: textLight, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: statusColor, size: 12),
                      const SizedBox(width: 4),
                      Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD1D5DB)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text('Cargar más pedidos', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_basket_outlined, color: textLight),
              SizedBox(height: 4),
              Text('Realizar pedido', style: TextStyle(color: textLight, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(24)),
            child: const Row(
              children: [
                Icon(Icons.history, color: primaryBlue, size: 20),
                SizedBox(width: 8),
                Text('Ver mis pedidos', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}