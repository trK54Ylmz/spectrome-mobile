import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/model/post/post.dart';

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

    if (widget.post.assets.length > 1) {
      final items = widget.post.assets.map(getAssetWidget);

      return new Container(
        width: width,
        height: height,
        child: new PageView(
          physics: const ClampingScrollPhysics(),
          children: items,
        ),
      );
    } else {
      return getAssetWidget(widget.post.assets.first);
    }
  }

  Widget getAssetWidget(PostAsset asset) {
    if (asset.type == PostAssetType.PHOTO) {
      return new Container(
        child: new CachedNetworkImage(
          imageUrl: widget.post.assets.first.url,
        ),
      );
    } else {
      return new Container();
    }
  }
}
