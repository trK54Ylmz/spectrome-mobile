import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class VersionService extends Service {
  /// Get system version
  static Future<VersionResponse> call() {
    final path = '/system/version';

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return VersionResponse.bind(status: false, message: m);
      }

      return VersionResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = VersionResponse.empty();

      dev.log('Version error.', error: e, stackTrace: s);

      return Service.handleError<VersionResponse>(e, s, r);
    };

    return Http.doGet(path, type: Http.JSON).then(c).catchError(e);
  }
}


class VersionResponse extends BasicResponse {
  String version;

  /// Create empty object
  VersionResponse.empty() : super.empty();

  /// Create only status and message
  VersionResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  VersionResponse.fromJson(String input) {
    final json = super.fromJson(input);

    version = json['version'] ?? null;
  }
}