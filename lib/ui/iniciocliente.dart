import 'package:flutter/material.dart';

class InicioCliente extends StatefulWidget {
  const InicioCliente({super.key});

  @override
  State<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
  int _selectedNavIndex = 0;

  static const Color _darkNavy  = Color(0xFF1A2F6B);
  static const Color _lightBg   = Color.fromARGB(255, 217, 232, 244);
  static const Color _cardGray  = Color.fromARGB(255, 241, 241, 245);
  static const Color _iconPurple = Color.fromARGB(255, 208, 216, 247);
  static const Color _iconGray  = Color(0xFFD0D5DD);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String nombre = args?['nombre'] ?? 'Cliente';

    // Genera iniciales para el avatar (ej: "Juan Pérez" → "JP")
    final String iniciales = nombre
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

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
                    _buildTopBar(context, iniciales),
                    const SizedBox(height: 32),
                    _buildGreeting(nombre),
                    const SizedBox(height: 28),
                    _buildActionCard(
                      iconBgColor: _iconPurple,
                      iconColor: _darkNavy,
                      icon: Icons.local_drink,
                      title: 'Realizar pedido',
                      subtitle:
                          'Recibe agua fresca en la puerta de tu hogar de forma rápida y sencilla.',
                      hasGradient: true,
                      onTap: () {
                        setState(() => _selectedNavIndex = 0);
                        Navigator.pushNamed(context, '/cliente/pedido');
                      },
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
                      onTap: () {
                        setState(() => _selectedNavIndex = 1);
                        Navigator.pushNamed(context, '/cliente/mis-pedidos');
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String iniciales) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.water_drop, color: Color(0xFF3578C4), size: 26),
            SizedBox(width: 8),
            Text(
              'PEYDAR',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkNavy),
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
            GestureDetector(
              onTap: () => _showLogoutDialog(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD8DCE8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    iniciales,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _darkNavy,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content:
            const Text('¿Estás seguro que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF073F9E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Salir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(String nombre) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $nombre 👋',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: _darkNavy,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '¿Qué deseas hacer hoy por tu\nhidratación?',
          style: TextStyle(
              fontSize: 15, color: Colors.grey[600], height: 1.45),
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
                  color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _darkNavy),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey[600], height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
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
            context: context,
            icon: Icons.local_drink,
            label: 'Realizar pedido',
            index: 0,
            route: '/cliente/pedido',
          ),
          _buildNavItem(
            context: context,
            icon: Icons.history,
            label: 'Ver mis pedidos',
            index: 1,
            route: '/cliente/mis-pedidos',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final bool isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        Navigator.pushNamed(context, route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFE8EFF8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isActive ? _darkNavy : Colors.grey[400], size: 22),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _darkNavy),
              ),
            ],
          ],
        ),
      ),
    );
  }
}