import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class ShareStatusService extends Service {
  /// Get status of post creation
  static Future<ShareStatusResponse> call({String session, String code}) {
    final path = '/share/status/$code';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return ShareStatusResponse.bind(status: false, message: m);
      }

      return ShareStatusResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = ShareStatusResponse.empty();

      dev.log('Share status error.', error: e, stackTrace: s);

      return Service.handleError<ShareStatusResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      headers: headers,
      type: Http.JSON,
    );

    return r.then(c).catchError(e);
  }
}

class ShareStatusResponse extends BasicResponse {
  // Is this last state or not
  bool done;

  // Last state is failed or not
  bool failed;

  // State of the progress
  String state;

  /// Create empty object
  ShareStatusResponse.empty() : super.empty();

  /// Create only status and message
  ShareStatusResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  ShareStatusResponse.fromJson(String input) {
    final json = super.fromJson(input);

    done = json['done'] ?? null;
    failed = json['failed'] ?? null;
    state = json['state'] ?? null;
  }
}
