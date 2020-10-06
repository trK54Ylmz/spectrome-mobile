import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class SignOutService extends Service {
  /// Sign out from current session
  static Future<BasicResponse> call(String session) {
    final path = '/account/out';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return BasicResponse.bind(status: false, message: m);
      }

      return BasicResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = BasicResponse.empty();

      dev.log('Sign out error.', error: e, stackTrace: s);

      return Service.handleError<BasicResponse>(e, s, r);
    };

    final r = Http.doGet(path: path, headers: headers);

    return r.then(c).catchError(e);
  }
}
