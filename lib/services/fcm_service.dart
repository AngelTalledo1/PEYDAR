import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'navigation_service.dart';

/// Maneja todo el ciclo de vida de notificaciones push:
/// - Permisos + token FCM
/// - Guardar/actualizar token en Supabase
/// - Notificaciones locales (app en foreground)
/// - Tap en notificaciones
class FcmService {
  FcmService._();

  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static final _supabase = Supabase.instance.client;

  /// Inicializar notificaciones locales y handlers
  static Future<void> init() async {
    // ── Configurar notificaciones locales ──
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // ── Handler: cuando llega noti con app en foreground ──
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // ── Handler: cuando se toca una noti con app en background ──
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapData);

    // ── Si la app se abrió desde una noti (terminada) ──
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationTapData(initialMessage);
    }
  }

  /// Solicitar permisos y obtener token
  static Future<String?> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    // Solicitar permiso en iOS (Android lo pide en runtime)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }

    // Obtener token FCM
    final token = await messaging.getToken();
    return token;
  }

  /// Guardar FCM token del admin en Supabase
  static Future<void> guardarToken({
    required int usuarioId,
    required String token,
  }) async {
    await _supabase
        .from('usuario')
        .update({'fcm_token': token}).eq('id', usuarioId);
  }

  /// Limpiar token al cerrar sesión
  static Future<void> limpiarToken(int usuarioId) async {
    await _supabase
        .from('usuario')
        .update({'fcm_token': null}).eq('id', usuarioId);
  }

  // ─── Handlers privados ───────────────────────────────────────────────────

  /// Mostrar notificación local cuando la app está en foreground
  static void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      'peydar_orders',
      'Pedidos',
      channelDescription: 'Notificaciones de nuevos pedidos',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: message.data['pedido_id']?.toString(),
    );
  }

  /// Navegar al detalle del pedido cuando se toca la noti (desde local)
  static void _onNotificationTap(NotificationResponse response) {
    final pedidoId = response.payload;
    if (pedidoId != null) {
      _navegarAPedido(int.tryParse(pedidoId) ?? 0);
    }
  }

  /// Navegar al detalle del pedido cuando se toca la noti (desde FCM)
  static void _onNotificationTapData(RemoteMessage message) {
    final pedidoId = message.data['pedido_id'];
    if (pedidoId != null) {
      _navegarAPedido(int.tryParse(pedidoId.toString()) ?? 0);
    }
  }

  static void _navegarAPedido(int pedidoId) {
    Future.delayed(const Duration(milliseconds: 500), () {
      navigatorKey.currentState?.pushNamed(
        '/admin/pedidos',
        arguments: {'pedido_id': pedidoId},
      );
    });
  }
}
