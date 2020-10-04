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

class PostItem {
  final String large;

  final String thumb;

  const PostItem({
    this.large,
    this.thumb,
  });
}

class Post {
  final String code;

  final int size;

  final bool disposable;

  final int users;

  final int comments;

  final List<PostItem> items;

  final List<int> types;

  final DateTime createTime;

  /// Create post object
  const Post({
    this.code,
    this.size,
    this.disposable,
    this.comments,
    this.users,
    this.items,
    this.types,
    this.createTime,
  });
}
