import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class ActivateService extends Service {
  /// Activate account by using activation code and session token
  static Future<ActivateResponse> call(String code, String token) {
    final path = '/account/activate';
    final body = {
      'code': code.toString(),
      'token': token,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return ActivateResponse.bind(status: false, message: m);
      }

      return ActivateResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = ActivateResponse.empty();

      dev.log('Activation error.', error: e, stackTrace: s);

      return Service.handleError<ActivateResponse>(e, s, r);
    };

    final r = Http.doPost(
      path: path,
      body: body,
      type: Http.FORM,
    );

    return r.then(c).catchError(e);
  }
}

class ActivateResponse extends BasicResponse {
  String session;

  /// Create empty object
  ActivateResponse.empty() : super.empty();

  /// Create only status and message
  ActivateResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  ActivateResponse.fromJson(String input) {
    final json = super.fromJson(input);

    session = json['session'] ?? null;
  }
}
