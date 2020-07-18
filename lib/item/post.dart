import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/service/post/waterfall.dart';

class PostCard extends StatefulWidget {
  // Post item
  final Post post;

  PostCard({
    Key key,
    this.post,
  });

  @override
  _PostState createState() => new _PostState();
}

class _PostState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final postWidth = widget.post.width.toDouble();

    final height = (width > postWidth) ? width / postWidth : postWidth / width;

    return new Container(
      child: new CachedNetworkImage(
        imageUrl: widget.post.photoUrl,
        width: width,
        height: height,
      ),
    );
  }
}
