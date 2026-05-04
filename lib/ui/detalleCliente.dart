import 'package:flutter/material.dart';
import 'package:apppeydar/services/order_service.dart';
import 'package:apppeydar/ui/detalle_pedido.dart';

class PerfilClienteInfoScreen extends StatefulWidget {
  const PerfilClienteInfoScreen({super.key, this.cliente});

  final Map<String, dynamic>? cliente;

  @override
  State<PerfilClienteInfoScreen> createState() => _PerfilClienteInfoScreenState();
}

class _PerfilClienteInfoScreenState extends State<PerfilClienteInfoScreen> {
  List<Map<String, dynamic>> _pedidos = [];
  bool _loading = true;

  Map<String, dynamic>? get cliente => widget.cliente;

  // Colores corporativos PEYDAR
  final Color primaryBlue = const Color(0xFF003DA5);
  final Color backgroundGrey = const Color(0xFFF8FAFC);
  final Color textNavy = const Color(0xFF002855);
  final Color cyanAccent = const Color(0xFF4DD0E1);

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  String _formatDateShort(String raw) {
    if (raw.isEmpty) return raw;
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length >= 10 ? raw.substring(0, 10) : raw;
    }
  }

  Future<void> _loadPedidos() async {
    setState(() => _loading = true);
    try {
      final uid = cliente?['usuario_id'] ?? cliente?['id'] ?? cliente?['usuario'];
      if (uid != null) {
        final int? usuarioId = int.tryParse(uid.toString());
        if (usuarioId != null) {
          final list = await OrderService.obtenerPedidos(usuarioId);
          setState(() => _pedidos = list);
        } else if (cliente?['pedidos'] is List) {
          setState(() => _pedidos = List<Map<String, dynamic>>.from(cliente!['pedidos']));
        } else {
          setState(() => _pedidos = []);
        }
      } else if (cliente?['pedidos'] is List) {
        setState(() => _pedidos = List<Map<String, dynamic>>.from(cliente!['pedidos']));
      } else {
        setState(() => _pedidos = []);
      }
    } catch (_) {
      setState(() => _pedidos = cliente?['pedidos'] is List ? List<Map<String, dynamic>>.from(cliente!['pedidos']) : []);
    } finally {
      setState(() => _loading = false);
    }
  }

  String _computeLastInteraction() {
    if (_pedidos.isEmpty) return cliente?['last_interaction']?.toString() ?? 'sin interacción';
    try {
      DateTime? latest;
      for (final p in _pedidos) {
        final f = (p['fecha'] ?? p['fecha_pedido'] ?? p['created_at'] ?? '').toString();
        if (f.isEmpty) continue;
        try {
          final dt = DateTime.parse(f).toLocal();
          if (latest == null || dt.isAfter(latest)) latest = dt;
        } catch (_) {}
      }
      if (latest == null) return cliente?['last_interaction']?.toString() ?? 'sin interacción';
      final diff = DateTime.now().difference(latest).inDays;
      if (diff == 0) return 'hoy';
      if (diff == 1) return 'hace 1 día';
      return 'hace $diff días';
    } catch (_) {
      return cliente?['last_interaction']?.toString() ?? 'sin interacción';
    }
  }

  int _totalPedidos() => _pedidos.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Gestión de Clientes', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(builder: (_) {
                        final nombre = (cliente?['nombre'] ?? '')?.toString() ?? '';
                        final apellido = (cliente?['apellido'] ?? '')?.toString() ?? '';
                        final displayName = (nombre.isNotEmpty || apellido.isNotEmpty) ? '$nombre $apellido' : 'Cliente ${cliente?['usuario_id'] ?? ''}';
                        return Text(displayName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textNavy));
                      }),
                      _buildBadge((cliente?['estado'] ?? 'ACTIVO').toString().toUpperCase(), Colors.green.shade50, Colors.green.shade700),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.badge_outlined, 'DNI', (cliente?['dni'] ?? cliente?['documento'] ?? '-').toString()),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.phone_android, 'TELÉFONO', (cliente?['telefono'] ?? cliente?['celular'] ?? '-').toString()),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.email_outlined, 'TIPO', (cliente?['tipo'] ?? 'CLIENTE').toString()),
                ],
              ),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [primaryBlue, const Color(0xFF002855)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text('RESUMEN DE ACTIVIDAD', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  Text('${_totalPedidos()} Pedidos Totales', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Última interacción: ${_computeLastInteraction()}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Historial Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textNavy)),
                Icon(Icons.filter_list, color: textNavy, size: 20),
              ],
            ),
            const SizedBox(height: 15),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_pedidos.isEmpty)
              const Text('No hay pedidos registrados para este cliente.', style: TextStyle(color: Colors.grey))
            else ..._pedidos.map((o) {
              final rawDate = (o['fecha'] ?? o['fecha_pedido'] ?? o['created_at'] ?? '').toString();
              final date = _formatDateShort(rawDate);
              final items = <String>[];
              final productNames = <String>[];
              try {
                if (o['detalles'] is List) {
                  for (final d in List<Map<String, dynamic>>.from(o['detalles'])) {
                    final prod = (d['producto'] ?? d['name'] ?? d['producto_nombre'] ?? '').toString();
                    final qty = (d['cantidad'] ?? d['cant'] ?? d['qty'] ?? '').toString();
                    if (prod.isNotEmpty) productNames.add(prod);
                    items.add(qty.isNotEmpty ? '$prod x$qty' : prod);
                  }
                } else if (o['items'] is List) {
                  final rawItems = List.from(o['items']);
                  for (final it in rawItems) {
                    final s = it?.toString() ?? '';
                    if (s.isNotEmpty) productNames.add(s);
                    items.add(s);
                  }
                } else if (o['productos'] != null) {
                  final prodStr = o['productos'].toString();
                  productNames.add(prodStr);
                  items.add(prodStr);
                }
              } catch (_) {}
              final title = productNames.isNotEmpty ? productNames.take(2).join(', ') : 'Pedido';
              final status = (o['estado'] ?? o['status'] ?? 'PENDIENTE').toString();
              final statusColor = (status.toUpperCase() == 'CANCELADO') ? Colors.red : Colors.green;
              return _buildOrderTile(title, date, items, status, statusColor, pedido: o);
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(value, style: TextStyle(color: textNavy, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildOrderTile(String title, String date, List<String> items, String status, Color statusColor, {Map<String, dynamic>? pedido}) {
    return InkWell(
      onTap: () async {
        if (pedido != null) {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetallePedidoScreen(pedido: pedido),
            ),
          );
          if (result == true || result is Map<String, dynamic>) {
            // if detail screen returned updated data, optionally reload pedidos
            await _loadPedidos();
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status.toLowerCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: 'PEDIDOS'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'CLIENTES'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'REPORTES'),
      ],
    );
  }
}