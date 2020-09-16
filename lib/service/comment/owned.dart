import 'dart:developer' as dev;

import 'package:spectrome/model/comment/comment.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CommentOwnedService extends Service {
  /// Get owned comment of post
  static Future<CommentOwnedResponse> call(String session, String code) {
    final path = '/comments/owned/$code';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CommentOwnedResponse.bind(status: false, message: m);
      }

      return CommentOwnedResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CommentOwnedResponse.empty();

      dev.log('Comment owned error.', error: e, stackTrace: s);

      return Service.handleError<CommentOwnedResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      headers: headers,
    );

    return r.then(c).catchError(e);
  }
}

class CommentOwnedResponse extends BasicResponse {
  // Owned comment result
  Comment comment;

  /// Create empty object
  CommentOwnedResponse.empty() : super.empty();

  /// Create only status and message
  CommentOwnedResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CommentOwnedResponse.fromJson(String input) {
    final json = super.fromJson(input);

    // Comment callback
    final c = (Map<String, dynamic> i) {
      return new Comment(
        message: i['message'],
        createTime: DateTime.parse(i['create_time']),
      );
    };

    if (json['comment'] != null) {
      comment = c(json['comment']);
    }
  }
}
