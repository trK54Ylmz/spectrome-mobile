import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class ResetService extends Service {
  /// Reset password by using code
  static Future<ResetResponse> call(String code, String password, String token) {
    final path = '/account/reset';
    final body = {
      'code': code,
      'password': password,
      'token': token,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return ResetResponse.bind(status: false, message: m);
      }

      return ResetResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = ResetResponse.empty();

      dev.log('Reset password error.', error: e, stackTrace: s);

      return Service.handleError<ResetResponse>(e, s, r);
    };

    final r = Http.doPost(
      path: path,
      body: body,
      type: Http.FORM,
    );

    return r.then(c).catchError(e);
  }
}

class ResetResponse extends BasicResponse {
  /// Create empty object
  ResetResponse.empty() : super.empty();

  /// Create only status and message
  ResetResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  ResetResponse.fromJson(String input) : super.fromJson(input);
}
