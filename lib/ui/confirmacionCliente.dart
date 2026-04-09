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
      home: const ConfirmacionPedidoScreen(),
    );
  }
}

class ConfirmacionPedidoScreen extends StatelessWidget {
  const ConfirmacionPedidoScreen({super.key});

  // Colores consistentes con la marca PEYDAR
  final Color primaryBlue = const Color(0xFF003DA5);
  final Color accentLightBlue = const Color(0xFF4FC3F7);
  final Color textNavy = const Color(0xFF002855);
  final Color backgroundGrey = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Confirmación',
          style: TextStyle(color: textNavy, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // ILUSTRACIÓN CENTRAL DE ÉXITO
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(Icons.water_drop, color: textNavy, size: 80),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentLightBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Text(
              '¡Pedido Realizado\nExitosamente!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.w900, 
                color: textNavy,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'Tu hidratación está en camino. Pronto recibirás noticias de nuestro repartidor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // TARJETA DE RESUMEN RÁPIDO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      icon: Icons.receipt_long_outlined,
                      label: 'ID DE PEDIDO',
                      value: '#01',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Color(0xFFF1F4F8), thickness: 1),
                    ),
                    _buildSummaryRow(
                      icon: Icons.location_on_outlined,
                      label: 'DIRECCIÓN DE ENTREGA',
                      value: 'Av. Santa Margarita',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 50),
            
            // ACCIONES FINALES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                        shadowColor: primaryBlue.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Regresar al inicio',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: textNavy, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.grey, 
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold, 
                  color: textNavy,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}