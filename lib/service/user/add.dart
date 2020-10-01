import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CircleAddService extends Service {
  /// Add user in circle by username
  static Future<CircleAddResponse> call(String session, String username) {
    final path = '/users/add/p/$username';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CircleAddResponse.bind(status: false, message: m);
      }

      return CircleAddResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CircleAddResponse.empty();

      dev.log('User add circle error.', error: e, stackTrace: s);

      return Service.handleError<CircleAddResponse>(e, s, r);
    };

    final post = Http.doPost(
      path: path,
      headers: headers,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class CircleAddResponse extends BasicResponse {
  /// Create empty object
  CircleAddResponse.empty() : super.empty();

  /// Create only status and message
  CircleAddResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CircleAddResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
