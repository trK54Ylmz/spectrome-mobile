import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Http {
  static const TOKEN_HEADER = 'x-authorization';

  static const CONTENT_HEADER = 'accept-encoding';

  static const FORM = 'application/x-www-form-urlencoded';

  static final client = new HttpClient();

  static String domain;

  /// Make a POST request to the remote server
  static Future<Response> doPost(
    String path, {
    Map<String, String> params,
    Map<String, String> headers,
    Map<String, String> body,
    String type,
  }) {
    final Uri url = new Uri.https(domain, path, params);

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

    return client.getUrl(url).then(c).then((r) => _toResponse(r));
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
