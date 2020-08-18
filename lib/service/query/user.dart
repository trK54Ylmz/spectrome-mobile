import 'dart:developer' as dev;

import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class UserQueryService extends Service {
  static Future<UserQueryResponse> call(String session, String query) {
    final path = '/query/user';
    final headers = {Http.TOKEN_HEADER: session};
    final params = {'query': query};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return UserQueryResponse.bind(status: false, message: m);
      }

      return UserQueryResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = UserQueryResponse.empty();

      dev.log('User query error.', error: e, stackTrace: s);

      return Service.handleError<UserQueryResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      params: params,
      headers: headers,
    );

    return r.then(c).catchError(e);
  }
}

class UserQueryResponse extends BasicResponse {
  // List of suggested users
  List<SimpleProfile> users;

  /// Create empty object
  UserQueryResponse.empty() : super.empty();

  /// Create only status and message
  UserQueryResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  UserQueryResponse.fromJson(String input) {
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
