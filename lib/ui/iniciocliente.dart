import 'package:flutter/material.dart';

void main() {
  runApp(const AzureFlowApp());
}

class AzureFlowApp extends StatelessWidget {
  const AzureFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PEYDAR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A2F6B)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  static const Color _darkNavy = Color(0xFF1A2F6B);
  static const Color _lightBg = Color.fromARGB(255, 217, 232, 244);
  static const Color _cardGray = Color.fromARGB(255, 241, 241, 245);
  static const Color _iconPurple = Color.fromARGB(255, 208, 216, 247);
  static const Color _iconGray = Color(0xFFD0D5DD);

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
                    const SizedBox(height: 32),
                    _buildGreeting(),
                    const SizedBox(height: 28),
                    _buildActionCard(
                      iconBgColor: _iconPurple,
                      iconColor: _darkNavy,
                      icon: Icons.local_drink,
                      title: 'Realizar pedido',
                      subtitle:
                          'Recibe agua fresca en la puerta de tu hogar de forma rápida y sencilla.',
                      hasGradient: true,
                      onTap: () => setState(() => _selectedNavIndex = 0),
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      iconBgColor: _iconGray,
                      iconColor: Colors.grey[700]!,
                      icon: Icons.history,
                      title: 'Ver mis pedidos',
                      subtitle:
                          'Consulta el estado de tus entregas actuales y revisa tu historial de compras.',
                      hasGradient: false,
                      onTap: () => setState(() => _selectedNavIndex = 1),
                    ),
                    const SizedBox(height: 16),
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
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: _darkNavy, size: 26),
              onPressed: () {},
            ),
            const SizedBox(width: 4),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DCE8),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'JD',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _darkNavy,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hola, Bienvenido',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: _darkNavy,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '¿Qué deseas hacer hoy por tu\nhidratación?',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required Color iconBgColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool hasGradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: hasGradient
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFE8F0FB),
                    Color(0xFFD6E8F8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasGradient ? null : _cardGray,
          boxShadow: hasGradient
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _darkNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.45,
              ),
            ),
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

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final yOffset = size.height * 0.3 + i * 22.0;
      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10,
          yOffset - 8,
          x + 20,
          yOffset,
        );
      }
      canvas.drawPath(path, paint);
    }

    // Subtle circle accents
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.2), 50, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.85), 35, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}