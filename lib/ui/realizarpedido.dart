import 'package:flutter/material.dart';

void main() {
  runApp(const PeydarApp());
}

class PeydarApp extends StatelessWidget {
  const PeydarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peydar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A2F6B)),
        useMaterial3: true,
      ),
      home: const RealizarPedidoScreen(),
    );
  }
}

class RealizarPedidoScreen extends StatefulWidget {
  const RealizarPedidoScreen({super.key});

  @override
  State<RealizarPedidoScreen> createState() => _RealizarPedidoScreenState();
}

class _RealizarPedidoScreenState extends State<RealizarPedidoScreen> {
  int _qtyCarga = 0;
  int _qtyCompra = 0;
  int _selectedNavIndex = 0;

  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  static const Color _darkNavy = Color(0xFF1A2F6B);
  static const Color _lightBg = Color(0xFFEFF4F9);
  static const Color _cyan = Color(0xFF6DD5ED);
  static const Color _cardBg = Color(0xFFFFFFFF);

  @override
  void dispose() {
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildTopBar(),
                    const SizedBox(height: 30),
                    _buildTitle(),
                    const SizedBox(height: 24),
                    _buildRecargaCard(),
                    const SizedBox(height: 14),
                    _buildCompraInicialCard(),
                    const SizedBox(height: 28),
                    _buildDeliverySection(),
                    const SizedBox(height: 28),
                    _buildResumenButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.water_drop, color: Color(0xFF3578C4), size: 26),
            const SizedBox(width: 8),
            const Text(
              'PEYDAR',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _darkNavy,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: _darkNavy, size: 26),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Realizar pedido',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: _darkNavy,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hidratación directo a tu puerta.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecargaCard() {
    return _buildProductCard(
      badgeText: 'ECONÓMICO',
      badgeColor: const Color(0xFFE8EAF6),
      badgeTextColor: _darkNavy,
      iconBgColor: _cyan,
      icon: Icons.refresh,
      iconColor: Colors.white,
      title: 'Recarga de Bidones',
      subtitle: 'Intercambia tus envases vacíos de 20L por unos llenos y frescos.',
      quantity: _qtyCarga,
      onDecrement: () {
        if (_qtyCarga > 0) setState(() => _qtyCarga--);
      },
      onIncrement: () => setState(() => _qtyCarga++),
      hasBottleImage: true,
    );
  }

  Widget _buildCompraInicialCard() {
    return _buildProductCard(
      badgeText: 'NUEVO',
      badgeColor: const Color(0xFFB2EBF2),
      badgeTextColor: const Color(0xFF006064),
      iconBgColor: _cyan,
      icon: Icons.verified,
      iconColor: Colors.white,
      title: 'Compra de Bidones',
      subtitle: 'Incluye el envase de 20L nuevo + agua mineral purificada.',
      quantity: _qtyCompra,
      onDecrement: () {
        if (_qtyCompra > 0) setState(() => _qtyCompra--);
      },
      onIncrement: () => setState(() => _qtyCompra++),
      hasBottleImage: true,
    );
  }

  Widget _buildProductCard({
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    required Color iconBgColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int quantity,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required bool hasBottleImage,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Bottle watermark image (right side)
          if (hasBottleImage)
            Positioned(
              right: 0,
              bottom: 0,
              top: 60,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        const Color(0xFFE8F4FB).withOpacity(0.6),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: CustomPaint(
                    painter: _BottlePainter(),
                  ),
                ),
              ),
            ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _darkNavy,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 220,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildQuantityBtn(
                      icon: Icons.remove,
                      filled: false,
                      onTap: onDecrement,
                    ),
                    SizedBox(
                      width: 52,
                      child: Center(
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _darkNavy,
                          ),
                        ),
                      ),
                    ),
                    _buildQuantityBtn(
                      icon: Icons.add,
                      filled: true,
                      onTap: onIncrement,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityBtn({
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled ? _darkNavy : Colors.white,
          shape: BoxShape.circle,
          border: filled
              ? null
              : Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: _darkNavy.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : _darkNavy,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.local_shipping, color: Color(0xFF2E7D6B), size: 24),
            const SizedBox(width: 10),
            const Text(
              'Información de Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _darkNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildFieldLabel('DIRECCIÓN DE ENTREGA'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _direccionController,
          hint: 'Calle, número, departamento',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('NÚMERO DE TELÉFONO'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _telefonoController,
          hint: '+51 ',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 254, 254, 254),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: _darkNavy,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildResumenButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Resumen del Pedido',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.local_drink,
            label: 'Realizar pedido',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.history,
            label: 'Ver mis pedidos',
            index: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8EFF8) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? _darkNavy : Colors.grey[400],
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _darkNavy,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Painter para simular la silueta del bidón de agua
class _BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCDE8F5).withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final cx = size.width * 0.55;
    final bottleWidth = size.width * 0.52;
    final bottleHeight = size.height * 0.72;
    final top = size.height * 0.1;

    // Cap
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, top + 10),
        width: bottleWidth * 0.45,
        height: 18,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(capRect, paint);

    // Neck
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, top + 26),
        width: bottleWidth * 0.35,
        height: 20,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(neckRect, paint);

    // Body
    final bodyPath = Path()
      ..moveTo(cx - bottleWidth * 0.28, top + 36)
      ..quadraticBezierTo(
        cx - bottleWidth * 0.5,
        top + 50,
        cx - bottleWidth * 0.5,
        top + 80,
      )
      ..lineTo(cx - bottleWidth * 0.5, top + bottleHeight - 20)
      ..quadraticBezierTo(
        cx - bottleWidth * 0.5,
        top + bottleHeight,
        cx - bottleWidth * 0.3,
        top + bottleHeight,
      )
      ..lineTo(cx + bottleWidth * 0.3, top + bottleHeight)
      ..quadraticBezierTo(
        cx + bottleWidth * 0.5,
        top + bottleHeight,
        cx + bottleWidth * 0.5,
        top + bottleHeight - 20,
      )
      ..lineTo(cx + bottleWidth * 0.5, top + 80)
      ..quadraticBezierTo(
        cx + bottleWidth * 0.5,
        top + 50,
        cx + bottleWidth * 0.28,
        top + 36,
      )
      ..close();

    canvas.drawPath(bodyPath, paint);

    // Water fill inside bottle
    final waterPaint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final waterPath = Path()
      ..moveTo(cx - bottleWidth * 0.48, top + 120)
      ..quadraticBezierTo(cx, top + 110, cx + bottleWidth * 0.48, top + 120)
      ..lineTo(cx + bottleWidth * 0.48, top + bottleHeight - 22)
      ..quadraticBezierTo(
          cx + bottleWidth * 0.48, top + bottleHeight - 5, cx + bottleWidth * 0.28, top + bottleHeight - 2)
      ..lineTo(cx - bottleWidth * 0.28, top + bottleHeight - 2)
      ..quadraticBezierTo(
          cx - bottleWidth * 0.48, top + bottleHeight - 5, cx - bottleWidth * 0.48, top + bottleHeight - 22)
      ..close();

    canvas.drawPath(waterPath, waterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}