import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class FollowingService extends Service {
  /// Follow user by username
  static Future<FollowingResponse> call(String session, String username) {
    final path = '/users/follow/p/$username';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return FollowingResponse.bind(status: false, message: m);
      }

      return FollowingResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = FollowingResponse.empty();

      dev.log('User follow error.', error: e, stackTrace: s);

      return Service.handleError<FollowingResponse>(e, s, r);
    };

    final post = Http.doPost(
      path: path,
      headers: headers,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class FollowingResponse extends BasicResponse {
  /// Create empty object
  FollowingResponse.empty() : super.empty();

  /// Create only status and message
  FollowingResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  FollowingResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
