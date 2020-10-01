import 'package:spectrome/model/post/post.dart';

class CommentHistory {
  final String username;

  final Post post;

  const CommentHistory({
    this.username,
    this.post,
  });
}
