import 'dart:developer' as dev;

import 'package:spectrome/model/history/comment.dart';
import 'package:spectrome/model/post/post.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class HistoryCommentService extends Service {
  /// Get comment history
  static Future<HistoryCommentResponse> call(String session, String timestamp) {
    final path = '/histories/comment';
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
        return HistoryCommentResponse.bind(status: false, message: m);
      }

      return HistoryCommentResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = HistoryCommentResponse.empty();

      dev.log('Comment history error.', error: e, stackTrace: s);

      return Service.handleError<HistoryCommentResponse>(e, s, r);
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

class HistoryCommentResponse extends BasicResponse {
  // List of comment history
  List<CommentHistory> posts;

  /// Create empty object
  HistoryCommentResponse.empty() : super.empty();

  /// Create only status and message
  HistoryCommentResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  HistoryCommentResponse.fromJson(String input) {
    final json = super.fromJson(input);

    if (json['posts'] == null) {
      posts = [];
    } else {
      final p = json['posts'] as List<dynamic>;

      // Post item callback
      final i = (Map<String, dynamic> i) {
        return new PostItem(
          large: i['large'],
          thumb: i['thumb'],
        );
      };

      // Post creator callback
      final c = (Map<String, dynamic> p) {
        final username = p['username'] as String;
        final ps = p['post'] as Map<String, dynamic>;

        final t = ps['types'] as List<dynamic>;
        final l = ps['items'] as List<dynamic>;

        // Post detail
        final post = new Post(
          code: ps['code'],
          size: ps['size'] as int,
          disposable: ps['disposable'] as bool,
          users: ps['number_of_users'] as int,
          comments: ps['number_of_comments'] as int,
          createTime: DateTime.parse(ps['create_time']),
          types: t.map((e) => e as int).toList(),
          items: l.map((e) => i(e as Map<String, dynamic>)).toList(),
        );

        return new CommentHistory(
          post: post,
          username: username,
        );
      };

      // Create posts
      posts = p.map((i) => c(i as Map<String, dynamic>)).toList();
    }
  }
}
