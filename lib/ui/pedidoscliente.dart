import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:apppeydar/services/order_service.dart';
import 'package:apppeydar/ui/detalle_pedido.dart';
import 'package:apppeydar/ui/resumenPedido.dart';

class MisPedidosPage extends StatefulWidget {
  const MisPedidosPage({super.key});

  @override
  State<MisPedidosPage> createState() => _MisPedidosPageState();
}

class _MisPedidosPageState extends State<MisPedidosPage> {
  late String clienteName;
  int? usuarioId;
  Map<String, dynamic>? _activeOrder;
  String _selectedFilter = 'TODOS';

  static const Color primaryBlue = Color(0xFF005BCB);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    clienteName = 'Cliente'; // Initialize with default value
  }

  Future<void> _loadActiveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('active_order');
    if (s != null) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        // Sólo consideramos como activo si el estado es EN_CURSO (admin debe marcarlo)
        if ((m['status'] ?? '').toString().toUpperCase() == 'EN_CURSO') {
          setState(() {
            _activeOrder = m;
          });
        }
      } catch (_) {}
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    clienteName = args?['nombre'] ?? 'Cliente';
    usuarioId = args?['id'] ?? args?['usuario_id'];
    if (usuarioId != null) _fetchPedidos();
    _loadActiveOrder();
  }

  List<Map<String, dynamic>> _pedidos = [];

  Future<void> _fetchPedidos() async {
    if (usuarioId == null) return;
    try {
      final list = await OrderService.obtenerPedidos(usuarioId!);
      setState(() {
        _pedidos = list;
        // if backend provides an active order (estado EN_CURSO), prefer it
        final active = _pedidos.firstWhere((p) => (p['estado'] ?? '').toString().toUpperCase() == 'EN_CURSO', orElse: () => {});
        if (active.isNotEmpty) {
          _activeOrder = {
            'pedido_id': active['id'],
            'status': active['estado'],
            'direccion': active['direccion_entrega'] ?? active['direccion'] ?? '',
            'date': active['fecha_pedido'],
            'title': 'Pedido #${active['id'] ?? ''}'
          };
        } else {
          // if no active, clear local active
          _activeOrder = null;
        }
      });
    } catch (e) {
      // ignore fetch errors for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPedidos = (_selectedFilter == 'TODOS')
        ? _pedidos
        : _pedidos.where((p) {
            final s = (p['estado'] ?? '').toString().toUpperCase();
            if (_selectedFilter == 'EN_CAMINO') return s == 'EN_CAMINO' || s == 'EN_CURSO';
            return s == _selectedFilter;
          }).toList();

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
            _activeOrder != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('PEDIDO EN CURSO'),
                      const SizedBox(height: 16),
                      _buildActiveOrderCard(),
                      const SizedBox(height: 40),
                    ],
                  )
                : const SizedBox.shrink(),
            _buildHistoryHeader(),
            const SizedBox(height: 16),
            _buildStatusFilters(),
            // Mostrar historial real desde backend
            ...filteredPedidos.map((p) {
              final detalles = (p['detalles'] as List? ) ?? [];
              // Preferir título provisto por backend (Pedido 1, Pedido 2, ...)
              final title = (p['title'] as String?) ?? (detalles.isNotEmpty ? '${detalles.length} items' : 'Pedido #${p['id'] ?? ''}');
              final id = (p['id'] ?? '').toString();
              final dateRaw = (p['fecha_pedido'] ?? '').toString();
              final date = dateRaw.isNotEmpty ? dateRaw.split('T').first : '';
              final status = (p['estado'] ?? 'PENDIENTE').toString();
              final statusUpper = status.toUpperCase();

              Color statusColor;
              Color statusBg;
              IconData icon;
              Color iconColor;
              Color iconBg;

              if (statusUpper == 'PENDIENTE') {
                statusColor = Colors.grey.shade700;
                statusBg = Colors.grey.shade100;
                icon = Icons.hourglass_empty;
                iconColor = Colors.grey;
                iconBg = Colors.grey.shade50;
              } else if (statusUpper == 'EN_CAMINO' || statusUpper == 'EN_CURSO') {
                statusColor = const Color(0xFF0369A1);
                statusBg = Colors.lightBlue.shade50;
                icon = Icons.local_shipping;
                iconColor = const Color(0xFF0369A1);
                iconBg = Colors.lightBlue.shade50;
              } else if (statusUpper == 'FINALIZADO') {
                statusColor = const Color(0xFF16A34A);
                statusBg = Colors.green.shade50;
                icon = Icons.check_circle;
                iconColor = const Color(0xFF16A34A);
                iconBg = Colors.green.shade50;
              } else if (statusUpper == 'CANCELADO') {
                statusColor = const Color(0xFFEF4444);
                statusBg = const Color(0xFFFEF2F2);
                icon = Icons.block;
                iconColor = const Color(0xFFB91C1C);
                iconBg = const Color(0xFFFEF2F2);
              } else {
                statusColor = Colors.grey.shade700;
                statusBg = Colors.grey.shade100;
                icon = Icons.local_shipping;
                iconColor = const Color(0xFF0891B2);
                iconBg = const Color(0xFFECFEFF);
              }

              final widgetItem = _buildHistoryItem(
                title: title,
                id: id,
                date: date,
                price: '',
                status: status,
                statusColor: statusColor,
                statusBg: statusBg,
                icon: icon,
                iconColor: iconColor,
                iconBg: iconBg,
              );
              // Navegación según estado: PENDIENTE -> Detalle (solo lectura), FINALIZADO -> Detalle (solo lectura), otros -> Detalle (solo lectura)
              return GestureDetector(
                onTap: () {
                  if (statusUpper == 'PENDIENTE') {
                    // Mostrar detalle de pedido en modo solo lectura (pendiente: sin monto final)
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DetallePedidoScreen(pedido: p, readOnly: true),
                    ));
                    return;
                  }

                  // Para finalizado y otros estados mostramos detalle en modo solo lectura
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DetallePedidoScreen(pedido: p, readOnly: true),
                  ));
                },
                child: widgetItem,
              );
            }).toList(),
            const SizedBox(height: 24),
            _buildLoadMoreButton(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mis Pedidos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 8),
        Text('Cliente: $clienteName', style: const TextStyle(fontSize: 16, color: textLight)),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), letterSpacing: 1.1));
  }

  Widget _buildActiveOrderCard() {
    if (_activeOrder == null) return const SizedBox.shrink();

    final title = _activeOrder?['title'] ?? 'Pedido en curso';
    final direccion = _activeOrder?['direccion'] ?? '';
    final date = _activeOrder?['date'] ?? '';

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
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Dirección: $direccion', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Fecha: $date', style: const TextStyle(color: Colors.white70, fontSize: 13)),
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

  Widget _buildStatusFilters() {
    final options = ['TODOS', 'PENDIENTE', 'EN_CAMINO', 'FINALIZADO'];
    String label(String v) {
      if (v == 'TODOS') return 'Todos';
      if (v == 'EN_CAMINO') return 'En camino';
      if (v == 'PENDIENTE') return 'Pendiente';
      return 'Finalizado';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        children: options.map((opt) {
          final selected = _selectedFilter == opt;
          return ChoiceChip(
            label: Text(label(opt)),
            selected: selected,
            onSelected: (s) => setState(() {
              _selectedFilter = opt;
            }),
            selectedColor: primaryBlue,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: selected ? Colors.white : primaryBlue, fontWeight: FontWeight.bold),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String id,
    required String date,
    required String price,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
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
                Text(date, style: TextStyle(color: textLight, fontSize: 13)),
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

  Widget _buildBottomNav(BuildContext context) {
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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/cliente/pedido',
                arguments: {'nombre': clienteName, 'id': usuarioId},
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shopping_basket_outlined, color: textLight),
                SizedBox(height: 4),
                Text('Realizar pedido', style: TextStyle(color: textLight, fontSize: 14)),
              ],
            ),
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
