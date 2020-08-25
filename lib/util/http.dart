import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class Http {
  static const TOKEN_HEADER = 'x-authorization';

  static const ACCEPT_HEADER = 'accept-encoding';

  static const CONTENT_HEADER = 'content-type';

  static const FORM = 'application/x-www-form-urlencoded; charset=utf-8';

  static const MULTIPART = 'multipart/form-data; charset=utf-8';

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
        Http.ACCEPT_HEADER: 'gzip',
      };
    } else {
      headers[Http.ACCEPT_HEADER] = 'gzip';
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
            r.headers.add(Http.CONTENT_HEADER, JSON);
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
        Http.ACCEPT_HEADER: 'gzip',
      };
    } else {
      headers[Http.ACCEPT_HEADER] = 'gzip';
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
            r.headers.add(Http.CONTENT_HEADER, FORM);
            break;
          case MULTIPART:
            r.headers.add(Http.CONTENT_HEADER, MULTIPART);
            break;
        }
      }

      // Add form data if body selected
      if (body != null) {
        // Prepare multipart form
        if (type == Http.MULTIPART) {
          // Remove plain multipart header
          r.headers.removeAll(Http.CONTENT_HEADER);

          // Create boundry header
          final a = new DateTime.now().toString();
          final b = new DateTime.now().millisecondsSinceEpoch;
          final hash = md5.convert(utf8.encode(a)).toString();
          final boundry = '$hash-$b';
          final header = '${Http.MULTIPART}; boundary=$boundry';

          // Set multipart header
          r.headers.add(Http.CONTENT_HEADER, header);

          for (var key in body.keys) {
            // Write start header
            r.write('--$boundry\n');

            if (body[key] is File) {
              final file = body[key] as File;

              // Get file name
              final name = file.path.split('/').last.replaceAll('"', '\\"');

              final ft = name.split('.').last;

              // Only mp4 and jpg allowed
              if (!['mp4', 'jpg'].contains(ft)) {
                continue;
              }

              final type = ft == 'mp4' ? 'image/mp4' : 'image/jpeg';

              r.write('Content-Disposition: form-data; name="$key"; filename="$name"\n');
              r.write('Content-Type: $type\n');
              r.write('\n');

              // Open file for read
              final fr = file.openSync();

              final bs = 4096;
              final size = file.lengthSync();

              int position = 0;

              // Iterate through the file write to response stream
              while (position < size) {
                final bytes = fr.readSync(bs);
                r.add(bytes);

                // Update current position of the reader
                position = fr.positionSync();
              }

              fr.closeSync();

              r.write('\n');
            } else {
              final v = body[key] is bool ? body[key] ? 1 : 0 : body[key];
              
              // Write plain text data
              r.write('Content-Disposition: form-data; name="$key"\n');
              r.write('\n');
              r.write(v.toString());
              r.write('\n');
            }
          }

          // Write final ending boundry
          r.write('--$boundry--');
        } else {
          // Plain form data
          final form = <String>[];
          for (var key in body.keys) {
            // Ignore multipart file types
            if (body[key] is File) {
              continue;
            }

            final k = Uri.encodeQueryComponent(key);

            if (body[key] is List) {
              int i = 0;

              // Iterate over list params
              for (var value in body[key] as List) {
                final v = value is bool ? value ? 1 : 0 : value;

                form.add('$k-$i=$v');
                i++;
              }
            } else {
              final v = Uri.encodeQueryComponent(body[key].toString());
              form.add('$k=$v');
            }
          }

          r.write(form.join('&'));
        }
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

class DebugHttpOverrides extends HttpOverrides {
  /// Override current http client
  @override
  HttpClient createHttpClient(SecurityContext context) {
    Http.client.badCertificateCallback = (c, h, p) => true;

    return Http.client;
  }
}

class Response {
  Response(this.code, this.body, this.headers);

  final int code;

  final String body;

  final Map<String, String> headers;
}
