import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/http.dart';

class PostCard extends StatefulWidget {
  // Account session key
  final String session;

  // Post item
  final PostDetail detail;

  PostCard({
    Key key,
    this.session,
    this.detail,
  });

  @override
  _PostState createState() => new _PostState();
}

class _PostState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Get resolution
    final wh = ScreenConst.fromValue(widget.detail.post.size);

    // Get post width and height
    final pw = width;
    final ph = (wh[0] / width) * wh[1];

    Widget p;
    if (widget.detail.post.items.length > 1) {
      final items = <Widget>[];

      for (int i = 0; i < widget.detail.post.items.length; i++) {
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

      p = new Container(
        width: pw,
        height: ph,
        child: new PageView(
          physics: const ClampingScrollPhysics(),
          children: items,
        ),
      );
    } else {
      final type = widget.detail.post.types[0];

      p = type == AppConst.video ? _getVideo(0) : _getPhoto(0);
    }

    return new Container(
      child: p,
    );
  }

  /// Get photo widget
  Widget _getPhoto(int index) {
    final width = MediaQuery.of(context).size.width;

    // Get resolution
    final wh = ScreenConst.fromValue(widget.detail.post.size);

    // Get post width and height
    final pw = width;
    final ph = (wh[0] / width) * wh[1];

    // Http headers for image request
    final h = {Http.CONTENT_HEADER: widget.session};

    return new Container(
      width: pw,
      height: ph,
      child: new CachedNetworkImage(
        width: pw,
        height: ph,
        imageUrl: widget.detail.post.items[index].large,
        httpHeaders: h,
        fadeInDuration: Duration.zero,
        filterQuality: FilterQuality.high,
        placeholder: (c, u) => new Loading(width: pw, height: ph),
        errorWidget: (c, u, e) => new Image.asset('assets/images/default.1.webp'),
      ),
    );
  }

  /// Get video widget
  Widget _getVideo(int index) {}
}
