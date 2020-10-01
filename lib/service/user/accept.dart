import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CircleAcceptService extends Service {
  /// Accept incoimg circle request by session and request code
  static Future<CircleAcceptResponse> call(String session, String code) {
    final path = '/users/circle/accept';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {
      'code': code,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CircleAcceptResponse.bind(status: false, message: m);
      }

      return CircleAcceptResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CircleAcceptResponse.empty();

      dev.log('Accept incoming circle error.', error: e, stackTrace: s);

      return Service.handleError<CircleAcceptResponse>(e, s, r);
    };

    final post = Http.doPost(
      path: path,
      headers: headers,
      body: body,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class CircleAcceptResponse extends BasicResponse {
  /// Create empty object
  CircleAcceptResponse.empty() : super.empty();

  /// Create only status and message
  CircleAcceptResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CircleAcceptResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
