import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/page/me.dart';
import 'package:spectrome/page/profile.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/date.dart';
import 'package:spectrome/util/http.dart';

class PostDetailCard extends StatefulWidget {
  // Account session key
  final String session;

  // Post item
  final PostDetail detail;

  PostDetailCard({
    Key key,
    this.session,
    this.detail,
  });

  @override
  _PostDetailState createState() => new _PostDetailState();
}

class _PostDetailState extends State<PostDetailCard> {
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

    final pts = new Padding(padding: EdgeInsets.only(top: 8.0));
    final pt = new Padding(padding: EdgeInsets.only(top: 16.0));
    final ptx = new Padding(padding: EdgeInsets.only(top: 32.0));

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

    final tsn = new TextStyle(
      fontFamily: FontConst.primary,
      color: ColorConst.black,
      fontSize: 14.0,
      letterSpacing: 0.33,
    );

    final tsb = new TextStyle(
      fontFamily: FontConst.primary,
      color: ColorConst.black,
      fontSize: 14.0,
      letterSpacing: 0.33,
      fontWeight: FontWeight.bold,
    );

    final smi = <InlineSpan>[];
    if (widget.detail.users.length > 3) {
      smi.add(new TextSpan(text: widget.detail.users[0].username, style: tsb));
      smi.add(new TextSpan(text: ', ', style: tsn));
      smi.add(new TextSpan(text: widget.detail.users[1].username, style: tsb));
      smi.add(new TextSpan(text: ' and ', style: tsn));
      smi.add(new TextSpan(text: '${widget.detail.users.length - 2} more', style: tsb));
    } else if (widget.detail.users.length == 2) {
      smi.add(new TextSpan(text: widget.detail.users[0].username, style: tsb));
      smi.add(new TextSpan(text: ' and ', style: tsn));
      smi.add(new TextSpan(text: widget.detail.users[1].username, style: tsb));
    } else {
      smi.add(new TextSpan(text: widget.detail.users[0].username, style: tsb));
    }

    final rt = new Padding(
      padding: EdgeInsets.only(left: 6.0),
      child: new RichText(
        overflow: TextOverflow.ellipsis,
        text: new TextSpan(
          text: 'shared with ',
          style: tsn,
          children: smi,
        ),
      ),
    );

    final ri = new Icon(
      new IconData(0xf007, fontFamily: FontConst.fal),
      color: ColorConst.darkerGray,
      size: 16.0,
    );

    final ru = new Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
      ),
      child: new Row(
        children: [
          ri,
          rt,
        ],
      ),
    );

    final ci = new Icon(
      new IconData(0xf4ad, fontFamily: FontConst.fal),
      color: ColorConst.darkerGray,
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

    final cu = new Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
      ),
      child: new Row(
        children: [
          ci,
          ct,
        ],
      ),
    );

    final wg = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4.0,
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.detail.post.restricted ? ru : ec,
          pts,
          cu,
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
        pt,
        wg,
        ptx,
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

    final i = new Image.network(
      widget.detail.post.items[index].large,
      headers: h,
      errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
    );

    return new Container(
      width: pw,
      height: ph,
      child: i,
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
