import 'package:flutter/material.dart';
import 'package:apppeydar/services/order_service.dart';

class DetallePedidoScreen extends StatefulWidget {
  final Map<String, dynamic>? pedido;
  final bool readOnly;
  const DetallePedidoScreen({Key? key, this.pedido, this.readOnly = false}) : super(key: key);

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  String _estado = 'PENDIENTE';
  String? _targetEstado;
  final TextEditingController _montoController = TextEditingController();
  Map<String, dynamic>? _pedidoData;
  bool _loading = false;
  bool _updated = false;
  DateTime? _montoSetAt;

  @override
  void initState() {
    super.initState();
    final p = widget.pedido ?? {};
    debugPrint('DetallePedido.initState widget.pedido: $p');
    _estado = (p['estado'] ?? 'PENDIENTE').toString();
    final m0 = _montoFromMap(p);
    if (m0 != null) _montoController.text = m0.toString();
    _montoSetAt = _parseMontoSetAtFromMap(p);

    final id = p['id'] ?? p['pedido_id'] ?? p['pedidoId'] ?? p['pedido'];
    var parsed = _parsePedidoId(id);

    if (parsed == null) {
      try {
        final s = p.isNotEmpty ? p.toString() : '';
        parsed = _parsePedidoId(s);
        debugPrint('DetallePedido.initState fallback parsed id from toString: $parsed');
      } catch (_) {
        parsed = null;
      }
    }

    if (parsed != null && parsed > 0) {
      _fetchPedido(parsed);
    } else {
      _pedidoData = p.isNotEmpty ? Map<String, dynamic>.from(p) : null;
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _fetchPedido(int id) async {
    if (id <= 0) return;
    setState(() { _loading = true; });
    try {
      final p = await OrderService.obtenerPedido(id);
      debugPrint('DetallePedido._fetchPedido $id -> response keys: ${p.keys.toList()}');
      setState(() {
        _pedidoData = p;
        _estado = (p['estado'] ?? _estado).toString();
        final m1 = _montoFromMap(p);
        if (m1 != null) _montoController.text = m1.toString();
        _montoSetAt = _parseMontoSetAtFromMap(p);
      });
    } catch (e) {
      debugPrint('DetallePedido._fetchPedido error: ${e.toString()}');
    } finally {
      setState(() { _loading = false; });
    }
  }

  int? _parsePedidoId(dynamic idObj) {
    if (idObj == null) return null;
    final s = idObj.toString();
    final n = int.tryParse(s);
    if (n != null && n > 0) return n;
    final reg = RegExp(r"(\d+)");
    final m = reg.firstMatch(s);
    if (m != null) {
      return int.tryParse(m.group(1)!);
    }
    return null;
  }

  dynamic _montoFromMap(Map? m) {
    if (m == null) return null;
    return m['monto_final'] ??
        m['montoFinal'] ??
        m['monto'] ??
        m['monto_total'] ??
        m['montoFinalizado'] ??
        m['monto_finalizado'] ??
        m['total'] ??
        m['total_amount'] ??
        m['amount'] ??
        m['total_monto'];
  }

  Future<void> _confirmChangeEstado(String newEstado) async {
    if (widget.readOnly) return;
    if (newEstado == _estado) return;
    double? monto;

    if (newEstado == 'FINALIZADO') {
      final res = await showDialog<double?>(
        context: context,
        builder: (ctx) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: const Text('Ingresar Monto Final'),
            content: TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Ingrese monto'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
                  Navigator.of(ctx).pop(v);
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
      if (res == null) return;
      monto = res;
    } else {
      final ok = await showDialog<bool?>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirmar cambio de estado'),
          content: Text(
            '¿Deseas cambiar el estado a ${newEstado == 'EN_CAMINO' ? 'En camino' : newEstado}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Sí'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final pid = (_pedidoData != null && _pedidoData!['id'] != null)
          ? int.tryParse(_pedidoData!['id'].toString())
          : (widget.pedido != null
              ? int.tryParse(
                  (widget.pedido!['id'] ?? widget.pedido!['pedido_id']).toString())
              : null);

      if (pid == null) throw Exception('ID de pedido inválido');

      final Map<String, dynamic> updated = await OrderService.actualizarEstadoPedido(
        pedidoId: pid,
        estado: newEstado,
        montoFinal: monto,
      );

      Map<String, dynamic>? fresh;
      try {
        fresh = await OrderService.obtenerPedido(pid);
        debugPrint('DetallePedido._confirmChangeEstado fresh keys: ${fresh.keys.toList()}');
        debugPrint('DetallePedido._confirmChangeEstado fresh values: $fresh');
      } catch (_) {
        fresh = null;
      }

      if (mounted) Navigator.of(context).pop(); // quitar loading

      setState(() {
        if (fresh != null) {
          _pedidoData = fresh;
          _estado = (fresh['estado'] ?? newEstado).toString();
          final montoFromServer = _montoFromMap(fresh);

          if (montoFromServer != null) {
            // El servidor devolvió el monto correctamente
            _montoController.text = montoFromServer.toString();
            _pedidoData!['monto_final'] = montoFromServer;
            _montoSetAt = _parseMontoSetAtFromMap(fresh);
          } else if (monto != null) {
            // El servidor no devolvió el monto: usamos el valor ingresado por el usuario
            _montoController.text = monto.toString();
            _pedidoData!['monto_final'] = monto;
          }
        } else {
          // No se pudo obtener el pedido fresco del servidor
          final resp = Map<String, dynamic>.from(updated);
          _estado = resp['estado']?.toString() ?? newEstado;
          final montoFromResp = _montoFromMap(resp);

          if (montoFromResp != null) {
            _montoController.text = montoFromResp.toString();
            if (_pedidoData == null) _pedidoData = {};
            _pedidoData!['monto_final'] = montoFromResp;
          } else if (monto != null) {
            // Fallback definitivo: usamos el monto ingresado por el usuario
            _montoController.text = monto.toString();
            if (_pedidoData == null) _pedidoData = {};
            _pedidoData!['monto_final'] = monto;
          }

          if (_pedidoData == null) _pedidoData = {};
          _pedidoData = {...?_pedidoData, ...resp};
          _montoSetAt = _parseMontoSetAtFromMap(resp);

          // Garantizar que monto_final no se sobreescriba con null al hacer el spread
          if (monto != null && _montoFromMap(_pedidoData) == null) {
            _pedidoData!['monto_final'] = monto;
            _montoController.text = monto.toString();
          }
        }

        _updated = true;
        _targetEstado = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido actualizado')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error actualizando pedido: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _editMonto() async {
    if (widget.readOnly) return;
    if (!_canEditMonto()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No es posible editar el monto: ventana de edición vencida')));
      return;
    }

    final current = _montoController.text.isNotEmpty
        ? _montoController.text
        : (_montoFromMap(_pedidoData)?.toString() ?? _montoFromMap(widget.pedido)?.toString() ?? '');

    final res = await showDialog<double?>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: current);
        return AlertDialog(
          title: const Text('Editar Monto Final'),
          content: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(hintText: 'Ingrese nuevo monto'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
                Navigator.of(ctx).pop(v);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (res == null) return;

    try {
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      final pid = (_pedidoData != null && _pedidoData!['id'] != null)
          ? int.tryParse(_pedidoData!['id'].toString())
          : (widget.pedido != null
              ? int.tryParse((widget.pedido!['id'] ?? widget.pedido!['pedido_id']).toString())
              : null);

      if (pid == null) throw Exception('ID de pedido inválido');

      final Map<String, dynamic> updated = await OrderService.actualizarEstadoPedido(
        pedidoId: pid,
        estado: _estado,
        montoFinal: res,
      );

      Map<String, dynamic>? fresh;
      try {
        fresh = await OrderService.obtenerPedido(pid);
      } catch (_) {
        fresh = null;
      }

      if (mounted) Navigator.of(context).pop(); // quitar loading

      setState(() {
        if (fresh != null) {
          _pedidoData = fresh;
          final montoFromServer = _montoFromMap(fresh);
          if (montoFromServer != null) {
            _montoController.text = montoFromServer.toString();
            _pedidoData!['monto_final'] = montoFromServer;
            _montoSetAt = _parseMontoSetAtFromMap(fresh);
          }
        } else {
          final resp = Map<String, dynamic>.from(updated);
          final montoFromResp = _montoFromMap(resp);
          if (montoFromResp != null) {
            _montoController.text = montoFromResp.toString();
            if (_pedidoData == null) _pedidoData = {};
            _pedidoData!['monto_final'] = montoFromResp;
          } else {
            _montoController.text = res.toString();
            if (_pedidoData == null) _pedidoData = {};
            _pedidoData!['monto_final'] = res;
          }
          _pedidoData = {...?_pedidoData, ...resp};
          _montoSetAt = _parseMontoSetAtFromMap(resp);
        }
        _updated = true;
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monto final actualizado')));
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error actualizando monto: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _pedidoData ?? (widget.pedido ?? {});

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF003DA5)),
            onPressed: () => Navigator.of(context).pop(_pedidoData ?? _updated),
          ),
          title: const Text(
            'Detalle de Pedido',
            style: TextStyle(color: Color(0xFF003DA5), fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final id = p['id']?.toString() ?? '#WF-9812';
    final nombre = (p['nombre'] ?? 'Ricardo Hernán Mendoza').toString();
    final telefono = (p['telefono_contacto'] ?? '+54 9 11 4455-6677').toString();
    final direccion = (p['direccion_entrega'] ??
            'Calle de las Aguas 1450, Piso 4, Dpto B. San Isidro, Buenos Aires.')
        .toString();
    final detalles = (p['detalles'] is List)
        ? List<Map<String, dynamic>>.from(p['detalles'])
        : [
            {'producto': 'Bidón Azul (20L)', 'desc': 'Recarga de agua mineralizada', 'cantidad': 2},
            {'producto': 'Bidón Celeste (12L)', 'desc': 'Bidón nuevo con dispenser manual', 'cantidad': 2},
          ];
    final fecha = p['fecha_pedido_local'] ?? p['fecha_pedido'] ?? '24/10/2023 14:30';

    final targetEstado = _targetEstado ?? _nextEstado(_estado);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_pedidoData ?? _updated);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF003DA5)),
            onPressed: () => Navigator.of(context).pop(_pedidoData ?? _updated),
          ),
          title: const Text(
            'Detalle de Pedido',
            style: TextStyle(color: Color(0xFF003DA5), fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF003DA5)),
              onPressed: () {},
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top card: ID + fecha
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(fecha.toString(), style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 10),
                        const Icon(Icons.circle, size: 6, color: Colors.grey),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          fecha.toString().split(' ').length > 1
                              ? fecha.toString().split(' ').last
                              : '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cliente card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFEAF2FF),
                          child: Text(
                            _initials(nombre),
                            style: const TextStyle(color: Color(0xFF003DA5)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(telefono, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.place, color: Colors.grey, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(direccion, style: const TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 110,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBDE1FF), Color(0xFFEAF6FF)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(child: Container()),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.location_on_outlined),
                              label: const Text('Ver Ruta'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF003DA5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Productos
              const Text(
                'Productos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...detalles.map((d) => _buildProductoTile(d)).toList(),
              const SizedBox(height: 18),

              // Estado del pedido
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado del Pedido', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _estadoChip('PENDIENTE'),
                        if (_estado == 'EN_CAMINO' || _estado == 'EN_CURSO') ...[
                          const SizedBox(width: 8),
                          _estadoChip('EN_CAMINO'),
                        ],
                        if (_estado == 'FINALIZADO') ...[
                          const SizedBox(width: 8),
                          _estadoChip('FINALIZADO'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Monto Final — visible solo si está FINALIZADO
              if (_estado == 'FINALIZADO') ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade50),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Monto Final',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          // Edit button (disabled in readOnly)
                                            _canEditMonto()
                                                ? IconButton(
                                                    onPressed: widget.readOnly ? null : () async {
                                                      await _editMonto();
                                                    },
                                                    icon: const Icon(Icons.edit, color: Color(0xFF003DA5)),
                                                    tooltip: widget.readOnly ? 'Solo lectura' : 'Editar monto final',
                                                  )
                                                : const SizedBox.shrink(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('S/. ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            _displayMonto(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Botón principal
              if (!widget.readOnly) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (targetEstado == _estado)
                        ? null
                        : () async {
                            await _confirmChangeEstado(targetEstado);
                          },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Actualizar a ${targetEstado == _estado ? _estado.toLowerCase() : targetEstado.toLowerCase()}',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003DA5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _displayMonto() {
    // Prioridad: controlador (valor ingresado/actualizado) > pedidoData > widget.pedido
    final ctrl = _montoController.text.isNotEmpty ? _montoController.text : null;
    final v = ctrl ?? _montoFromMap(_pedidoData)?.toString() ?? _montoFromMap(widget.pedido)?.toString();
    return v ?? '-';
  }

  Widget _buildProductoTile(Map<String, dynamic> d) {
    final nombre = d['producto'] ?? '';
    final desc = d['desc'] ?? '';
    final cantidad = d['cantidad'] ?? d['cant'] ?? 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.opacity, color: Color(0xFF003DA5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'x$cantidad',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003DA5)),
          ),
        ],
      ),
    );
  }

  Widget _estadoChip(String value) {
    final label = value == 'EN_CAMINO'
        ? 'en camino'
        : value == 'FINALIZADO'
            ? 'finalizado'
            : 'pendiente';

    final selected = (_targetEstado != null)
        ? (_targetEstado == value)
        : (_estado == value || (_estado == 'EN_CURSO' && value == 'EN_CAMINO'));

    Color bg = selected ? Colors.grey.shade300 : Colors.grey.shade100;
    Color fg = selected ? Colors.grey.shade800 : Colors.grey.shade700;

    if (value == 'EN_CAMINO' || value == 'EN_CURSO') {
      bg = selected ? Colors.lightBlue.shade50 : Colors.grey.shade100;
      fg = selected ? const Color(0xFF0369A1) : Colors.grey.shade700;
    } else if (value == 'FINALIZADO' || value == 'ENTREGADO') {
      bg = selected ? Colors.green.shade50 : Colors.grey.shade100;
      fg = selected ? Colors.green.shade700 : Colors.grey.shade700;
    }

    return GestureDetector(
      onTap: widget.readOnly
          ? null
          : () => setState(() {
                _targetEstado = value;
              }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _nextEstado(String current) {
    if (current == 'PENDIENTE') return 'EN_CAMINO';
    if (current == 'EN_CAMINO' || current == 'EN_CURSO') return 'FINALIZADO';
    return current;
  }

  DateTime? _parseMontoSetAtFromMap(Map? m) {
    if (m == null) return null;
    final v = m['monto_final_set_at'] ?? m['montoFinalSetAt'] ?? m['monto_final_setAt'] ?? m['monto_set_at'];
    if (v == null) return null;
    try {
      if (v is DateTime) return v;
      return DateTime.parse(v.toString());
    } catch (_) {
      try {
        // try as integer epoch
        final n = int.tryParse(v.toString());
        if (n != null) return new DateTime.fromMillisecondsSinceEpoch(n);
      } catch (_) {}
    }
    return null;
  }

  bool _canEditMonto() {
    if (widget.readOnly) return false;
    // If no timestamp exists, allow initial set/edit
    if (_montoSetAt == null) return true;
    final diff = DateTime.now().toUtc().difference(_montoSetAt!.toUtc()).inSeconds;
    return diff <= 300; // 5 minutes = 300 seconds
  }

  String _initials(String full) {
    final parts = full.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0];
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}