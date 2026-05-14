import 'package:flutter/material.dart';
import 'package:apppeydar/services/order_service.dart';
import 'package:apppeydar/services/user_service.dart';
import 'package:apppeydar/services/reporte_pdf_service.dart';
import 'package:apppeydar/ui/detalle_pedido.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  static const Color primaryBlue = Color(0xFF003DA5);
  static const Color textNavy = Color(0xFF002855);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color greenAccent = Color(0xFF16A34A);
  static const Color tealAccent = Color(0xFF0D9488);

  List<Map<String, dynamic>> _pedidos = [];
  List<Map<String, dynamic>> _clientes = [];
  bool _loading = true;

  // Date filter
  String _selectedPeriodo = 'Este mes';
  DateTime _fechaDesde = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _fechaHasta = DateTime.now();

  // Client filter
  int? _clienteFiltroId;

  @override
  void initState() {
    super.initState();
    _loadReportes();
    _cargarClientes();
  }

  // ─── Cargar clientes ─────────────────────────────────────────────────────
  Future<void> _cargarClientes() async {
    try {
      final list = await UserService.obtenerClientes();
      if (mounted) setState(() => _clientes = list);
    } catch (_) {}
  }

  // ─── Cargar reportes ─────────────────────────────────────────────────────
  Future<void> _loadReportes() async {
    setState(() => _loading = true);
    try {
      final list = await OrderService.obtenerReportes(
        desde: _fechaDesde,
        hasta: _fechaHasta,
        usuarioId: _clienteFiltroId,
      );
      if (mounted) {
        setState(() {
          _pedidos = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pedidos = [];
          _loading = false;
        });
      }
    }
  }

  // ─── Calcular periodo ────────────────────────────────────────────────────
  void _calcularPeriodo(String periodo) {
    final now = DateTime.now();
    DateTime desde;
    DateTime hasta = now;

    switch (periodo) {
      case 'Hoy':
        desde = DateTime(now.year, now.month, now.day);
        break;
      case 'Esta semana':
        final daysSinceMonday = now.weekday - 1;
        desde = DateTime(now.year, now.month, now.day - daysSinceMonday);
        break;
      case 'Este mes':
        desde = DateTime(now.year, now.month, 1);
        break;
      case 'Personalizado':
        _mostrarDateRangePicker();
        return; // _loadReportes will be called after picker closes
      default:
        desde = DateTime(now.year, now.month, 1);
    }

    setState(() {
      _selectedPeriodo = periodo;
      _fechaDesde = desde;
      _fechaHasta = hasta;
    });
    _loadReportes();
  }

  // ─── Date range picker ───────────────────────────────────────────────────
  Future<void> _mostrarDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _fechaDesde, end: _fechaHasta),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: primaryBlue),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedPeriodo = 'Personalizado';
        _fechaDesde = picked.start;
        _fechaHasta = picked.end;
      });
      _loadReportes();
    }
  }

  // ─── Getters ─────────────────────────────────────────────────────────────
  int get _totalPedidos => _pedidos.length;

  double get _totalIngresos {
    double sum = 0;
    for (final p in _pedidos) {
      final monto = p['monto_final'];
      if (monto != null) {
        final value = monto is double ? monto : double.tryParse(monto.toString());
        if (value != null) sum += value;
      }
    }
    return sum;
  }

  int get _totalBidones {
    int sum = 0;
    for (final p in _pedidos) {
      final detalles = p['detalles_pedido'] as List? ?? [];
      for (final d in detalles) {
        final cantidad = d['cantidad'];
        if (cantidad != null) {
          final value =
              cantidad is int ? cantidad : int.tryParse(cantidad.toString());
          if (value != null) sum += value;
        }
      }
    }
    return sum;
  }

  Map<String, int> _desgloseBidones() {
    int recargaAzul = 0;
    int recargaCeleste = 0;
    int compraAzul = 0;
    int compraCeleste = 0;

    for (final p in _pedidos) {
      final detalles = p['detalles_pedido'] as List? ?? [];
      for (final d in detalles) {
        final producto = (d['producto'] ?? '').toString();
        final cantidad = d['cantidad'];
        final value =
            cantidad is int ? cantidad : int.tryParse(cantidad?.toString() ?? '0') ?? 0;

        if (producto == 'Recarga Azul') {
          recargaAzul += value;
        } else if (producto == 'Recarga Celeste') {
          recargaCeleste += value;
        } else if (producto == 'Compra Azul') {
          compraAzul += value;
        } else if (producto == 'Compra Celeste') {
          compraCeleste += value;
        }
      }
    }

    return {
      'Recarga Azul': recargaAzul,
      'Recarga Celeste': recargaCeleste,
      'Compra Azul': compraAzul,
      'Compra Celeste': compraCeleste,
    };
  }

  // ─── Formatting helpers ──────────────────────────────────────────────────
  String _formatFecha(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatCurrency(double amount) {
    return 'S/. ${amount.toStringAsFixed(2)}';
  }

  String _parseDateFromPedido(Map<String, dynamic> pedido) {
    try {
      final raw = pedido['created_at'];
      if (raw == null) return '-';
      final dt = DateTime.parse(raw.toString()).toLocal();
      return _formatFecha(dt);
    } catch (_) {
      return '-';
    }
  }

  String _getClienteName(Map<String, dynamic> pedido) {
    final usuario = pedido['usuario'];
    if (usuario is Map) {
      final nombre = (usuario['nombre'] ?? '').toString();
      final apellido = (usuario['apellido'] ?? '').toString();
      final parts = [nombre, apellido].where((s) => s.isNotEmpty).toList();
      return parts.isNotEmpty ? parts.join(' ') : '-';
    }
    return '-';
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Reportes',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: primaryBlue),
            tooltip: 'Exportar PDF',
            onPressed: _exportarPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Panel de Reportes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Analiza métricas de ventas, pedidos y consumo de bidones.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),

            // ── Date Filter Chips ──────────────────────────────────────────
            _buildDateFilterRow(),
            const SizedBox(height: 16),

            // ── Client Filter Dropdown ─────────────────────────────────────
            _buildClientFilter(),
            const SizedBox(height: 25),

            // ── Summary Cards ──────────────────────────────────────────────
            _loading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    children: [
                      _buildSummaryRow(),
                      const SizedBox(height: 20),

                      // ── Detail Cards ──────────────────────────────────
                      _buildDetailCards(),
                      const SizedBox(height: 25),

                      // ── Bottle Breakdown ──────────────────────────────
                      _buildBottleBreakdown(),
                      const SizedBox(height: 25),

                      // ── Recent Orders Table ───────────────────────────
                      _buildRecentOrders(),
                    ],
                  ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Date Filter Row ─────────────────────────────────────────────────────
  Widget _buildDateFilterRow() {
    final periodos = ['Hoy', 'Esta semana', 'Este mes', 'Personalizado'];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: periodos.map((periodo) {
        final selected = _selectedPeriodo == periodo;
        return ChoiceChip(
          label: Text(
            periodo,
            style: TextStyle(
              color: selected ? Colors.white : textNavy,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          selected: selected,
          selectedColor: primaryBlue,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected ? primaryBlue : Colors.grey.shade300,
          ),
          onSelected: (_) => _calcularPeriodo(periodo),
        );
      }).toList(),
    );
  }

  // ─── Client Filter ───────────────────────────────────────────────────────
  Widget _buildClientFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _clienteFiltroId,
          isExpanded: true,
          hint: const Text(
            'Todos los clientes',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'Todos los clientes',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            ..._clientes.map((c) {
              final nombre = '${c['nombre'] ?? ''} ${c['apellido'] ?? ''}'
                  .trim();
              final id = c['id'] is int ? c['id'] as int : int.tryParse(c['id']?.toString() ?? '');
              return DropdownMenuItem<int?>(
                value: id,
                child: Text(
                  nombre.isNotEmpty ? nombre : 'Cliente #$id',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _clienteFiltroId = value);
            _loadReportes();
          },
        ),
      ),
    );
  }

  // ─── Summary Row ─────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Pedidos', _totalPedidos.toString(), Icons.receipt_long_outlined, primaryBlue)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Ingresos', _formatCurrency(_totalIngresos), Icons.attach_money, greenAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildSummaryCard('Bidones', _totalBidones.toString(), Icons.water_drop_outlined, tealAccent)),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textNavy,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Detail Stat Cards ───────────────────────────────────────────────────
  Widget _buildDetailCards() {
    return Column(
      children: [
        _buildStatCard(
          title: 'Total Pedidos',
          value: _totalPedidos.toString(),
          subtitle: 'Periodo: ${_formatFecha(_fechaDesde)} - ${_formatFecha(_fechaHasta)}',
          color: primaryBlue,
          icon: Icons.receipt_long,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'Ingresos Totales',
          value: _formatCurrency(_totalIngresos),
          subtitle: 'Solo pedidos finalizados',
          color: greenAccent,
          icon: Icons.trending_up,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'Bidones Vendidos',
          value: _totalBidones.toString(),
          subtitle: 'Entre recargas y compras',
          color: tealAccent,
          icon: Icons.water_drop,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottle Breakdown ────────────────────────────────────────────────────
  Widget _buildBottleBreakdown() {
    final desglose = _desgloseBidones();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: tealAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Desglose de Bidones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBottleRow('Recarga Azul', desglose['Recarga Azul'] ?? 0, Colors.blue.shade600),
          const Divider(height: 20),
          _buildBottleRow('Recarga Celeste', desglose['Recarga Celeste'] ?? 0, Colors.lightBlue.shade300),
          const Divider(height: 20),
          _buildBottleRow('Compra Azul', desglose['Compra Azul'] ?? 0, Colors.blue.shade800),
          const Divider(height: 20),
          _buildBottleRow('Compra Celeste', desglose['Compra Celeste'] ?? 0, Colors.lightBlue.shade500),
        ],
      ),
    );
  }

  Widget _buildBottleRow(String label, int count, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textNavy,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textNavy,
          ),
        ),
      ],
    );
  }

  // ─── Recent Orders Table ─────────────────────────────────────────────────
  Widget _buildRecentOrders() {
    if (_pedidos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No hay pedidos en este periodo.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedidos Recientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textNavy,
            ),
          ),
          const SizedBox(height: 16),
          // Header row
          _buildOrderHeader(),
          const Divider(height: 16),
          // Order rows
          ..._pedidos.map((p) => _buildOrderRow(p)),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      children: [
        const SizedBox(width: 50, child: Text('ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
        const Expanded(flex: 2, child: Text('Cliente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
        const SizedBox(width: 80, child: Text('Fecha', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
        const SizedBox(width: 70, child: Text('Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.right)),
        const SizedBox(width: 80, child: Text('Estado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
      ],
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> pedido) {
    final id = (pedido['id'] ?? '-').toString();
    final cliente = _getClienteName(pedido);
    final fecha = _parseDateFromPedido(pedido);

    double monto = 0;
    final montoRaw = pedido['monto_final'];
    if (montoRaw != null) {
      monto = montoRaw is double
          ? montoRaw
          : double.tryParse(montoRaw.toString()) ?? 0;
    }

    final estado = (pedido['estado'] ?? 'PENDIENTE').toString();
    final estadoUpper = estado.toUpperCase();

    Color estadoColor = Colors.grey;
    if (estadoUpper == 'EN_CAMINO' || estadoUpper == 'EN_CURSO') {
      estadoColor = Colors.orange;
    } else if (estadoUpper == 'FINALIZADO' || estadoUpper == 'ENTREGADO') {
      estadoColor = greenAccent;
    } else if (estadoUpper == 'CANCELADO') {
      estadoColor = Colors.red.shade400;
    }

    String estadoLabel = estado.toLowerCase();
    if (estadoUpper == 'EN_CAMINO' || estadoUpper == 'EN_CURSO') estadoLabel = 'en camino';
    if (estadoUpper == 'ENTREGADO' || estadoUpper == 'FINALIZADO') estadoLabel = 'finalizado';
    if (estadoUpper == 'CANCELADO') estadoLabel = 'cancelado';

    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetallePedidoScreen(pedido: pedido),
          ),
        );
        if (result != null) _loadReportes();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                '#$id',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textNavy,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                cliente,
                style: TextStyle(fontSize: 13, color: textNavy),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                fecha,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                monto > 0 ? _formatCurrency(monto) : '-',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: monto > 0 ? greenAccent : Colors.grey,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  estadoLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: estadoColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Navigation ───────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'PEDIDOS',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt),
          label: 'CLIENTES',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'REPORTES',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/admin/pedidos');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/admin/clientes');
            break;
        }
      },
    );
  }

  // ─── Exportar PDF ────────────────────────────────────────────────────────
  Future<void> _exportarPdf() async {
    // Prepare period text
    final periodos = {
      'Hoy': 'Hoy',
      'Esta semana': 'Esta semana',
      'Este mes': 'Este mes',
      'Personalizado': '${_fechaDesde.day}/${_fechaDesde.month}/${_fechaDesde.year} - ${_fechaHasta.day}/${_fechaHasta.month}/${_fechaHasta.year}',
    };
    final periodoTexto = periodos[_selectedPeriodo] ?? _selectedPeriodo;

    // Client text
    String clienteTexto = 'Todos los clientes';
    if (_clienteFiltroId != null) {
      final c = _clientes.firstWhere(
        (c) => (c['id'] == _clienteFiltroId || c['usuario_id'] == _clienteFiltroId),
        orElse: () => {},
      );
      if (c.isNotEmpty) {
        clienteTexto = '${c['nombre'] ?? ''} ${c['apellido'] ?? ''}'.trim();
      }
    }

    // Calculate desglose and totals
    final desglose = _desgloseBidones();

    await ReportePdfService.exportarPdf(
      periodoTexto: periodoTexto,
      clienteTexto: clienteTexto,
      totalPedidos: _totalPedidos,
      totalIngresos: _totalIngresos,
      totalBidones: _totalBidones,
      desglose: desglose,
      pedidos: _pedidos,
    );
  }
}
