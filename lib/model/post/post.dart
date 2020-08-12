import 'package:spectrome/util/const.dart';

class PostAssetType {
  static const PHOTO = AppConst.photo;
  static const VIDEO = AppConst.video;

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

  final String url;

  const PostAsset({
    this.name,
    this.type,
    this.url,
  });
}

class Post {
  final String username;

  final List<PostAsset> assets;

  final int width;

  final int height;

  /// Create post object
  const Post({
    this.username,
    this.assets,
    this.width,
    this.height,
  });
}
