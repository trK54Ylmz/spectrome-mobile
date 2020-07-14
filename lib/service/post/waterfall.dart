import 'dart:developer' as dev;

import 'package:spectrome/service/base.dart';
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

    final post = Http.doPost(path, body: body, headers: headers, type: Http.FORM);

    return post.then(c).catchError(e);
  }
}

class Post {
  final String username;

  final String photoUrl;

  final List<String> tags;

  /// Create post object
  const Post({
    this.username,
    this.photoUrl,
    this.tags,
  });
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

      // Post creator callback
      final c = (Map<String, dynamic> p) {
        return new Post(
          username: p['username'] as String,
          photoUrl: p['photo_url'] as String,
          tags: p['tags'] as List<String>,
        );
      };

      // Create posts
      posts = p.map(c);
    }
  }
}