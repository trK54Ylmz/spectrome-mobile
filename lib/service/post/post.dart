import 'package:spectrome/model/post/post.dart';
import 'package:spectrome/service/response.dart';

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
        type: PostAssetType.from(a['type']),
      );
    };

    final p = json['p'] as Map<String, dynamic>;
    final assets = p['assets'] as List<Map<String, dynamic>>;

    post = new Post(
      username: p['username'] as String,
      assets: assets.map(a),
      width: p['width'] as int,
      height: p['height'] as int,
    );
  }
}
