import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class SessionService extends Service {
  /// Check user session by using session code
  static Future<SessionResponse> call(String session) {
    final path = '/session/check';
    final body = {'session': session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return SessionResponse.bind(status: false, message: m);
      }

      return SessionResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = SessionResponse.empty();

      dev.log('Session check error.', error: e, stackTrace: s);

      return Service.handleError<SessionResponse>(e, s, r);
    };

    return Http.doPost(path, body: body).then(c).catchError(e);
  }
}

class SessionResponse extends BasicResponse {
  String session;

  /// Create empty object
  SessionResponse.empty() : super.empty();

  /// Create only status and message
  SessionResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  SessionResponse.fromJson(String input) {
    final json = super.fromJson(input);

    session = json['session'] ?? null;
  }
}
