import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class TermService extends Service {
  /// Get terms and conditions
  static Future<TermResponse> call() {
    final path = '/system/term';

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return TermResponse.bind(status: false, message: m);
      }

      return TermResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = TermResponse.empty();

      dev.log('Version error.', error: e, stackTrace: s);

      return Service.handleError<TermResponse>(e, s, r);
    };

    final r = Http.doGet(
      path: path,
      type: Http.JSON,
    );

    return r.then(c).catchError(e);
  }
}

class TermResponse extends BasicResponse {
  // Items of the terms
  List<MapEntry<String, String>> items;

  /// Create empty object
  TermResponse.empty() : super.empty();

  /// Create only status and message
  TermResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  TermResponse.fromJson(String input) {
    final json = super.fromJson(input);

    if (json['items'] == null) {
      items = [];
    } else {
      final i = json['items'] as List<dynamic>;

      // Item callback
      final c = (Map<String, dynamic> item) {
        final key = item.keys.first;
        final value = item[key].toString();

        return new MapEntry(key, value);
      };

      // Create list of items
      items = i.map((e) => c(e as Map<String, dynamic>)).toList();
    }
  }
}
