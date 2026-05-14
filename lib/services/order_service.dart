import 'package:supabase_flutter/supabase_flutter.dart';

class OrderResult {
  final bool success;
  final int? pedidoId;
  final String message;

  OrderResult({
    required this.success,
    this.pedidoId,
    required this.message,
  });

  factory OrderResult.success(int id, String msg) {
    return OrderResult(success: true, pedidoId: id, message: msg);
  }

  factory OrderResult.failure(String msg) {
    return OrderResult(success: false, message: msg);
  }
}

class OrderService {
  static final supabase = Supabase.instance.client;

  // 🔥 GUARDAR PEDIDO
  static Future<OrderResult> guardarPedido({
    required int usuarioId,
    required String direccion,
    required String telefono,
    String tipoPedido = 'standard',
    String colorBidon = '',
    required List<Map<String, dynamic>> detalles,
    double? latitud,
    double? longitud,
  }) async {
    try {
      // 1. Insertar pedido
     final pedidoResponse = await supabase
    .from('pedidos')
    .insert({
      'usuario_id': usuarioId,
      'direccion_entrega': direccion,
      'telefono_contacto': telefono,
      'tipo_pedido': tipoPedido,
      'color_bidon': colorBidon,
      'estado': 'PENDIENTE',
      'latitud': latitud,
      'longitud': longitud,
    })
    .select()
    .maybeSingle();

if (pedidoResponse == null) {
  throw Exception('No se pudo crear el pedido');
}

final pedidoId = pedidoResponse['id'];

      // 2. Insertar detalles
      for (var item in detalles) {
        await supabase.from('detalles_pedido').insert({
          'pedido_id': pedidoId,
          'producto': '${item['tipo']} ${item['color']}',
          'cantidad': item['cantidad'],
        });
      }

      return OrderResult.success(pedidoId, 'Pedido guardado correctamente');
    } catch (e) {
      return OrderResult.failure('Error: ${e.toString()}');
    }
  }

  // 🔥 OBTENER PEDIDOS DEL CLIENTE
  static Future<List<Map<String, dynamic>>> obtenerPedidos(int usuarioId) async {
    final data = await supabase
        .from('pedidos')
        .select('*, usuario(nombre, apellido), detalles_pedido(*)')
        .eq('usuario_id', usuarioId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // 🔥 OBTENER TODOS (ADMIN)
  static Future<List<Map<String, dynamic>>> obtenerPedidosAdmin() async {
    final data = await supabase
        .from('pedidos')
        .select('*, usuario(nombre, apellido), detalles_pedido(*)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // 🔥 OBTENER REPORTES (ADMIN) — filtro por fecha y cliente
  static Future<List<Map<String, dynamic>>> obtenerReportes({
    DateTime? desde,
    DateTime? hasta,
    int? usuarioId,
  }) async {
    // Build query with dynamic for type flexibility (filter vs transform builders)
    dynamic query = supabase
        .from('pedidos')
        .select('*, usuario(nombre, apellido), detalles_pedido(*)');

    if (desde != null) {
      query = query.gte('created_at', desde.toUtc().toIso8601String());
    }
    if (hasta != null) {
      query = query.lte('created_at', hasta.toUtc().toIso8601String());
    }
    if (usuarioId != null) {
      query = query.eq('usuario_id', usuarioId);
    }

    query = query.order('created_at', ascending: false);
    final data = await query;
    return List<Map<String, dynamic>>.from(data);
  }

  // 🔥 ACTUALIZAR ESTADO Y (opcional) MONTO — devuelve el registro actualizado
  static Future<Map<String, dynamic>> actualizarEstadoPedido({
    required int pedidoId,
    required String estado,
    double? montoFinal,
  }) async {
    final updates = <String, dynamic>{'estado': estado};
    if (montoFinal != null) {
      updates['monto_final'] = montoFinal;
      updates['monto_final_set_at'] = DateTime.now().toUtc().toIso8601String();
    }

    final resp = await supabase
        .from('pedidos')
        .update(updates)
        .eq('id', pedidoId)
        .select()
        .maybeSingle();

    if (resp == null) throw Exception('Error actualizando pedido: $pedidoId');
    return Map<String, dynamic>.from(resp);
  }

  // 🔥 OBTENER UN PEDIDO
  static Future<Map<String, dynamic>> obtenerPedido(int pedidoId) async {
    final data = await supabase
        .from('pedidos')
        .select('*, usuario(nombre, apellido), detalles_pedido(*)')
        .eq('id', pedidoId)
        .maybeSingle();

    if (data == null) throw Exception('Pedido no encontrado: $pedidoId');
    return Map<String, dynamic>.from(data);
  }

  // Save returned bottles when finalizing
  static Future<void> actualizarBidonesDevueltos({
    required int pedidoId,
    required int azul,
    required int celeste,
  }) async {
    await supabase
        .from('pedidos')
        .update({
          'bidones_devueltos_azul': azul,
          'bidones_devueltos_celeste': celeste,
        })
        .eq('id', pedidoId);
  }

  // Get total debt for a customer
  static Future<Map<String, int>> obtenerDeudaCliente(int usuarioId) async {
    final pedidos = await supabase
        .from('pedidos')
        .select('*, detalles_pedido(*)')
        .eq('usuario_id', usuarioId);

    int deudaAzul = 0;
    int deudaCeleste = 0;

    for (var pedido in pedidos) {
      final detalles = pedido['detalles_pedido'] as List? ?? [];
      int recargaAzul = 0;
      int recargaCeleste = 0;

      for (var detalle in detalles) {
        final producto = (detalle['producto'] ?? '').toString();
        final cantidad = detalle['cantidad'] is int
            ? detalle['cantidad'] as int
            : int.tryParse(detalle['cantidad']?.toString() ?? '0') ?? 0;
        if (producto == 'Recarga Azul') recargaAzul += cantidad;
        if (producto == 'Recarga Celeste') recargaCeleste += cantidad;
      }

      final devueltosAzul = pedido['bidones_devueltos_azul'] is int
          ? pedido['bidones_devueltos_azul'] as int
          : int.tryParse(pedido['bidones_devueltos_azul']?.toString() ?? '0') ?? 0;
      final devueltosCeleste = pedido['bidones_devueltos_celeste'] is int
          ? pedido['bidones_devueltos_celeste'] as int
          : int.tryParse(pedido['bidones_devueltos_celeste']?.toString() ?? '0') ?? 0;

      deudaAzul += (recargaAzul - devueltosAzul).clamp(0, 999);
      deudaCeleste += (recargaCeleste - devueltosCeleste).clamp(0, 999);
    }

    return {'azul': deudaAzul, 'celeste': deudaCeleste};
  }
}