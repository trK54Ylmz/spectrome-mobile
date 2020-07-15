import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class ForgotService extends Service {
  /// Send forgot password mail
  static Future<ForgotResponse> call(String username, String phone) {
    final path = '/account/forgot';
    final body = {
      'username': username,
      'phone': phone,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return ForgotResponse.bind(status: false, message: m);
      }

      return ForgotResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = ForgotResponse.empty();

      dev.log('Forgot password error.', error: e, stackTrace: s);

      return Service.handleError<ForgotResponse>(e, s, r);
    };

    return Http.doPost(path, body: body, type: Http.FORM).then(c).catchError(e);
  }
}

class ForgotResponse extends BasicResponse {

  /// Create empty object
  ForgotResponse.empty() : super.empty();

  /// Create only status and message
  ForgotResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  ForgotResponse.fromJson(String input) : super.fromJson(input);
}
