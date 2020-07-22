import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class InviteService extends Service {
  /// Invite users by using e-mail address group
  static Future<InviteResponse> call(String session, List<String> emails) {
    final path = '/users/invite';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {'session': session, 'email': emails};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return InviteResponse.bind(status: false, message: m);
      }

      return InviteResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = InviteResponse.empty();

      dev.log('User invitation error.', error: e, stackTrace: s);

      return Service.handleError<InviteResponse>(e, s, r);
    };

    final post = Http.doPost(
      path: path,
      body: body,
      headers: headers,
      type: Http.FORM,
    );

    return post.then(c).catchError(e);
  }
}

class InviteResponse extends BasicResponse {
  /// Create empty object
  InviteResponse.empty() : super.empty();

  /// Create only status and message
  InviteResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  InviteResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
