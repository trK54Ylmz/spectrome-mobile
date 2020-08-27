import 'dart:developer' as dev;

import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/model/post/post.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class PostDetailService extends Service {
  /// Get detail of selected post
  static Future<PostDetailResponse> call(String session, String code) {
    final path = '/posts/post/$code';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {'session': session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return PostDetailResponse.bind(status: false, message: m);
      }

      return PostDetailResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = PostDetailResponse.empty();

      dev.log('Post detail error.', error: e, stackTrace: s);

      return Service.handleError<PostDetailResponse>(e, s, r);
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

class PostDetailResponse extends BasicResponse {
  // Detail of post
  PostDetail post;

  /// Create empty object
  PostDetailResponse.empty() : super.empty();

  /// Create only status and message
  PostDetailResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  PostDetailResponse.fromJson(String input) {
    final json = super.fromJson(input);

    if (json['post'] != null) {
      final p = json['post'] as Map<String, dynamic>;

      // Post assets callback
      final u = (Map<String, dynamic> u) {
        return new SimpleProfile(
          name: u['name'],
          username: u['username'],
          photoUrl: u['photo_url'],
        );
      };

      // Post item callback
      final i = (Map<String,dynamic> i) {
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
          restricted: ps['restricted'] as bool,
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
      post = c(p);
    }
  }
}