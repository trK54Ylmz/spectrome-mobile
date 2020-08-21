import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class IntentionCountService extends Service {
  /// Get follow requuest count by using session code
  static Future<IntentionCountResponse> call(String session) {
    final path = '/users/request/count';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        try {
          return IntentionCountResponse.fromJson(r.body);
        } catch (FormatException) {
          final m = 'An error occurred';
          return IntentionCountResponse.bind(status: false, message: m);
        }
      }

      return IntentionCountResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = IntentionCountResponse.empty();

      dev.log('Follow intention count error.', error: e, stackTrace: s);

      return Service.handleError<IntentionCountResponse>(e, s, r);
    };

    final post = Http.doGet(
      path: path,
      headers: headers,
    );

    return post.then(c).catchError(e);
  }
}

class IntentionCountResponse extends BasicResponse {
  // Number of unseen requests
  int count;

  /// Create empty object
  IntentionCountResponse.empty() : super.empty();

  /// Create only status and message
  IntentionCountResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  IntentionCountResponse.fromJson(String input) {
    final json = super.fromJson(input);

    count = json['count'] ?? 0;
  }
}
