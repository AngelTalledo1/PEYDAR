import 'package:flutter/material.dart';

/// Servicio compartido de navegación.
/// Usa [navigatorKey] como GlobalKey para que servicios como FcmService
/// puedan navegar sin tener un BuildContext.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
