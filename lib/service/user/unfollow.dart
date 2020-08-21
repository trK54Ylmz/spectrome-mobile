import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class UnfollowingService extends Service {
  /// Unfollow user by username
  static Future<UnfollowingResponse> call(String session, String username) {
    final path = '/users/unfollow/p/$username';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return UnfollowingResponse.bind(status: false, message: m);
      }

      return UnfollowingResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = UnfollowingResponse.empty();

      dev.log('User unfollow error.', error: e, stackTrace: s);

      return Service.handleError<UnfollowingResponse>(e, s, r);
    };

    final post = Http.doPost(
      path: path,
      headers: headers,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class UnfollowingResponse extends BasicResponse {
  /// Create empty object
  UnfollowingResponse.empty() : super.empty();

  /// Create only status and message
  UnfollowingResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  UnfollowingResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
