import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class IntentionCancelService extends Service {
  /// Cancel user follow request by username
  static Future<IntentionCancelResponse> call(String session, String username) {
    final path = '/users/cancel/p/$username';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return IntentionCancelResponse.bind(status: false, message: m);
      }

      return IntentionCancelResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = IntentionCancelResponse.empty();

      dev.log('User intention cancel error.', error: e, stackTrace: s);

      return Service.handleError<IntentionCancelResponse>(e, s, r);
    };

    final post = Http.doPost(
      path: path,
      headers: headers,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class IntentionCancelResponse extends BasicResponse {
  /// Create empty object
  IntentionCancelResponse.empty() : super.empty();

  /// Create only status and message
  IntentionCancelResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  IntentionCancelResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
