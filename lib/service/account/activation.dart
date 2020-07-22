import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class ActivationService extends Service {
  /// Send activation code by using activation code and session token
  static Future<ActivationResponse> call(String token) {
    final path = '/account/activation';
    final body = {
      'token': token,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return ActivationResponse.bind(status: false, message: m);
      }

      return ActivationResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = ActivationResponse.empty();

      dev.log('Activation error.', error: e, stackTrace: s);

      return Service.handleError<ActivationResponse>(e, s, r);
    };

    final r = Http.doPost(
      path: path,
      body: body,
      type: Http.FORM,
    );

    return r.then(c).catchError(e);
  }
}

class ActivationResponse extends BasicResponse {
  String token;

  /// Create empty object
  ActivationResponse.empty() : super.empty();

  /// Create only status and message
  ActivationResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  ActivationResponse.fromJson(String input) {
    final json = super.fromJson(input);

    token = json['token'] ?? null;
  }
}
