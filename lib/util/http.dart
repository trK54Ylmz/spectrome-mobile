import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:spectrome/util/device.dart';

class Http {
  static final _client = new HttpClient();

  static const TOKEN_HEADER = 'x-authorization';

  static const CONTENT_HEADER = 'accept-encoding';

  static const FORM = 'application/x-www-form-urlencoded';

  static String _domain;

  /// Initialize domain name according to device type
  ///
  /// Local environment ignores ssl verification
  static Future<Null> init() {
    if (_domain != null) {
      new Future.value(null);
    }

    final c = (bool isDevice) {
      _domain = isDevice ? 'api.spectrome.app' : 'localhost';

      /// Bypass ssl verification at test
      if (!isDevice) {
        _client.badCertificateCallback = (c, h, p) => true;
      }

      return null;
    };

    return Device.isDevice().then(c);
  }

  /// Make a POST request to the remote server
  static Future<Response> doPost(
    String path, {
    Map<String, String> params,
    Map<String, String> headers,
    Map<String, String> body,
    String type,
  }) {
    final Uri url = new Uri.https(_domain, path, params);

    // Http request and response callback
    final c = (HttpClientRequest r) {
      // Update request headers if headers parameter is present
      if (headers != null && headers.isNotEmpty) {
        for (String k in headers.keys) {
          r.headers.add(k, headers[k]);
        }
      }

      // Add http request content type header
      if (type != null) {
        switch (type) {
          case FORM:
            r.headers.add(HttpHeaders.contentTypeHeader, FORM);
            break;
        }
      }

      // Send request and close remote connection
      return r.close();
    };

    return _client.getUrl(url).then(c).then((r) => _toResponse(r));
  }

  /// Convert [HttpClientResponse] to Spectrome [HttpResponse] object
  ///
  /// Uses stream processing
  static Future<Response> _toResponse(HttpClientResponse res) {
    final Map<String, String> headers = new Map();

    res.headers.forEach((f, s) => headers[f] = s[0]);

    return res.transform(utf8.decoder).join().then((content) {
      return Response(res.statusCode, content, headers);
    });
  }
}

class Response {
  Response(this.code, this.body, this.headers);

  final int code;

  final String body;

  final Map<String, String> headers;
}
