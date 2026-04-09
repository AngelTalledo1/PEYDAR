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
      home: const ResumenPedidoScreen(),
    );
  }
}

class ResumenPedidoScreen extends StatelessWidget {
  const ResumenPedidoScreen({super.key});

  // Colores del ecosistema PEYDAR
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Resumen del Pedido',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Icono Central de Gota
            Center(
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.cyanAccent.shade100.withOpacity(0.5),
                child: Icon(Icons.water_drop, color: Colors.cyan.shade700, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text('Detalle del Pedido', 
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textNavy)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Revisa los productos seleccionados para tu próxima entrega.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),

            // SECCIÓN: RECARGA DE BIDONES
            _buildSectionContainer(
              icon: Icons.menu,
              title: 'Recarga de Bidones',
              children: [
                _buildProductTile('Bidón Azul', 'x 2', Colors.blue.shade700),
                _buildProductTile('Bidón Celeste', 'x 1', Colors.cyan.shade300),
              ],
            ),

            // SECCIÓN: COMPRA INICIAL
            _buildSectionContainer(
              icon: Icons.shopping_basket_outlined,
              title: 'Compra Inicial',
              children: [
                _buildProductTile('Bidón Azul', 'Sin stock pedido', Colors.grey, isOutOfStock: true),
                _buildProductTile('Bidón Celeste', 'x 1', Colors.cyan.shade300),
              ],
            ),

            // SECCIÓN: INFORMACIÓN DE ENTREGA
            _buildSectionContainer(
              icon: Icons.local_shipping_outlined,
              title: 'Información de Entrega',
              children: [
                _buildInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'DIRECCIÓN',
                  content: 'Calle Falsa 123, Depto 4B',
                  subContent: 'Ciudad Autónoma de Buenos Aires',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  label: 'TELÉFONO',
                  content: '+54 9 11 1234-5678',
                  subContent: 'Habilitado para avisos de llegada',
                ),
              ],
            ),

            const SizedBox(height: 30),
            
            // BOTÓN CONFIRMAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Confirmar Pedido', 
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      SizedBox(width: 0),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textNavy, size: 20),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textNavy, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProductTile(String name, String quantity, Color color, {bool isOutOfStock = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isOutOfStock ? Border.all(color: Colors.grey.shade200, style: BorderStyle.solid) : null,
      ),
      child: Row(
        children: [
          Icon(Icons.local_drink, color: color),
          const SizedBox(width: 15),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isOutOfStock ? Colors.transparent : textNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              quantity,
              style: TextStyle(
                color: isOutOfStock ? Colors.grey : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String content, required String subContent}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textNavy, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(fontWeight: FontWeight.bold, color: textNavy, fontSize: 14)),
                Text(subContent, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}