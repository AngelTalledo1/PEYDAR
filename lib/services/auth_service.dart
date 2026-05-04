import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthResult {
  final bool success;
  final String message;
  final String? role;
  final String? nombre;
  final int? id;
  final String? token;

  const AuthResult({
    required this.success,
    required this.message,
    this.role,
    this.nombre,
    this.id,
    this.token,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      role: json['role']?.toString(),
      nombre: json['name']?.toString(),
      id: json['user'] != null
          ? int.tryParse(json['user']['id']?.toString() ?? '')
          : null,
      token: json['token']?.toString(),
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(success: false, message: message);
  }
}

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<AuthResult> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return AuthResult.fromJson(jsonDecode(response.body));
      }

      final errorJson = jsonDecode(response.body);
      return AuthResult.failure(
        errorJson['message']?.toString() ?? 'Error del servidor',
      );
    } catch (e) {
      return AuthResult.failure('Error de conexión: ${e.toString()}');
    }
  }
}