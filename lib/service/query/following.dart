import 'dart:developer' as dev;

import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class FollowingQueryService extends Service {
  static Future<FollowingQueryResponse> call(String session, String query) {
    final path = '/query/following';
    final headers = {Http.TOKEN_HEADER: session};
    final params = {'query': query};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return FollowingQueryResponse.bind(status: false, message: m);
      }

      return FollowingQueryResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = FollowingQueryResponse.empty();

      dev.log('Following query error.', error: e, stackTrace: s);

      return Service.handleError<FollowingQueryResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      params: params,
      headers: headers,
    );

    return r.then(c).catchError(e);
  }
}

class FollowingQueryResponse extends BasicResponse {
  // List of suggested users
  List<SimpleProfile> users;

  /// Create empty object
  FollowingQueryResponse.empty() : super.empty();

  /// Create only status and message
  FollowingQueryResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  FollowingQueryResponse.fromJson(String input) {
    final json = super.fromJson(input);

    if (json['users'] == null) {
      users = [];
    } else {
      final u = json['users'] as List<Map<String, dynamic>>;

      final c = (Map<String, dynamic> u) {
        return SimpleProfile(
          name: u['name'],
          username: u['username'],
          photoUrl: u['photo_url'],
        );
      };

      users = u.map(c);
    }
  }
}
