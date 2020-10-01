import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CircleRemoveService extends Service {
  /// Remove user from circle by username
  static Future<CircleRemoveResponse> call(String session, String username) {
    final path = '/users/remove/p/$username';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CircleRemoveResponse.bind(status: false, message: m);
      }

      return CircleRemoveResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CircleRemoveResponse.empty();

      dev.log('User remove circle error.', error: e, stackTrace: s);

      return Service.handleError<CircleRemoveResponse>(e, s, r);
    };

    final post = Http.doPost(
      path: path,
      headers: headers,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class CircleRemoveResponse extends BasicResponse {
  /// Create empty object
  CircleRemoveResponse.empty() : super.empty();

  /// Create only status and message
  CircleRemoveResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CircleRemoveResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
