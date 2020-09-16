import 'dart:developer' as dev;

import 'package:spectrome/model/comment/comment.dart';
import 'package:spectrome/model/comment/detail.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CommentRecentService extends Service {
  /// Get last 2 comments for the post
  static Future<CommentRecentResponse> call(String session, String code) {
    final path = '/comments/recent/$code';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CommentRecentResponse.bind(status: false, message: m);
      }

      return CommentRecentResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CommentRecentResponse.empty();

      dev.log('Comment recent error.', error: e, stackTrace: s);

      return Service.handleError<CommentRecentResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      headers: headers,
    );

    return r.then(c).catchError(e);
  }
}

class CommentRecentResponse extends BasicResponse {
  // List of comments
  List<CommentDetail> comments;

  /// Create empty object
  CommentRecentResponse.empty() : super.empty();

  /// Create only status and message
  CommentRecentResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CommentRecentResponse.fromJson(String input) {
    final json = super.fromJson(input);

    final cc = (Map<String, dynamic> i) {
      return new Comment(
        message: i['message'],
        createTime: DateTime.parse(i['create_time']),
      );
    };

    // Comment user callback
    final uc = (Map<String, dynamic> u) {
      return new SimpleProfile(
        name: u['name'],
        username: u['username'],
        photoUrl: u['photo_url'],
      );
    };

    // Comment callback
    final c = (Map<String, dynamic> i) {
      return new CommentDetail(
        me: i['me'] as bool,
        comment: cc(i['comment'] as Map<String, dynamic>),
        user: uc(i['comment'] as Map<String, dynamic>),
      );
    };

    if (json['comments'] == null) {
      comments = [];
    } else {
      final d = json['comments'] as List<dynamic>;

      comments = d.map((i) => c(i as Map<String, dynamic>)).toList();
    }
  }
}
