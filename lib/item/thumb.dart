import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spectrome/item/photo.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/page/detail.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/http.dart';

class PostThumbCard extends StatefulWidget {
  // Account session key
  final String session;

  // Post item
  final PostDetail detail;

  PostThumbCard({
    Key key,
    this.session,
    this.detail,
  });

  @override
  _PostThumbState createState() => new _PostThumbState();
}

class _PostThumbState extends State<PostThumbCard> {
  @override
  Widget build(BuildContext context) {
    final c = () async {
      await Navigator.of(context).pushNamed(DetailPage.tag, arguments: widget.detail);
    };

    // Create post widget by number of posts
    if (widget.detail.post.items.length == 1) {
      final type = widget.detail.post.types[0];

      final p = type == AppConst.video ? _getVideo(0) : _getPhoto(0);

      return new GestureDetector(
        onTap: c,
        child: p,
      );
    }

    final items = <Widget>[];
    for (int i = 0; i < min(widget.detail.post.items.length, 3); i++) {
      final type = widget.detail.post.types[i];

      if (type == AppConst.video) {
        // Add photo widget
        items.add(_getVideo(i));
      } else if (type == AppConst.photo) {
        // Add video widget
        items.add(_getPhoto(i));
      } else {
        dev.log('Invalid item type $type.');
      }
    }

    final clipped = <Widget>[];

    if (items.length == 2) {
      final i = new Expanded(
        child: new Padding(
          padding: EdgeInsets.only(left: 0.5),
          child: items[1],
        ),
      );

      clipped.add(i);
    } else {
      final ii = new Expanded(
        child: new Padding(
          padding: EdgeInsets.only(left: 0.5),
          child: items[1],
        ),
      );

      clipped.add(ii);

      final ij = new Expanded(
        child: items[2],
      );

      clipped.add(ij);
    }

    return new GestureDetector(
      onTap: c,
      child: new Container(
        width: 400,
        height: 400,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Expanded(
              child: new Padding(
                padding: EdgeInsets.only(right: 0.5),
                child: items[0],
              ),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: clipped,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get photo widget
  Widget _getPhoto(int index) {
    // Http headers for image request
    final h = {Http.TOKEN_HEADER: widget.session};

    return new Photo(
      key: new ValueKey(widget.detail.post.items[index].thumb),
      url: widget.detail.post.items[index].thumb,
      headers: h,
      width: 400.0,
      height: 400.0,
      fit: BoxFit.fitHeight,
    );
  }

  /// Get video widget
  Widget _getVideo(int index) {
    // Http headers for image request
    final h = {Http.TOKEN_HEADER: widget.session};

    return new Photo(
      key: new ValueKey(widget.detail.post.items[index].thumb),
      url: widget.detail.post.items[index].thumb,
      headers: h,
      width: 400.0,
      height: 400.0,
      fit: BoxFit.fitHeight,
    );
  }
}
