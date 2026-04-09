import 'package:flutter/material.dart';

void main() {
  runApp(const PeydarApp());
}

class PeydarApp extends StatelessWidget {
  const PeydarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'sans-serif'),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const RealizarPedidoScreen(),
    const MisPedidosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: const Color(0xFF003DA5),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.delete_outline), label: 'Realizar pedido'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Ver mis pedidos'),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA 1: REALIZAR PEDIDO ---
class RealizarPedidoScreen extends StatelessWidget {
  const RealizarPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Realizar pedido', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF002855))),
            const Text('Hidratación directo a tu puerta.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            
            _buildSectionCard(
              title: 'Recarga de Bidones',
              tag: 'ECONÓMICO',
              icon: Icons.refresh,
              isHighlight: true,
              subtitle: 'Intercambia tus envases vacíos de 20L.',
              items: ['Bidón Azul', 'Bidón Celeste'],
            ),
            const SizedBox(height: 20),
            
            _buildSectionCard(
              title: 'Compra de Bidones',
              tag: 'NUEVO',
              icon: Icons.verified_user_outlined,
              isHighlight: true,
              subtitle: 'Incluye el envase de 20L nuevo + agua.',
              items: ['Bidón Azul', 'Bidón Celeste'],
            ),
            const SizedBox(height: 25),
            
            _buildDeliveryInfo(),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003DA5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Resumen del Pedido', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 0),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String tag, required IconData icon, required String subtitle, required List<String> items, bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isHighlight ? Border.all(color: Colors.blue.shade200, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(icon, color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 15),
          ...items.map((item) => _buildCounterItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildCounterItem(String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(width: 4, height: 20, color: Colors.blue),
            const SizedBox(width: 10),
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.remove_circle_outline, color: Colors.grey),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text('0', style: TextStyle(fontWeight: FontWeight.bold))),
            const Icon(Icons.add_circle, color: Color(0xFF002855)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping, color: Color(0xFF002855)),
              SizedBox(width: 10),
              Text('Información de Entrega', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          _buildSmallField('DIRECCIÓN DE ENTREGA', 'Calle, número, departamento', Icons.location_on),
          const SizedBox(height: 15),
          _buildSmallField('NÚMERO DE TELÉFONO', '+51', Icons.phone),
        ],
      ),
    );
  }

  Widget _buildSmallField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18),
            hintText: hint,
            filled: true,
            fillColor: Colors.white70,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

// --- PANTALLA 2: MIS PEDIDOS ---
class MisPedidosScreen extends StatelessWidget {
  const MisPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mis Pedidos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF002855))),
            const Text('Gestiona tus entregas de agua y recargas activas.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            
            const Text('PEDIDO EN CURSO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF003DA5), letterSpacing: 1)),
            const SizedBox(height: 15),
            
            _buildActiveOrderCard(),
            const SizedBox(height: 30),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('HISTORIAL RECIENTE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list, size: 18), label: const Text('Filtros')),
              ],
            ),
            _buildHistoryItem('5 Recargas + 1 Dispensador', '\$42.50', 'ENTREGADO', Colors.green),
            _buildHistoryItem('2 Recargas de 20L', '\$18.00', 'ENTREGADO', Colors.green),
            _buildHistoryItem('1 Botellón Extra', '\$9.00', 'CANCELADO', Colors.red),
            
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text('Cargar más pedidos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0052D4), Color(0xFF003DA5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(Icons.local_shipping, color: Colors.white, size: 14), SizedBox(width: 5), Text('En camino', style: TextStyle(color: Colors.white, fontSize: 12))],
            ),
          ),
          const SizedBox(height: 15),
          const Text('3 Recargas de 20L', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Llega hoy, aprox. 14:30 - 15:00', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue), child: const Text('Ver Mapa')),
          const Divider(height: 40, color: Colors.white24),
          Row(
            children: [
              const CircleAvatar(backgroundColor: Colors.black26, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Repartidor asignado', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('Carlos Mendoza', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
              ),
              CircleAvatar(backgroundColor: Colors.white24, child: IconButton(icon: const Icon(Icons.phone, color: Colors.white), onPressed: () {})),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String price, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(status == 'CANCELADO' ? Icons.block : Icons.water_drop, color: statusColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('ID: #AF-88219 • 12 Oct, 2023', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ]),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

AppBar _buildAppBar() {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: const Padding(padding: EdgeInsets.all(8.0), child: CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.water_drop, color: Color(0xFF003DA5), size: 18))),
    title: const Text('PEYDAR', style: TextStyle(color: Color(0xFF003DA5), fontWeight: FontWeight.bold)),
    actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Color(0xFF002855)))],
  );
}