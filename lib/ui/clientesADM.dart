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
      home: const DirectorioClientesScreen(),
    );
  }
}

class DirectorioClientesScreen extends StatelessWidget {
  const DirectorioClientesScreen({super.key});

  // Paleta de colores PEYDAR
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
        leading: Icon(Icons.grid_view_rounded, color: primaryBlue),
        title: Text('Admin Panel', style: TextStyle(color: textNavy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(backgroundColor: primaryBlue, child: const Text('AP', style: TextStyle(color: Colors.white, fontSize: 12))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Directorio de Clientes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textNavy)),
            const Text('Gestiona la base de datos de consumidores activos.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            // BOTÓN NUEVO CLIENTE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                label: const Text('Nuevo Cliente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // BUSCADOR Y FILTRO
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o DNI...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xFFF1F4F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3E5FC),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Filtrar', style: TextStyle(color: Color(0xFF0277BD), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // LISTA DE CLIENTES
            _buildCustomerList(),
            const SizedBox(height: 25),

            // MÉTRICAS
            _buildStatCard(
              title: 'TOTAL CLIENTES',
              value: '1,284',
              subtitle: '+12% este mes',
              color: primaryBlue,
              isBlue: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCustomerList() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('CLIENTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text('IDENTIFICACIÓN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          _customerTile('Juan David Pérez', '1098.455.221', 'JD'),
          _customerTile('Mariana Rodríguez', '52.987.334', 'MR'),
          _customerTile('Carlos Gómez Duarte', '80.112.556', 'CG'),
          _customerTile('Andrea Villamil', '1010.455.988', 'AV'),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _customerTile(String name, String id, String initials) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE3F2FD),
        child: Text(initials, style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: const Text('Registrado: 12 Oct 2023', style: TextStyle(fontSize: 11)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(8)),
        child: Text(id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          const Text('Mostrando 4 de 128', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          _pageBtn('1', true),
          _pageBtn('2', false),
          _pageBtn('3', false),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _pageBtn(String label, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: active ? primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String subtitle, required Color color, required bool isBlue}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), // Textura sutil
          opacity: 0.1,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: isBlue ? Colors.white70 : textNavy.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: isBlue ? Colors.white : textNavy, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(subtitle, style: TextStyle(color: isBlue ? Colors.white : textNavy, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'PEDIDOS'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'CLIENTES'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'REPORTES'),
      ],
    );
  }
}