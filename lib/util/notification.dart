import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:spectrome/service/user/notification.dart';

class NotificationSystem {
  static final _fb = new FirebaseMessaging();

  /// Initialize firebase
  static Future<void> init(String session) async {
    dev.log('Firebase cloud message initializing.');

    // Request permissiopn notification
    _fb.requestNotificationPermissions();

    // Create configurations of firebase
    _fb.configure();

    // Token callback
    final c = (String token) async {
      dev.log('Token update request sending.');

      final cc = (NotificationTokenResponse r) {
        // create log according to status
        if (r.status) {
          dev.log('Notification token is updated.');
        } else {
          dev.log('Notification token could not updated.');
        }
      };

      // Error callback
      final e = (Object e, StackTrace s) {
        dev.log(e);
      };

      // Prepare request
      final r = NotificationTokenService.call(
        session: session,
        token: token,
      );

      await r.then(cc).catchError(e);
    };

    dev.log('Firebase token is loading.');

    // Get device token
    _fb.getToken().then(c);
  }
}
