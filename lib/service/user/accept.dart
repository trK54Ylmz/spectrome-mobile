import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class FollowAcceptService extends Service {
  /// Accept follow request by session and request code
  static Future<FollowAcceptResponse> call(String session, String code) {
    final path = '/users/follow/accept';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {
      'code': code,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return FollowAcceptResponse.bind(status: false, message: m);
      }

      return FollowAcceptResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = FollowAcceptResponse.empty();

      dev.log('Follow accept error.', error: e, stackTrace: s);

      return Service.handleError<FollowAcceptResponse>(e, s, r);
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

class FollowAcceptResponse extends BasicResponse {
  /// Create empty object
  FollowAcceptResponse.empty() : super.empty();

  /// Create only status and message
  FollowAcceptResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  FollowAcceptResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
