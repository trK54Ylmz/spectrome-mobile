import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class LocationService extends Service {
  /// Check user session by using session code
  static Future<LocationResponse> call(String session, String country, String language) {
    final path = '/account/location';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {'country': country, 'language': language};

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return LocationResponse.bind(status: false, message: m);
      }

      return LocationResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = LocationResponse.empty();

      dev.log('Location update error.', error: e, stackTrace: s);

      return Service.handleError<LocationResponse>(e, s, r);
    };

    return Http.doPost(path, body: body, headers: headers).then(c).catchError(e);
  }
}

class LocationResponse extends BasicResponse {
  /// Create empty object
  LocationResponse.empty() : super.empty();

  /// Create only status and message
  LocationResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  LocationResponse.fromJson(String input) {
    super.fromJson(input);
  }
}
