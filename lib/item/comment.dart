import 'package:flutter/cupertino.dart';
import 'package:spectrome/model/post/comment.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/date.dart';
import 'package:spectrome/util/http.dart';

class CommentRow extends StatefulWidget {
  // User profile
  final SimpleProfile user;

  // Comment instance
  final Comment comment;

  // Session header
  final String session;

  // Am I comment owner
  final bool me;

  const CommentRow({
    this.comment,
    this.user,
    this.session,
    this.me,
  });

  _CommentRowState createState() => new _CommentRowState();
}

class _CommentRowState extends State<CommentRow> {
  @override
  Widget build(BuildContext context) {
    // Http headers for profile image request
    final h = {Http.TOKEN_HEADER: widget.session};

    // Comment owner profile photo
    final pp = new GestureDetector(
      onTap: () => null,
      child: new Container(
        width: 30.0,
        height: 30.0,
        decoration: new BoxDecoration(
          color: ColorConst.gray,
          border: new Border.all(
            width: 0.5,
            color: ColorConst.gray.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        child: new ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: new Image.network(
            widget.user.photoUrl,
            headers: h,
            width: 30.0,
            height: 30.0,
            errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
          ),
        ),
      ),
    );

    // Comment owner username
    final pt = new Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: new Text(
        widget.user.username,
        style: new TextStyle(
          fontFamily: FontConst.bold,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: ColorConst.black,
        ),
      ),
    );

    // Comment create time
    final ct = new Text(
      DateTimes.diff(DateTime.now(), widget.comment.createTime),
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 12.0,
        letterSpacing: 0.33,
        color: ColorConst.darkGray,
      ),
    );

    final pr = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        pt,
        ct,
      ],
    );

    // Comment message
    final ms = new Padding(
      padding: EdgeInsets.only(top: 2.0),
      child: new Semantics(
        focusable: true,
        button: true,
        child: new GestureDetector(
          child: new Text(
            widget.comment.message,
            style: new TextStyle(
              fontFamily: FontConst.primary,
              fontSize: 14.0,
              letterSpacing: 0.33,
              color: ColorConst.black,
            ),
          ),
        ),
      ),
    );

    final col = new Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          pr,
          ms,
        ],
      ),
    );

    return new Padding(
      padding: EdgeInsets.all(10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          pp,
          col,
        ],
      ),
    );
  }
}
