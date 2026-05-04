import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserService {
  static const String _apiKey = 'peydar_api_2024_secure_key';

  // ─── OBTENER CLIENTES ──────────────────────────────────────────────────────
  /// Obtiene todos los usuarios de tipo 'cliente' con su último pedido.
  static Future<List<Map<String, dynamic>>> obtenerClientes() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/clientes');
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Error fetching clientes: ${resp.statusCode}');
    }
    final body = json.decode(resp.body) as Map<String, dynamic>;
    final clientes = (body['clientes'] as List?) ?? [];
    return clientes.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ─── CREAR CLIENTE ─────────────────────────────────────────────────────────
  /// Crea un nuevo cliente en el backend.
  static Future<Map<String, dynamic>> crearCliente({
    required String usuario,
    required String nombre,
    required String apellido,
    required String telefono,
    required String password,
    String? gmail,
    String? direccion,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/usuario');
    final body = {
      'api_key': _apiKey,
      'usuario': usuario,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'password': password,
      'gmail': gmail,
      'direccion': direccion,
      'tipo_usuario': 'cliente',
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Error creando cliente: ${resp.statusCode}');
    }
    try {
      return json.decode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Respuesta inválida del servidor al crear cliente');
    }
  }

  // ─── EDITAR CLIENTE ────────────────────────────────────────────────────────
      /// Activa un cliente (cambia `estado` a 'ACTIVO') usando el campo DNI/usuario.
      static Future<Map<String, dynamic>> activarCliente({required String dni}) async {
        // Reusa el endpoint de actualizar para establecer estado
        final payload = {'usuario': dni, 'estado': 'ACTIVO'};
        return actualizarCliente(payload);
      }
  /// Edita los datos de un cliente existente por su usuario_id.
  static Future<Map<String, dynamic>> editarCliente({
    required dynamic usuarioId,
    required String nombre,
    required String apellido,
    required String telefono,
    String? gmail,
    String? direccion,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/usuario/editar');
    final body = {
      'api_key': _apiKey,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'gmail': gmail,
      'direccion': direccion,
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) {
      throw Exception('Error editando cliente: ${resp.statusCode}');
    }
    try {
      return json.decode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Respuesta inválida del servidor al editar cliente');
    }
  }

  // ─── DESACTIVAR CLIENTE ────────────────────────────────────────────────────
  /// Desactiva un cliente por su DNI/usuario (envía `usuario` al backend).
  static Future<Map<String, dynamic>> desactivarCliente({required String dni}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/usuario/desactivar');
    final body = {
      'api_key': _apiKey,
      'usuario': dni,
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) {
      throw Exception('Error desactivando cliente: ${resp.statusCode}');
    }

    try {
      return json.decode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Respuesta inválida del servidor al desactivar cliente');
    }
  }

  // ─── ACTUALIZAR CLIENTE (genérico) ────────────────────────────────────────
  /// Actualiza campos genéricos de un cliente. Se espera `usuario_id` en el payload.
  static Future<Map<String, dynamic>> actualizarCliente(
      Map<String, dynamic> payload) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/usuario/actualizar');
    final body = {...payload, 'api_key': _apiKey};

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    ).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) {
      throw Exception('Error actualizando cliente: ${resp.statusCode}');
    }
    try {
      return json.decode(resp.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Respuesta inválida del servidor al actualizar cliente');
    }
  }
}