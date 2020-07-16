import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class SignUpService extends Service {
  /// Create new user account
  /// by using e-mail address, password, name and username
  static Future<SignUpResponse> call(
    String phone,
    String email,
    String password,
    String username,
    String name,
  ) {
    final path = '/account/create';
    final body = {
      'phone': phone,
      'username': username,
      'email': email,
      'password': password,
      'name': name,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return SignUpResponse.bind(status: false, message: m);
      }

      return SignUpResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = SignUpResponse.empty();

      dev.log('Sign up error.', error: e, stackTrace: s);

      return Service.handleError<SignUpResponse>(e, s, r);
    };

    return Http.doPost(path, body: body, type: Http.FORM).then(c).catchError(e);
  }
}

class SignUpResponse extends BasicResponse {
  // Session token
  String token;

  /// Create empty object
  SignUpResponse.empty() : super.empty();

  /// Create only status and message
  SignUpResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  SignUpResponse.fromJson(String input) {
    final json = super.fromJson(input);

    token = json['token'];
  }
}
