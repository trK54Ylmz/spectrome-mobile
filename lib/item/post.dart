import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:spectrome/item/photo.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/page/detail.dart';
import 'package:spectrome/page/me.dart';
import 'package:spectrome/page/profile.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/date.dart';
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
  // Page controller for multiple items
  final _pc = new PageController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Get resolution
    final wh = ScreenConst.fromValue(widget.detail.post.size);

    // Get post width and height
    final pw = width;
    final ph = (width / wh[0]) * wh[1];

    // Http headers for profile image request
    final h = {Http.TOKEN_HEADER: widget.session};

    final pt = new Padding(padding: EdgeInsets.only(top: 16.0));

    // User profile callback
    final uc = () async {
      final t = widget.detail.me ? MePage.tag : ProfilePage.tag;
      final u = widget.detail.user.username;

      // Move to profile page
      await Navigator.of(context).pushNamed(t, arguments: u);
    };

    final pp = new GestureDetector(
      onTap: uc,
      child: new Container(
        width: 40.0,
        height: 40.0,
        decoration: new BoxDecoration(
          color: ColorConst.gray,
          border: new Border.all(
            width: 0.5,
            color: ColorConst.gray.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: new ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: new Image.network(
            widget.detail.user.photoUrl,
            headers: h,
            width: 40.0,
            height: 40.0,
            errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
          ),
        ),
      ),
    );

    final ur = new Container(
      width: 120.0,
      height: 22.0,
      child: new Text(
        widget.detail.user.username,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.black,
          fontSize: 16.0,
          letterSpacing: 0.33,
        ),
      ),
    );

    final un = new Container(
      width: 120.0,
      height: 14.0,
      child: new Text(
        DateTimes.diff(DateTime.now(), widget.detail.post.createTime),
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkGray,
          fontSize: 12.0,
          letterSpacing: 0.33,
        ),
      ),
    );

    final uu = new GestureDetector(
      onTap: uc,
      child: new Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ur,
            un,
          ],
        ),
      ),
    );

    final cl = new Container(
      width: width - 130,
      child: uu,
    );

    final ec = new Container();

    final dt = new Text(
      'Disposible'.toUpperCase(),
      textAlign: TextAlign.right,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 12.0,
        color: ColorConst.yellow,
      ),
    );

    final ds = new Container(
      width: 64.0,
      height: 14.0,
      child: widget.detail.post.disposible ? dt : ec,
    );

    final i = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        pp,
        cl,
        ds,
      ],
    );

    final ri = new Icon(
      new IconData(0xf007, fontFamily: FontConst.fal),
      color: ColorConst.gray,
      size: 16.0,
    );

    final rt = new Padding(
      padding: EdgeInsets.only(left: 6.0),
      child: new Text(
        widget.detail.post.users.toString(),
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: ColorConst.black,
        ),
      ),
    );

    final ru = new Expanded(
      flex: 1,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ri,
          rt,
        ],
      ),
    );

    final ci = new Icon(
      new IconData(0xf4ad, fontFamily: FontConst.fal),
      color: ColorConst.gray,
      size: 16.0,
    );

    // Number of comments text
    final ct = new Padding(
      padding: EdgeInsets.only(left: 6.0),
      child: new Text(
        widget.detail.post.comments.toString(),
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: ColorConst.black,
        ),
      ),
    );

    final cu = new Expanded(
      flex: 1,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ci,
          ct,
        ],
      ),
    );

    final rw = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.detail.post.restricted ? ru : ec,
        cu,
      ],
    );

    final wg = new GestureDetector(
      onTap: () async {
        // Move to detail page
        await Navigator.of(context).pushNamed(DetailPage.tag, arguments: widget.detail);
      },
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          pt,
          rw,
          pt,
        ],
      ),
    );

    // Create post widget by number of posts
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
          controller: _pc,
          children: items,
        ),
      );
    } else {
      final type = widget.detail.post.types[0];

      p = type == AppConst.video ? _getVideo(0) : _getPhoto(0);
    }

    return new Column(
      children: [
        i,
        pt,
        p,
        wg,
        pt,
      ],
    );
  }

  /// Get photo widget
  Widget _getPhoto(int index) {
    final width = MediaQuery.of(context).size.width;

    // Get resolution
    final wh = ScreenConst.fromValue(widget.detail.post.size);

    // Get post width and height
    final pw = width;
    final ph = (width / wh[0]) * wh[1];

    // Http headers for image request
    final h = {Http.TOKEN_HEADER: widget.session};

    return new Photo(
      key: new ValueKey(widget.detail.post.items[index].large),
      url: widget.detail.post.items[index].large,
      headers: h,
      width: pw,
      height: ph,
    );
  }

  /// Get video widget
  Widget _getVideo(int index) {
    final width = MediaQuery.of(context).size.width;

    // Get resolution
    final wh = ScreenConst.fromValue(widget.detail.post.size);

    // Get post width and height
    final pw = width;
    final ph = (width / wh[0]) * wh[1];

    return new Container(
      width: pw,
      height: ph,
    );
  }
}
