import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:apppeydar/services/order_service.dart';
import 'package:apppeydar/services/boleta_service.dart';

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

  // Pending bottle return data (collected before saving)
  int? _pendingDevueltosAzul;
  int? _pendingDevueltosCeleste;

  @override
  void initState() {
    super.initState();
    final p = widget.pedido ?? {};
    debugPrint('DetallePedido.initState widget.pedido: $p');
    _estado = (p['estado'] ?? 'PENDIENTE').toString().toUpperCase();
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
        _estado = (p['estado'] ?? _estado).toString().toUpperCase();
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

      // Collect returned bottles
      final detalles = _pedidoData?['detalles_pedido'] as List? ?? widget.pedido?['detalles_pedido'] as List? ?? [];
      int recargaAzul = 0;
      int recargaCeleste = 0;
      for (var d in detalles) {
        final prod = (d['producto'] ?? '').toString();
        final cant = d['cantidad'] is int ? d['cantidad'] as int : int.tryParse(d['cantidad']?.toString() ?? '0') ?? 0;
        if (prod == 'Recarga Azul') recargaAzul += cant;
        if (prod == 'Recarga Celeste') recargaCeleste += cant;
      }

      if (recargaAzul > 0 || recargaCeleste > 0) {
        final returned = await _showBidonesDevueltosDialog(recargaAzul, recargaCeleste);
        if (returned == null) return; // user cancelled -> abort finalization
        setState(() {
          _pendingDevueltosAzul = returned['azul'] ?? 0;
          _pendingDevueltosCeleste = returned['celeste'] ?? 0;
        });
      }
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

      int? pid;
      if (_pedidoData != null && _pedidoData!['id'] != null) {
        pid = _pedidoData!['id'] is int
            ? _pedidoData!['id'] as int
            : _parsePedidoId(_pedidoData!['id']);
      } else if (widget.pedido != null) {
        final rawId = widget.pedido!['id'] ?? widget.pedido!['pedido_id'];
        pid = rawId is int ? rawId as int : _parsePedidoId(rawId);
      }

      if (pid == null || pid <= 0) throw Exception('ID de pedido inválido');

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

      // Save returned bottles if collected
      if (_pendingDevueltosAzul != null && _pendingDevueltosCeleste != null) {
        try {
          await OrderService.actualizarBidonesDevueltos(
            pedidoId: pid,
            azul: _pendingDevueltosAzul!,
            celeste: _pendingDevueltosCeleste!,
          );
        } catch (_) {
          // non-fatal: bottle return data just won't be saved
        }
        setState(() {
          _pendingDevueltosAzul = null;
          _pendingDevueltosCeleste = null;
        });
      }

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

      int? pid;
      if (_pedidoData != null && _pedidoData!['id'] != null) {
        pid = _pedidoData!['id'] is int
            ? _pedidoData!['id'] as int
            : _parsePedidoId(_pedidoData!['id']);
      } else if (widget.pedido != null) {
        final rawId = widget.pedido!['id'] ?? widget.pedido!['pedido_id'];
        pid = rawId is int ? rawId as int : _parsePedidoId(rawId);
      }

      if (pid == null || pid <= 0) throw Exception('ID de pedido inválido');

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
    final nombreCliente = (p['usuario']?['nombre'] ?? '').toString();
    final apellidoCliente = (p['usuario']?['apellido'] ?? '').toString();
    final nombre = [nombreCliente, apellidoCliente]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final telefono = (p['telefono_contacto'] ?? '+54 9 11 4455-6677').toString();
    final direccion = (p['direccion_entrega'] ??
            'Calle de las Aguas 1450, Piso 4, Dpto B. San Isidro, Buenos Aires.')
        .toString();

    // Coordenadas para el mapa
    final rawLat = p['latitud'];
    final rawLon = p['longitud'];
    double? lat;
    double? lon;
    if (rawLat != null) {
      lat = rawLat is double ? rawLat : double.tryParse(rawLat.toString());
    }
    if (rawLon != null) {
      lon = rawLon is double ? rawLon : double.tryParse(rawLon.toString());
    }
    final hasCoords = lat != null && lon != null;

    final detalles = (p['detalles_pedido'] is List)
        ? List<Map<String, dynamic>>.from(p['detalles_pedido'])
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: hasCoords ? 180 : 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: hasCoords
                            ? FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(lat!, lon!),
                                  initialZoom: 17.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.apppeydar.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(lat!, lon!),
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Color(0xFF002855),
                                          size: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFBDE1FF), Color(0xFFEAF6FF)],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: Color(0xFF003DA5)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Sin coordenadas de mapa',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF002855),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            direccion,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                // Ver Boleta
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _verBoleta(),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Ver Boleta',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF003DA5),
                      side: const BorderSide(color: Color(0xFF003DA5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Botón de registrar devolución — solo en FINALIZADO
                if (!widget.readOnly) _buildBottleReturnSection(),
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
        ? 'En camino'
        : value == 'FINALIZADO'
            ? 'Finalizado'
            : 'Pendiente';

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

  Future<Map<String, int>?> _showBidonesDevueltosDialog(int maxAzul, int maxCeleste) async {
    int devueltosAzul = maxAzul;
    int devueltosCeleste = maxCeleste;
    final azulCtrl = TextEditingController(text: maxAzul.toString());
    final celesteCtrl = TextEditingController(text: maxCeleste.toString());

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar bidones devueltos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Indicá cuántos bidones vacíos devolvió el cliente para este pedido.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // Azul
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF003DA5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Bidón Azul', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: azulCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '0',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null) {
                          setDialogState(() => devueltosAzul = parsed.clamp(0, maxAzul));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('/ $maxAzul', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              // Celeste
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF87CEEB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Bidón Celeste', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: celesteCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: '0',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null) {
                          setDialogState(() => devueltosCeleste = parsed.clamp(0, maxCeleste));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('/ $maxCeleste', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF003DA5), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _calcularTextoDeuda(maxAzul, maxCeleste, devueltosAzul, devueltosCeleste),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF002855)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop({
                'azul': devueltosAzul.clamp(0, maxAzul),
                'celeste': devueltosCeleste.clamp(0, maxCeleste),
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003DA5),
              ),
              child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    azulCtrl.dispose();
    celesteCtrl.dispose();
    return result;
  }

  String _calcularTextoDeuda(int maxAzul, int maxCeleste, int devAzul, int devCeleste) {
    final deudaAzul = maxAzul - devAzul;
    final deudaCeleste = maxCeleste - devCeleste;
    final partes = <String>[];
    if (deudaAzul > 0) partes.add('$deudaAzul azul');
    if (deudaCeleste > 0) partes.add('$deudaCeleste celeste');
    if (partes.isEmpty) return '✓ No debe bidones';
    return '⚠ Debe ${partes.join(', ')}';
  }

  bool _canEditMonto() {
    if (widget.readOnly) return false;
    // If no timestamp exists, allow initial set/edit
    if (_montoSetAt == null) return true;
    final diff = DateTime.now().toUtc().difference(_montoSetAt!.toUtc()).inSeconds;
    return diff <= 300; // 5 minutes = 300 seconds
  }

  Future<void> _verBoleta() async {
    final p = _pedidoData ?? (widget.pedido ?? {});
    
    // Get customer name
    final nombre = (p['usuario']?['nombre'] ?? '').toString();
    final apellido = (p['usuario']?['apellido'] ?? '').toString();
    final clienteNombre = [nombre, apellido].where((s) => s.isNotEmpty).join(' ');
    
    final direccion = (p['direccion_entrega'] ?? '').toString();
    final telefono = (p['telefono_contacto'] ?? '').toString();
    final pedidoId = p['id'] is int ? p['id'] as int : int.tryParse(p['id']?.toString() ?? '0') ?? 0;
    
    // Get monto
    final monto = _montoFromMap(p) ?? 0.0;
    final montoFinal = monto is double ? monto : double.tryParse(monto.toString()) ?? 0.0;
    
    // Get detalles
    final List<Map<String, dynamic>> detalles = ((p['detalles_pedido'] as List?) ?? []).cast<Map<String, dynamic>>();
    
    // Format date
    final rawFecha = (p['fecha_pedido'] ?? '').toString();
    String fecha = rawFecha;
    try {
      final dt = DateTime.parse(rawFecha).toLocal();
      fecha = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {}
    
    await BoletaService.verBoleta(
      pedidoId: pedidoId,
      clienteNombre: clienteNombre.isNotEmpty ? clienteNombre : 'Cliente',
      direccion: direccion,
      telefono: telefono,
      detalles: detalles,
      montoFinal: montoFinal,
      fecha: fecha,
    );
  }

  String _initials(String full) {
    final parts = full.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0];
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildBottleReturnSection() {
    final p = _pedidoData ?? (widget.pedido ?? {});
    final detalles = p['detalles_pedido'] as List? ?? [];
    
    // Calculate recarga quantities for this order
    int recargaAzul = 0;
    int recargaCeleste = 0;
    for (var d in detalles) {
      final prod = (d['producto'] ?? '').toString();
      final cant = d['cantidad'] is int ? d['cantidad'] as int : int.tryParse(d['cantidad']?.toString() ?? '0') ?? 0;
      if (prod == 'Recarga Azul') recargaAzul += cant;
      if (prod == 'Recarga Celeste') recargaCeleste += cant;
    }
    
    if (recargaAzul == 0 && recargaCeleste == 0) return const SizedBox.shrink();
    
    final returnedAzul = p['bidones_devueltos_azul'] is int
        ? p['bidones_devueltos_azul'] as int
        : int.tryParse(p['bidones_devueltos_azul']?.toString() ?? '0') ?? 0;
    final returnedCeleste = p['bidones_devueltos_celeste'] is int
        ? p['bidones_devueltos_celeste'] as int
        : int.tryParse(p['bidones_devueltos_celeste']?.toString() ?? '0') ?? 0;
    
    final deudaAzul = (recargaAzul - returnedAzul).clamp(0, 999);
    final deudaCeleste = (recargaCeleste - returnedCeleste).clamp(0, 999);
    
    final partes = <String>[];
    if (deudaAzul > 0) partes.add('$deudaAzul azul');
    if (deudaCeleste > 0) partes.add('$deudaCeleste celeste');
    
    final tieneDeuda = partes.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tieneDeuda ? const Color(0xFFFFF3E0) : const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tieneDeuda ? const Color(0xFFFFB74D) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                tieneDeuda ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 18,
                color: tieneDeuda ? const Color(0xFFE65100) : const Color(0xFF16A34A),
              ),
              const SizedBox(width: 8),
              Text(
                'Bidones del pedido',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recarga: $recargaAzul azul, $recargaCeleste celeste  |  Devueltos: $returnedAzul azul, $returnedCeleste celeste',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (tieneDeuda) ...[
            const SizedBox(height: 6),
            Text(
              'Pendiente: ${partes.join(', ')}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFBF360C),
              ),
            ),
          ],
          if (!widget.readOnly) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _registrarDevolucion(
                  recargaAzul, recargaCeleste, returnedAzul, returnedCeleste,
                ),
                icon: const Icon(Icons.replay, size: 16),
                label: Text(
                  tieneDeuda ? 'Registrar devolución' : 'Actualizar devolución',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF003DA5),
                  side: const BorderSide(color: Color(0xFF003DA5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _registrarDevolucion(int recargaAzul, int recargaCeleste, int returnedAzul, int returnedCeleste) async {
    // Calculate remaining available returns
    final availableAzul = recargaAzul - returnedAzul;
    final availableCeleste = recargaCeleste - returnedCeleste;
    
    final result = await _showBidonesDevueltosDialog(recargaAzul, recargaCeleste);
    if (result == null || !mounted) return;
    
    int? pid;
    if (_pedidoData != null && _pedidoData!['id'] != null) {
      pid = _pedidoData!['id'] is int
          ? _pedidoData!['id'] as int
          : _parsePedidoId(_pedidoData!['id']);
    } else if (widget.pedido != null) {
      final rawId = widget.pedido!['id'] ?? widget.pedido!['pedido_id'];
      pid = rawId is int ? rawId as int : _parsePedidoId(rawId);
    }
    if (pid == null || pid <= 0) return;
    
    try {
      await OrderService.actualizarBidonesDevueltos(
        pedidoId: pid,
        azul: result['azul'] ?? 0,
        celeste: result['celeste'] ?? 0,
      );
      
      // Refresh pedido data
      final fresh = await OrderService.obtenerPedido(pid);
      if (mounted) {
        setState(() {
          _pedidoData = fresh;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devolución registrada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}