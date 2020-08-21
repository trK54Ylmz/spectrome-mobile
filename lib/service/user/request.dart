import 'dart:developer' as dev;

import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/model/user/intention.dart';
import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class IntentionService extends Service {
  /// Follow user by username
  static Future<IntentionResponse> call(String session) {
    final path = '/users/request';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return IntentionResponse.bind(status: false, message: m);
      }

      return IntentionResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = IntentionResponse.empty();

      dev.log('Follow intention error.', error: e, stackTrace: s);

      return Service.handleError<IntentionResponse>(e, s, r);
    };

    final post = Http.doGet(
      path: path,
      headers: headers,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class Request {
  final Intention intention;

  final SimpleProfile user;

  const Request({
    this.intention,
    this.user,
  });
}

class IntentionResponse extends BasicResponse {
  // List of intentions
  List<Request> intentions;

  /// Create empty object
  IntentionResponse.empty() : super.empty();

  /// Create only status and message
  IntentionResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  IntentionResponse.fromJson(String input) {
    final json = super.fromJson(input);

    final i = json['intentions'] as List<dynamic>;

    // List of intentions callback
    final c = (Map<String, dynamic> e) {
      final i = e['intention'] as Map<String, dynamic>;
      final u = e['user'] as Map<String, dynamic>;

      final intention = new Intention(
        code: i['code'],
        createTime: DateTime.parse(i['create_time']),
      );

      final user = new SimpleProfile(
        name: u['name'],
        username: u['username'],
        photoUrl: u['photo_url'],
      );

      return new Request(
        intention: intention,
        user: user,
      );
    };

    intentions = i.map((e) => c(e as Map<String, dynamic>)).toList();
  }
}
