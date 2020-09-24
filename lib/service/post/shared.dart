import 'dart:developer' as dev;

import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/model/post/post.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class UserSharedPostService extends Service {
  /// Get user posts by given username
  static Future<UserSharedPostResponse> call({
    String session,
    String username,
    String timestamp,
  }) {
    final path = '/posts/user/$username';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {'session': session};

    // Add timestamp iterator if presents
    if (timestamp != null) {
      body['timestamp'] = timestamp.toString();
    }

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return UserSharedPostResponse.bind(status: false, message: m);
      }

      return UserSharedPostResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = UserSharedPostResponse.empty();

      dev.log('User posts error.', error: e, stackTrace: s);

      return Service.handleError<UserSharedPostResponse>(e, s, r);
    };

    final r = Http.doPost(
      path: path,
      body: body,
      headers: headers,
      type: Http.FORM,
    );

    return r.then(c).catchError(e);
  }
}

class UserSharedPostResponse extends BasicResponse {
  // List of posts
  List<PostDetail> posts;

  /// Create empty object
  UserSharedPostResponse.empty() : super.empty();

  /// Create only status and message
  UserSharedPostResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  UserSharedPostResponse.fromJson(String input) {
    final json = super.fromJson(input);

    if (json['posts'] == null) {
      posts = [];
    } else {
      final p = json['posts'] as List<dynamic>;

      // Post assets callback
      final u = (Map<String, dynamic> u) {
        return new SimpleProfile(
          name: u['name'],
          username: u['username'],
          photoUrl: u['photo_url'],
        );
      };

      // Post item callback
      final i = (Map<String, dynamic> i) {
        return new PostItem(
          large: i['large'],
          thumb: i['thumb'],
        );
      };

      // Post creator callback
      final c = (Map<String, dynamic> p) {
        final me = p['me'] as bool;
        final ps = p['post'] as Map<String, dynamic>;
        final us = p['user'] as Map<String, dynamic>;
        final ul = p['users'] as List<dynamic>;

        final t = ps['types'] as List<dynamic>;
        final l = ps['items'] as List<dynamic>;

        // Post detail
        final post = new Post(
          code: ps['code'],
          size: ps['size'] as int,
          disposible: ps['disposible'] as bool,
          users: ps['number_of_users'] as int,
          comments: ps['number_of_comments'] as int,
          createTime: DateTime.parse(ps['create_time']),
          types: t.map((e) => e as int).toList(),
          items: l.map((e) => i(e as Map<String, dynamic>)).toList(),
        );

        // Post owner details
        final user = new SimpleProfile(
          name: us['name'],
          username: us['username'],
          photoUrl: us['photo_url'],
        );

        // Restricted users
        final users = ul.map((e) => u(e as Map<String, dynamic>)).toList();

        return new PostDetail(
          me: me,
          post: post,
          user: user,
          users: users,
        );
      };

      // Create posts
      posts = p.map((i) => c(i as Map<String, dynamic>)).toList();
    }
  }
}
