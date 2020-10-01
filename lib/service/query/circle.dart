import 'dart:developer' as dev;

import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CircleQueryService extends Service {
  static Future<CircleQueryResponse> call(String session, String query) {
    final path = '/query/circle';
    final headers = {Http.TOKEN_HEADER: session};
    final params = {'query': query};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CircleQueryResponse.bind(status: false, message: m);
      }

      return CircleQueryResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CircleQueryResponse.empty();

      dev.log('Circle query error.', error: e, stackTrace: s);

      return Service.handleError<CircleQueryResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      params: params,
      headers: headers,
    );

    return r.then(c).catchError(e);
  }
}

class CircleQueryResponse extends BasicResponse {
  // List of suggested users
  List<SimpleProfile> users;

  /// Create empty object
  CircleQueryResponse.empty() : super.empty();

  /// Create only status and message
  CircleQueryResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CircleQueryResponse.fromJson(String input) {
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
