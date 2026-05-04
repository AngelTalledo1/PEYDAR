import 'package:flutter/material.dart';
import 'package:apppeydar/services/order_service.dart';
import 'package:apppeydar/ui/detalle_pedido.dart';

class GestionPedidosScreen extends StatefulWidget {
  const GestionPedidosScreen({super.key});

  @override
  State<GestionPedidosScreen> createState() => _GestionPedidosScreenState();
}

class _GestionPedidosScreenState extends State<GestionPedidosScreen> {
  final Color primaryBlue = const Color(0xFF003DA5);
  final Color backgroundGrey = const Color(0xFFF8FAFC);
  final Color textNavy = const Color(0xFF002855);

  List<Map<String, dynamic>> _pedidos = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    _fetchAdminPedidos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAdminPedidos() async {
    try {
      final list = await OrderService.obtenerPedidosAdmin();
      setState(() {
        _pedidos = list;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
       
        title: Text(
          'Pedidos',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Pedidos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Visualiza y gestiona las solicitudes de tus clientes en tiempo real.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),

            // FILTRO POR ESTADO
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterEstado,
                    items: ['TODOS', 'PENDIENTE', 'EN_CAMINO', 'FINALIZADO', 'CANCELADO']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e == 'TODOS'
                                    ? 'Todos'
                                    : e == 'EN_CAMINO'
                                        ? 'En camino'
                                        : e == 'FINALIZADO'
                                            ? 'Finalizado'
                                            : e == 'CANCELADO'
                                                ? 'Cancelado'
                                                : e.toLowerCase(),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _filterEstado = v ?? 'TODOS';
                    }),
                    decoration: InputDecoration(
                      labelText: 'Filtrar por estado',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_filterEstado != 'TODOS')
                  TextButton(
                    onPressed: () => setState(() => _filterEstado = 'TODOS'),
                    child: const Text('Limpiar'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // BUSCADOR
            TextField(
              controller: _searchController,
              onChanged: (v) =>
                  setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, apellido o producto...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // LISTA DE PEDIDOS
            if (_loading) ...[
              const SizedBox(height: 40),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
            ] else if (_pedidos.isEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'No hay pedidos por el momento.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ] else ..._buildPedidosList(),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  List<Widget> _buildPedidosList() {
    final visible = _pedidos.where((p) {
      final nombre = ((p['nombre'] ?? '') as String).toLowerCase();
      final apellido = ((p['apellido'] ?? '') as String).toLowerCase();
      String products = '';
      try {
        if (p['productos'] != null &&
            p['productos'].toString().trim().isNotEmpty) {
          products = p['productos'].toString().toLowerCase();
        } else if (p['detalles'] is List) {
          final detallesList =
              List<Map<String, dynamic>>.from(p['detalles']);
          products = detallesList
              .map((d) =>
                  (d['producto'] ?? d['name'] ?? d['producto_nombre'] ?? '')
                      .toString())
              .where((s) => s.isNotEmpty)
              .join(' ')
              .toLowerCase();
        }
      } catch (e) {
        products = '';
      }
      final idStr =
          ((p['id'] ?? p['pedido_id'] ?? '')).toString().toLowerCase();
      final combined = '$nombre $apellido';
      final matchesSearch = _searchQuery.isEmpty
          ? true
          : (combined.contains(_searchQuery) ||
              products.contains(_searchQuery) ||
              idStr.contains(_searchQuery));
      final status =
          ((p['estado'] ?? 'PENDIENTE').toString()).toUpperCase();
      final matchesFilter =
          _filterEstado == 'TODOS' ? true : status == _filterEstado;
      return matchesSearch && matchesFilter;
    }).toList();

    return visible.map((p) {
      final nombre = (p['nombre'] ?? '').toString();
      final apellido = (p['apellido'] ?? '').toString();
      final firstName =
          nombre.isNotEmpty ? nombre.split(' ').first : '';
      final firstSurname =
          apellido.isNotEmpty ? apellido.split(' ').first : '';
      final displayName = [firstName, firstSurname]
          .where((s) => s.isNotEmpty)
          .join(' ');

      String products = '';
      try {
        if (p['productos'] != null &&
            p['productos'].toString().trim().isNotEmpty) {
          products = p['productos'].toString();
        } else if (p['detalles'] is List) {
          final detallesList =
              List<Map<String, dynamic>>.from(p['detalles']);
          products = detallesList
              .map((d) {
                final prod =
                    (d['producto'] ?? d['name'] ?? d['producto_nombre'] ?? '')
                        .toString();
                final cantidad =
                    d['cantidad'] ?? d['cant'] ?? d['qty'] ?? '';
                return cantidad != '' ? '$prod x$cantidad' : prod;
              })
              .where((s) => s.isNotEmpty)
              .join(', ');
        }
      } catch (e) {
        products = (p['productos'] ?? '').toString();
      }

      final fecha = (p['fecha_pedido'] ?? '').toString();
      String timeLabel = fecha;
      try {
        final dt = DateTime.parse(fecha);
        final local = dt.toLocal();
        timeLabel =
            '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        // dejar como está si falla el parse
      }

      final status = (p['estado'] ?? 'PENDIENTE').toString();
      final statusUpper = status.toUpperCase();

      Color statusColor = Colors.grey.shade400;
      if (statusUpper == 'EN_CAMINO' || statusUpper == 'EN_CURSO') {
        statusColor = Colors.green.shade400;
      } else if (statusUpper == 'ENTREGADO' ||
          statusUpper == 'FINALIZADO') {
        statusColor = Colors.green.shade400;
      } else if (statusUpper == 'CANCELADO') {
        statusColor = Colors.red.shade300;
      }

      String statusLabel() {
        if (statusUpper == 'EN_CAMINO' || statusUpper == 'EN_CURSO') {
          return 'en camino';
        }
        if (statusUpper == 'ENTREGADO' || statusUpper == 'FINALIZADO') {
          return 'finalizado';
        }
        if (statusUpper == 'CANCELADO') return 'cancelado';
        return status.toLowerCase();
      }

      return _buildOrderCard(
        name: displayName,
        products: products,
        time: timeLabel,
        status: statusLabel(),
        statusColor: statusColor,
        actionLabel: 'Ver',
        pedido: p,
      );
    }).toList();
  }

  Widget _buildOrderCard({
    required String name,
    required String products,
    required String time,
    required String status,
    required Color statusColor,
    required String actionLabel,
    Map<String, dynamic>? pedido,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline, color: primaryBlue),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textNavy,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'PRODUCTOS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            products,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textNavy,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              InkWell(
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          DetallePedidoScreen(pedido: pedido),
                    ),
                  );
                  if (result is Map<String, dynamic>) {
                    final updatedId = result['id']?.toString();
                    if (updatedId != null) {
                      final idx = _pedidos.indexWhere((e) =>
                          (e['id'] ?? e['pedido_id'])?.toString() ==
                          updatedId);
                      if (idx != -1) {
                        setState(() => _pedidos[idx] = result);
                        return;
                      }
                    }
                    await _fetchAdminPedidos();
                  } else if (result == true) {
                    await _fetchAdminPedidos();
                  }
                },
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping),
          label: 'ORDERS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          label: 'CLIENTS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          label: 'REPORTS',
        ),
      ],
    );
  }
}