import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final supabase = Supabase.instance.client;

  // 🔥 OBTENER CLIENTES
  static Future<List<Map<String, dynamic>>> obtenerClientes() async {
    final data = await supabase
        .from('usuario')
        .select()
        .eq('tipo_usuario', 'cliente')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  // 🔥 CREAR ADMINISTRADOR (solo otro admin puede hacerlo, validado en RPC)
  static Future<Map<String, dynamic>> crearAdmin({
    required String usuario,
    required String nombre,
    required String apellido,
    required String telefono,
    required String password,
    String? gmail,
    String? direccion,
  }) async {
    try {
      final res = await supabase.rpc('crear_admin_completo', params: {
        'p_dni': usuario,
        'p_password': password,
        'p_nombre': nombre,
        'p_apellido': apellido,
        'p_telefono': telefono,
        'p_gmail': gmail,
        'p_direccion': direccion,
      });
      return Map<String, dynamic>.from(res);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // 🔥 CREAR CLIENTE usando función SQL (no afecta la sesión del admin)
  static Future<Map<String, dynamic>> crearCliente({
    required String usuario,
    required String nombre,
    required String apellido,
    required String telefono,
    required String password,
    String? gmail,
    String? direccion,
  }) async {
    try {
      // Usar la función SQL que creamos antes
      await supabase.rpc('crear_usuario_completo', params: {
        'p_dni': usuario,
        'p_password': password,
        'p_nombre': nombre,
        'p_apellido': apellido,
        'p_telefono': telefono,
        'p_tipo_usuario': 'cliente',
        'p_gmail': gmail,
        'p_direccion': direccion,
      });

      // Obtener el id recién creado
     final insert = await supabase
    .from('usuario')
    .select()
    .eq('dni', usuario)
    .maybeSingle();

if (insert == null) {
  return {
    'status': 'error',
    'message': 'Cliente creado pero no encontrado en tabla'
  };
}

      return {
        'status': 'success',
        'message': 'Cliente creado correctamente',
        'data': insert,
      };
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // 🔥 EDITAR CLIENTE
  static Future<Map<String, dynamic>> editarCliente({
    required int usuarioId,
    required String nombre,
    required String apellido,
    required String telefono,
    String? gmail,
    String? direccion,
  }) async {
    try {
      final resp = await supabase.from('usuario').update({
        'nombre': nombre,
        'apellido': apellido,
        'telefono': telefono,
        'gmail': gmail,
        'direccion': direccion,
      }).eq('id', usuarioId).select().maybeSingle();

      if (resp == null) {
        return {'status': 'error', 'message': 'No se pudo actualizar'};
      }
      return {'status': 'success', 'message': 'Actualizado', 'data': resp};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // 🔥 DESACTIVAR CLIENTE
  static Future<Map<String, dynamic>> desactivarCliente({
    int? usuarioId,
    String? dni,
  }) async {
    try {
      if (usuarioId != null) {
        await supabase
            .from('usuario')
            .update({'estado': 'INACTIVO'})
            .eq('id', usuarioId);
      } else if (dni != null) {
        await supabase
            .from('usuario')
            .update({'estado': 'INACTIVO'})
            .eq('dni', dni);
      }
      return {'status': 'success', 'message': 'Cliente desactivado'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // 🔥 ACTIVAR CLIENTE
  static Future<Map<String, dynamic>> activarCliente({
    int? usuarioId,
    String? dni,
  }) async {
    try {
      if (usuarioId != null) {
        await supabase
            .from('usuario')
            .update({'estado': 'ACTIVO'})
            .eq('id', usuarioId);
      } else if (dni != null) {
        await supabase
            .from('usuario')
            .update({'estado': 'ACTIVO'})
            .eq('dni', dni);
      }
      return {'status': 'success', 'message': 'Cliente activado'};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}