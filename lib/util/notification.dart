import 'dart:developer' as dev;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notification {
  /// Initialize plugin
  Future<void> init(FlutterLocalNotificationsPlugin p) async {
    final ir = (int id, String title, String body, String payload) async {};

    final oc = (String payload) async {
      dev.log(payload);
    };

    var a = new AndroidInitializationSettings('ic_launcher');
    var i = IOSInitializationSettings(onDidReceiveLocalNotification: ir);

    // Initialize platform settings
    var s = new InitializationSettings(a, i);

    // Initialize plugin
    await p.initialize(s, onSelectNotification: oc);
  }
}
