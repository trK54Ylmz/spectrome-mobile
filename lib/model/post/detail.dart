import 'package:spectrome/model/post/post.dart';
import 'package:spectrome/model/profile/simple.dart';

class PostDetail {
  final Post post;

  final SimpleProfile user;

  final List<SimpleProfile> users;

  const PostDetail({
    this.post,
    this.user,
    this.users,
  });
}
