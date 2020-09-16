import 'dart:developer' as dev;

import 'package:spectrome/model/comment/comment.dart';
import 'package:spectrome/model/comment/detail.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class CommentHistoryService extends Service {
  /// Get comment history by post code and timestamp
  static Future<CommentHistoryResponse> call({
    String session,
    String code,
    String timestamp,
  }) {
    final path = '/comments/history';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {
      'code': code,
    };

    // Add timestamp iterator if presents
    if (timestamp != null) {
      body['timestamp'] = timestamp.toString();
    }

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return CommentHistoryResponse.bind(status: false, message: m);
      }

      return CommentHistoryResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = CommentHistoryResponse.empty();

      dev.log('Comment history error.', error: e, stackTrace: s);

      return Service.handleError<CommentHistoryResponse>(e, s, r);
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

class CommentHistoryResponse extends BasicResponse {
  // List of comments
  List<CommentDetail> comments;

  /// Create empty object
  CommentHistoryResponse.empty() : super.empty();

  /// Create only status and message
  CommentHistoryResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  CommentHistoryResponse.fromJson(String input) {
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

    if (json['comments'] == null) {
      comments = [];
    } else {
      final d = json['comments'] as List<dynamic>;

      comments = d.map((i) => c(i as Map<String, dynamic>)).toList();
    }
  }
}
