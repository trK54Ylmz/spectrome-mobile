import 'dart:developer' as dev;

import 'package:spectrome/model/comment/comment.dart';
import 'package:spectrome/model/comment/detail.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CommentAddService extends Service {
  /// Create new comment to selected post
  static Future<CommentAddResponse> call({
    String session,
    String code,
    String message,
  }) {
    final path = '/comments/history';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {
      'code': code,
      'message': message,
    };

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CommentAddResponse.bind(status: false, message: m);
      }

      return CommentAddResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CommentAddResponse.empty();

      dev.log('Comment create error.', error: e, stackTrace: s);

      return Service.handleError<CommentAddResponse>(e, s, r);
    };

    final r = Http.doPost(
      path: path,
      headers: headers,
      body: body,
      type: Http.FORM,
    );

    return r.then(c).catchError(e);
  }
}

class CommentAddResponse extends BasicResponse {
  // Created comment
  CommentDetail comment;

  /// Create empty object
  CommentAddResponse.empty() : super.empty();

  /// Create only status and message
  CommentAddResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CommentAddResponse.fromJson(String input) {
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
        user: uc(i['user'] as Map<String, dynamic>),
      );
    };

    if (json['comment'] != null) {
      comment = c(json['comment'] as Map<String, dynamic>);
    }
  }
}
