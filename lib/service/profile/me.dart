import 'dart:developer' as dev;

import 'package:spectrome/model/profile/me.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class MyProfileService extends Service {
  /// Get my profile by using session code
  static Future<MyProfileResponse> call(String session) {
    final path = '/profile/user/me';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return MyProfileResponse.bind(status: false, message: m);
      }

      return MyProfileResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = MyProfileResponse.empty();

      dev.log('Get my profile error.', error: e, stackTrace: s);

      return Service.handleError<MyProfileResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      headers: headers,
      type: Http.JSON,
    );

    return r.then(c).catchError(e);
  }
}

class MyProfileResponse extends BasicResponse {
  MyProfile profile;

  /// Create empty object
  MyProfileResponse.empty() : super.empty();

  /// Create only status and message
  MyProfileResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  MyProfileResponse.fromJson(String input) {
    final json = super.fromJson(input);

    final p = json['user'] as Map<String, dynamic>;

    profile = new MyProfile(
      username: p['username'] as String,
      name: p['name'] as String,
      photoUrl: p['photo_url'] as String,
      posts: p['posts'] as int,
      circles: p['circles'] as int,
    );
  }
}
