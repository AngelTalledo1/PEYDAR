import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apppeydar/services/order_service.dart';

class InicioCliente extends StatefulWidget {
  const InicioCliente({super.key});

  @override
  State<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
  int? _usuarioId;
  late final RealtimeChannel _realtimeChannel;
  int _selectedNavIndex = 0;

  int _deudaAzul = 0;
  int _deudaCeleste = 0;
  bool _deudaLoaded = false;

  @override
  void initState() {
    super.initState();
    _initRealtime();
  }

  void _initRealtime() {
    _realtimeChannel = Supabase.instance.client.channel('inicio-cliente');
    _realtimeChannel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'pedidos',
      callback: (_) {
        if (mounted && _usuarioId != null) {
          _cargarDeuda(_usuarioId!);
        }
      },
    ).subscribe();
  }

  void _cargarDeuda(int? usuarioId) async {
    if (usuarioId == null) return;
    final deuda = await OrderService.obtenerDeudaCliente(usuarioId);
    if (mounted) {
      setState(() {
        _deudaAzul = deuda['azul'] ?? 0;
        _deudaCeleste = deuda['celeste'] ?? 0;
      });
    }
  }

  static const Color _darkNavy  = Color(0xFF002855);
  static const Color _lightBg   = Color(0xFFF8FAFC);
  static const Color _primaryBlue = Color(0xFF003DA5);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String nombre = args?['nombre'] ?? 'Cliente';
    final int? usuarioId = args?['id'] ?? args?['usuario_id'];
    _usuarioId ??= usuarioId;

    if (usuarioId != null && !_deudaLoaded) {
      _deudaLoaded = true;
      _cargarDeuda(usuarioId);
    }

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
                    _buildWelcomeCard(nombre),
                    const SizedBox(height: 24),
                    if (_deudaAzul > 0 || _deudaCeleste > 0)
                      _buildDeudaCard(),
                    if (_deudaAzul > 0 || _deudaCeleste > 0)
                      const SizedBox(height: 16),
                    _buildActionCard(
                      icon: Icons.shopping_cart_outlined,
                      iconColor: const Color(0xFF003DA5),
                      title: 'Realizar pedido',
                      subtitle:
                          'Recibe agua fresca en la puerta de tu hogar de forma rápida y sencilla.',
                      actionText: 'Acceder ahora',
                      onTap: () {
                        setState(() => _selectedNavIndex = 0);
                        Navigator.pushNamed(
                          context,
                          '/cliente/pedido',
                          arguments: {'nombre': nombre, 'id': usuarioId},
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      icon: Icons.history,
                      iconColor: const Color(0xFF00ACC1),
                      title: 'Ver mis pedidos',
                      subtitle:
                          'Consulta el estado de tus entregas actuales y revisa tu historial de compras.',
                      actionText: 'Explorar lista',
                      onTap: () {
                        setState(() => _selectedNavIndex = 1);
                        Navigator.pushNamed(
                          context,
                          '/cliente/mis-pedidos',
                          arguments: {'nombre': nombre, 'id': usuarioId},
                        );
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
            Icon(Icons.water_drop, color: _primaryBlue, size: 26),
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
                  color: Color(0xFFE3F2FD),
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
              backgroundColor: _primaryBlue,
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

  Widget _buildDeudaCard() {
    final partes = <String>[];
    if (_deudaAzul > 0) partes.add('$_deudaAzul azul');
    if (_deudaCeleste > 0) partes.add('$_deudaCeleste celeste');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bidones pendientes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Debés ${partes.join(', ')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFBF360C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String nombre) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenido, $nombre 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '¿Qué deseas hacer hoy por tu hidratación?',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF002855),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  actionText,
                  style: const TextStyle(
                    color: Color(0xFF003DA5),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF003DA5),
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String nombre = args?['nombre'] ?? 'Cliente';
    final int? usuarioId = args?['id'] ?? args?['usuario_id'];

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
            nombre: nombre,
            usuarioId: usuarioId,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.history,
            label: 'Ver mis pedidos',
            index: 1,
            route: '/cliente/mis-pedidos',
            nombre: nombre,
            usuarioId: usuarioId,
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
    required String nombre,
    required int? usuarioId,
  }) {
    final bool isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        Navigator.pushNamed(
          context,
          route,
          arguments: {'nombre': nombre, 'id': usuarioId},
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFE3F2FD)
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

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_realtimeChannel);
    super.dispose();
  }
}