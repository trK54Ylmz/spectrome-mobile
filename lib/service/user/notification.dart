import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class NotificationTokenService extends Service {
  /// Get system version
  static Future<NotificationTokenResponse> call({
    String session,
    String token,
  }) {
    final path = '/users/notification';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {'token': token};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return NotificationTokenResponse.bind(status: false, message: m);
      }

      return NotificationTokenResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = NotificationTokenResponse.empty();

      dev.log('Notification token error.', error: e, stackTrace: s);

      return Service.handleError<NotificationTokenResponse>(e, s, r);
    };

    final r = Http.doPost(
      path: path,
      headers: headers,
      body: body,
      type: Http.FORM,
    );

    return r.then(c).catchError(e);
  }
}

class NotificationTokenResponse extends BasicResponse {
  /// Create empty object
  NotificationTokenResponse.empty() : super.empty();

  /// Create only status and message
  NotificationTokenResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  NotificationTokenResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
