import 'package:spectrome/service/response.dart';

class PostAssetType {
  static const PHOTO = 1;
  static const VIDEO = 2;

  /// Get asset type from int value
  static int from(int value) {
    switch (value) {
      case PHOTO:
        return PHOTO;
      case VIDEO:
        return VIDEO;
      default:
        return null;
    }
  }
}

class PostAsset {
  final String name;

  final int type;

  final int duration;

  final String url;

  const PostAsset({
    this.name,
    this.type,
    this.duration,
    this.url,
  });
}

class Post {
  final String username;

  final List<PostAsset> assets;

  final List<String> tags;

  final int width;

  final int height;

  /// Create post object
  const Post({
    this.username,
    this.assets,
    this.tags,
    this.width,
    this.height,
  });
}

class PostResponse extends BasicResponse {
  Post post;

  /// Create empty object
  PostResponse.empty() : super.empty();

  /// Create only status and message
  PostResponse.bind({
    status,
    message,
  }) : super.bind(status: status, message: message);

  /// Create response by using JSON input
  PostResponse.fromJson(String input) {
    final json = super.fromJson(input);

    // Post assets callback
    final a = (Map<String, dynamic> a) {
      return new PostAsset(
        name: a['name'] as String,
        duration: a['duration'] ?? null,
        type: PostAssetType.from(a['type']),
      );
    };

    final p = json['p'] as Map<String, dynamic>;
    final assets = p['assets'] as List<Map<String, dynamic>>;

    post = new Post(
      username: p['username'] as String,
      assets: assets.map(a),
      tags: p['tags'] as List<String>,
      width: p['width'] as int,
      height: p['height'] as int,
    );
  }
}
