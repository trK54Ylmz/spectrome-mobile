import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Http {
  static const TOKEN_HEADER = 'x-authorization';

  static const CONTENT_HEADER = 'accept-encoding';

  static const FORM = 'application/x-www-form-urlencoded; charset=utf-8';

  static const JSON = 'application/json; charset=utf-8';

  static final client = new HttpClient();

  static final gzip = new GZipCodec();

  static String domain;

  /// Make a GET request to the remote server
  static Future<Response> doGet({
    String path,
    Map<String, String> params,
    Map<String, String> headers,
    String type,
    Duration timeout,
  }) {
    assert(path != null);

    final Uri url = new Uri.https(domain, path, params);

    // Add gzip header
    if (headers == null) {
      headers = {
        Http.CONTENT_HEADER: 'gzip',
      };
    } else {
      headers[Http.CONTENT_HEADER] = 'gzip';
    }

    // Http request and response callback
    final c = (HttpClientRequest r) {
      // Update request headers if headers parameter is present
      for (String k in headers.keys) {
        r.headers.add(k, headers[k]);
      }

      // Add http request content type header
      if (type != null) {
        switch (type) {
          case JSON:
            r.headers.add(HttpHeaders.contentTypeHeader, JSON);
            break;
        }
      }

      // Send request and close remote connection
      return r.close();
    };

    final t = timeout == null ? Duration(seconds: 10) : timeout;
    return client.getUrl(url).timeout(t).then(c).then((r) => _toResponse(r));
  }

  /// Make a POST request to the remote server
  static Future<Response> doPost({
    String path,
    Map<String, String> params,
    Map<String, String> headers,
    Map<String, dynamic> body,
    String type,
    Duration timeout,
  }) {
    assert(path != null);

    final Uri url = new Uri.https(domain, path, params);

    // Add gzip header
    if (headers == null) {
      headers = {
        Http.CONTENT_HEADER: 'gzip',
      };
    } else {
      headers[Http.CONTENT_HEADER] = 'gzip';
    }

    // Http request and response callback
    final c = (HttpClientRequest r) {
      // Update request headers if headers parameter is present
      for (String k in headers.keys) {
        r.headers.add(k, headers[k]);
      }

      // Add http request content type header
      if (type != null) {
        switch (type) {
          case FORM:
            r.headers.add(HttpHeaders.contentTypeHeader, FORM);
            break;
        }
      }

      // Add form data if body selected
      if (body != null) {
        final form = <String>[];
        for (var key in body.keys) {
          final k = Uri.encodeQueryComponent(key);

          if (body[key] is List) {
            int i = 0;

            // Iterate over list params
            for (var v in body[key] as List) {
              form.add('$k-$i=$v');
              i++;
            }
          } else {
            final v = Uri.encodeQueryComponent(body[key]);
            form.add('$k=$v');
          }
        }

        r.write(form.join('&'));
      }

      // Send request and close remote connection
      return r.close();
    };

    final t = timeout == null ? Duration(seconds: 10) : timeout;
    return client.postUrl(url).timeout(t).then(c).then((r) => _toResponse(r));
  }

  /// Convert [HttpClientResponse] to Spectrome [HttpResponse] object
  ///
  /// Uses stream processing
  static Future<Response> _toResponse(HttpClientResponse res) {
    final Map<String, String> headers = new Map();

    res.headers.forEach((f, s) => headers[f.toLowerCase()] = s[0]);

    bool gzip = false;
    if (headers.containsKey('content-encoding')) {
      gzip = headers['content-encoding'] == 'gzip';
    }

    // Decode gzip encoding
    final t = gzip ? res.transform(Http.gzip.decoder) : res;

    return t.transform(utf8.decoder).join().then((content) {
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
