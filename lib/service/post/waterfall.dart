import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
import 'package:spectrome/service/post/post.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/util/http.dart';

class WaterFallService extends Service {
  /// Get waterfall posts
  static Future<WaterFallResponse> call(String session, double timestamp) {
    final path = '/posts/waterfall';
    final headers = {Http.TOKEN_HEADER: session};
    final body = {'session': session};

    // Add timestamp iterator if presents
    if (timestamp != null) {
      body['timestamp'] = timestamp.toString();
    }

    // Http response handle callback
    final c = (Response r) {
      if (r.code != 200) {
        final m = 'An error occurred';
        return WaterFallResponse.bind(status: false, message: m);
      }

      return WaterFallResponse.fromJson(r.body);
    };

    // Handle error case
    final e = (e, StackTrace s) {
      final r = WaterFallResponse.empty();

      dev.log('Waterfall posts error.', error: e, stackTrace: s);

      return Service.handleError<WaterFallResponse>(e, s, r);
    };

    final r = Http.doPost(
      path: path,
      body: body,
      headers: headers,
      type: Http.FORM,
    );

    return r.then(c).catchError(e);
  }
}

class WaterFallResponse extends BasicResponse {
  List<Post> posts;

  /// Create empty object
  WaterFallResponse.empty() : super.empty();

  /// Create only status and message
  WaterFallResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  WaterFallResponse.fromJson(String input) {
    final json = super.fromJson(input);

    if (json['posts'] == null) {
      posts = [];
    } else {
      final p = json['posts'] as List<Map<String, dynamic>>;

      // Post assets callback
      final a = (Map<String, dynamic> a) {
        return new PostAsset(
          name: a['name'] as String,
          duration: a['duration'] ?? null,
          type: PostAssetType.from(a['type']),
        );
      };

      // Post creator callback
      final c = (Map<String, dynamic> p) {
        final assets = p['assets'] as List<Map<String, dynamic>>;

        return new Post(
          username: p['username'] as String,
          assets: assets.map(a),
          tags: p['tags'] as List<String>,
          width: p['width'] as int,
          height: p['height'] as int,
        );
      };

      // Create posts
      posts = p.map(c);
    }
  }
}
