import 'dart:developer' as dev;

import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CircleUserService extends Service {
  /// Get list of follower users
  static Future<CircleUserResponse> call({
    String session,
    String username,
  }) {
    final path = '/profile/circle/user/$username';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CircleUserResponse.bind(status: false, message: m);
      }

      return CircleUserResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CircleUserResponse.empty();

      dev.log('Following users error.', error: e, stackTrace: s);

      return Service.handleError<CircleUserResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      headers: headers,
      type: Http.JSON,
    );

    return r.then(c).catchError(e);
  }
}

class CircleUserResponse extends BasicResponse {
  // List of follower users
  List<SimpleProfile> users;

  /// Create empty object
  CircleUserResponse.empty() : super.empty();

  /// Create only status and message
  CircleUserResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CircleUserResponse.fromJson(String input) {
    final json = super.fromJson(input);

    if (json['users'] == null) {
      users = [];
    } else {
      final u = json['users'] as List<dynamic>;

      final c = (Map<String, dynamic> u) {
        return SimpleProfile(
          name: u['name'],
          username: u['username'],
          photoUrl: u['photo_url'],
        );
      };

      users = u.map((i) => c(i as Map<String, dynamic>)).toList();
    }
  }
}
