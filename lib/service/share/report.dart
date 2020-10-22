import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class ShareReportService extends Service {
  /// Send fail report of post
  static Future<ShareReportResponse> call({String session, String code}) {
    final path = '/shares/report/$code';
    final headers = {Http.TOKEN_HEADER: session};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return ShareReportResponse.bind(status: false, message: m);
      }

      return ShareReportResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = ShareReportResponse.empty();

      dev.log('Share report error.', error: e, stackTrace: s);

      return Service.handleError<ShareReportResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      headers: headers,
      type: Http.JSON,
    );

    return r.then(c).catchError(e);
  }
}

class ShareReportResponse extends BasicResponse {
  /// Create empty object
  ShareReportResponse.empty() : super.empty();

  /// Create only status and message
  ShareReportResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  ShareReportResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
