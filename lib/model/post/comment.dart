import 'package:spectrome/model/profile/simple.dart';

class Comment {
  final String message;

  final DateTime createTime;

  const Comment({
    this.message,
    this.createTime,
  });
}

class CommentDetail {
  final Comment comment;

  final SimpleProfile user;

  const CommentDetail({
    this.comment,
    this.user,
  });
}
