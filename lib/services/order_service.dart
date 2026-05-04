import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class OrderResult {
  final bool success;
  final int? pedidoId;
  final String message;

  const OrderResult({
    required this.success,
    this.pedidoId,
    required this.message,
  });

  factory OrderResult.success(int pedidoId, String message) {
    return OrderResult(success: true, pedidoId: pedidoId, message: message);
  }

  factory OrderResult.failure(String message) {
    return OrderResult(success: false, pedidoId: null, message: message);
  }
}

class OrderService {
  static String get baseUrl => ApiConfig.baseUrl;

  static const String apiKey = 'peydar_api_2024_secure_key';

  static Future<OrderResult> guardarPedido({
    required int usuarioId,
    required String direccion,
    required String telefono,
    required List<Map<String, dynamic>> detalles,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/guardar_pedido'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'api_key': apiKey,
              'usuario_id': usuarioId,
              'direccion': direccion,
              'telefono': telefono,
              'detalles': detalles,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception(
              'Timeout: El servidor tardó demasiado en responder. Verifica tu conexión y la URL del servidor.',
            ),
          );

      if (response.statusCode != 200) {
        // Intentar decodificar el cuerpo de respuesta para mostrar el mensaje del servidor
        String serverMsg = 'Error del servidor (${response.statusCode}). Por favor intenta de nuevo.';
        try {
          final Map<String, dynamic> err = jsonDecode(response.body);
          if (err['message'] != null) serverMsg = err['message'].toString();
          else if (err['error'] != null) serverMsg = err['error'].toString();
        } catch (_) {}

        return OrderResult.failure(serverMsg);
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['status'] != 'success' || data['pedido_id'] == null) {
        return OrderResult.failure(
          data['message'] ??
              'No se pudo guardar el pedido. Verifica los datos e intenta de nuevo.',
        );
      }

      final int pedidoId = int.tryParse(data['pedido_id'].toString()) ?? 0;
      if (pedidoId <= 0) {
        return OrderResult.failure('ID de pedido inválido recibido del servidor.');
      }

      return OrderResult.success(
        pedidoId,
        data['message'] ?? 'Pedido guardado correctamente',
      );
    } catch (error) {
      final message = error.toString();
      if (message.contains('SocketException') || message.contains('Connection refused')) {
        return OrderResult.failure(
          'Error de conexión: No se puede alcanzar el servidor. Verifica la URL y tu conexión.',
        );
      }
      return OrderResult.failure('Error de conexión: $message');
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerPedidos(int usuarioId) async {
    final uri = Uri.parse('$baseUrl/mis_pedidos?usuario_id=$usuarioId');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Error obteniendo pedidos: ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data['status'] != 'success' || data['pedidos'] == null) {
      throw Exception(data['message'] ?? 'Respuesta inválida al obtener pedidos');
    }
    final List<dynamic> raw = data['pedidos'];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<List<Map<String, dynamic>>> obtenerPedidosAdmin() async {
    final uri = Uri.parse('$baseUrl/admin/pedidos');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Error obteniendo pedidos admin: ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data['status'] != 'success' || data['pedidos'] == null) {
      throw Exception(data['message'] ?? 'Respuesta inválida al obtener pedidos admin');
    }
    final List<dynamic> raw = data['pedidos'];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<Map<String, dynamic>> obtenerPedido(int pedidoId) async {
    final uri = Uri.parse('$baseUrl/pedido?id=$pedidoId');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Error obteniendo pedido: ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data['status'] != 'success' || data['pedido'] == null) {
      throw Exception(data['message'] ?? 'Respuesta inválida al obtener pedido');
    }
    return Map<String, dynamic>.from(data['pedido'] as Map);
  }

  static Future<Map<String, dynamic>> actualizarEstadoPedido({
    required int pedidoId,
    required String estado,
    double? montoFinal,
  }) async {
    final uri = Uri.parse('$baseUrl/pedido/actualizar');
    final body = {
      'api_key': apiKey,
      'pedido_id': pedidoId,
      'estado': estado,
    };
    if (montoFinal != null) body['monto_final'] = montoFinal;

    final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body)).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Error actualizando pedido: ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data['status'] != 'success' || data['pedido'] == null) {
      throw Exception(data['message'] ?? 'Respuesta inválida al actualizar pedido');
    }
    return Map<String, dynamic>.from(data['pedido'] as Map);
  }
}
