import 'package:spectrome/model/comment/comment.dart';
import 'package:spectrome/model/profile/simple.dart';

class CommentDetail {
  final bool me;

  final Comment comment;

  final SimpleProfile user;

  const CommentDetail({
    this.me,
    this.comment,
    this.user,
  });
}
