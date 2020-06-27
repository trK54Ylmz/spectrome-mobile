import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class SignInService extends Service {
  /// Sign in by using loginId and password
  /// Login id is e-mail address or username
  static Future<SignInResponse> call(String loginId, String password) {
    final path = '/account/login';
    final body = {
      'login_id': loginId,
      'password': password,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return SignInResponse.bind(status: false, message: m);
      }

      return SignInResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = SignInResponse.empty();

      dev.log('Sign in error.', error: e, stackTrace: s);

      return Service.handleError<SignInResponse>(e, s, r);
    };

    return Http.doPost(path, body: body, type: Http.FORM).then(c).catchError(e);
  }
}

class SignInResponse extends BasicResponse {
  bool activation = true;

  String session;

  String token;

  /// Create empty object
  SignInResponse.empty() : super.empty();

  /// Create only status and message
  SignInResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  SignInResponse.fromJson(String input) {
    final json = super.fromJson(input);

    token = json['token'] ?? null;
    session = json['session'] ?? null;
    activation = json['activation'] ?? true;
  }
}
