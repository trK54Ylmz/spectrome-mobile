import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class IntentionSeenService extends Service {
  /// Set requests as seen by using session code
  static Future<IntentionSeenResponse> call(String session) {
    final path = '/users/request/seen';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        try {
          return IntentionSeenResponse.fromJson(r.body);
        } catch (FormatException) {
          final m = 'An error occurred';
          return IntentionSeenResponse.bind(status: false, message: m);
        }
      }

      return IntentionSeenResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = IntentionSeenResponse.empty();

      dev.log('Circle intention seen error.', error: e, stackTrace: s);

      return Service.handleError<IntentionSeenResponse>(e, s, r);
    };

    final post = Http.doPost(
      path: path,
      headers: headers,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class IntentionSeenResponse extends BasicResponse {
  /// Create empty object
  IntentionSeenResponse.empty() : super.empty();

  /// Create only status and message
  IntentionSeenResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  IntentionSeenResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
