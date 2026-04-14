import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // ⚠️ Cambia esto por tu dominio real de cPanel
  static const String baseUrl = 'https://mabticspiura.com/api';

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Error del servidor'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Sin conexión a internet'};
    }
  }
}