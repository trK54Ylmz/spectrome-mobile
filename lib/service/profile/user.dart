import 'dart:developer' as dev;

import 'package:spectrome/model/profile/user.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class UserProfileService extends Service {
  /// Get user profile by using session code and username
  static Future<UserProfileResponse> call(String session, String username) {
    final path = '/profile/user/$username';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return UserProfileResponse.bind(status: false, message: m);
      }

      return UserProfileResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = UserProfileResponse.empty();

      dev.log('Get user profile error.', error: e, stackTrace: s);

      return Service.handleError<UserProfileResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      headers: headers,
    );

    return r.then(c).catchError(e);
  }
}

class UserProfileResponse extends BasicResponse {
  // User profile details
  UserProfile profile;

  // User is in circle
  bool circle;

  // User circle request sent
  bool request;

  /// Create empty object
  UserProfileResponse.empty() : super.empty();

  /// Create only status and message
  UserProfileResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  UserProfileResponse.fromJson(String input) {
    final json = super.fromJson(input);

    circle = json['circle'] ?? false;
    request = json['request'] ?? false;

    final p = json['user'] as Map<String, dynamic>;

    if (p != null) {
      profile = new UserProfile(
        username: p['username'] as String,
        name: p['name'] as String,
        photoUrl: p['photo_url'] as String,
        posts: p['posts'] as int,
        circles: p['circles'] as int,
      );
    }
  }
}
