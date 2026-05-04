import 'dart:io';

class ApiConfig {
  /// Si estás usando un celular físico, define aquí la IP de tu PC.
  /// Ejemplo: http://192.168.18.192:3000
  static const String manualBaseUrl = 'http://192.168.18.192:3000';

  /// Cambia esta URL según dónde ejecutes tu backend.
  ///
  /// Android emulator: http://10.0.2.2:3000
  /// iOS simulator / macOS: http://localhost:3000
  /// Android physical device: http://<IP-de-tu-PC>:3000
  ///
  /// Si tu backend ya está en la misma red local que el dispositivo,
  /// reemplaza <IP-de-tu-PC> por la dirección IP de tu máquina.
  static String get baseUrl {
    if (manualBaseUrl.isNotEmpty) {
      return manualBaseUrl;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}
