import 'package:supabase_flutter/supabase_flutter.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? nombre;
  final String? role;
  final int? id;

  AuthResult({
    required this.success,
    required this.message,
    this.nombre,
    this.role,
    this.id,
  });

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

class AuthService {
  static final supabase = Supabase.instance.client;

  static Future<AuthResult> login(String dni, String password) async {
    try {
      final emailFake = "$dni@peydar.com";

      // 1. Intentar autenticación (flujo original)
      final res = await supabase.auth.signInWithPassword(
        email: emailFake,
        password: password,
      );

      final user = res.user;

      if (user == null) {
        return AuthResult.failure('Contraseña incorrecta');
      }

      // 2. Buscar datos del usuario en la tabla
      final data = await supabase
          .from('usuario')
          .select()
          .eq('auth_id', user.id)
          .maybeSingle();

      if (data == null) {
        return AuthResult.failure(
          'Usuario existe en Auth pero no en tabla usuario',
        );
      }

      return AuthResult(
        success: true,
        message: 'Login correcto',
        nombre: data['nombre'],
        role: data['tipo_usuario'],
        id: data['id'],
      );
    } on AuthException catch (e) {
      // 3. Auth falló — distinguir entre usuario y contraseña
      final usuarioExiste = await supabase
          .from('usuario')
          .select()
          .eq('dni', dni)
          .maybeSingle();

      if (usuarioExiste == null) {
        return AuthResult.failure('Usuario incorrecto');
      }
      return AuthResult.failure('Contraseña incorrecta');
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }
}