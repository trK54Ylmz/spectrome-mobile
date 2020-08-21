import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/post.dart';
import 'package:spectrome/item/shimmer.dart';
import 'package:spectrome/model/post/post.dart';
import 'package:spectrome/page/search.dart';
import 'package:spectrome/service/post/waterfall.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/storage.dart';

class WaterFallPage extends StatefulWidget {
  static final tag = 'waterfall';

  WaterFallPage() : super();

  @override
  _WaterFallState createState() => new _WaterFallState();
}

class _WaterFallState extends State<WaterFallPage> with AutomaticKeepAliveClientMixin {
  // Scaffold key
  final _sk = GlobalKey<ScaffoldState>();

  // Post items
  final _posts = <Post>[];

  // Scroll controller
  final _sc = new ScrollController();

  // Loading indicator
  bool _loading = true;

  // Account session key
  String _session;

  // Cursor timestamp value
  double _timestamp;

  @override
  void initState() {
    super.initState();

    _sc.addListener(() {
      // Load more posts
      if (_sc.offset == _sc.position.maxScrollExtent) {
        _getPosts();
      }
    });

    // Shared preferences callback
    final c = (SharedPreferences s) {
      final session = s.getString('_session');

      setState(() => _session = session);
    };

    // Complete callback
    final cc = () {
      // Load posts for the first time
      _getPosts();
    };

    // Get shared preferences
    Storage.load().then(c).whenComplete(cc);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Use multiple widgets to show shimmer
    final items = <Widget>[
      _getWaterFall(),
    ];

    // Add shimmer in case of loading state
    if (_loading) {
      final s = new Shimmer(
        duration: Duration(seconds: 1),
        child: new Container(
          width: 300,
          height: 300,
          color: ColorConst.gray,
        ),
      );

      items.add(s);
    }

    // Settings button
    final t = new Semantics(
      button: true,
      child: new GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(SearchPage.tag),
        child: new Padding(
          padding: EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 12.0,
          ),
          child: new Icon(
            IconData(
              0xf002,
              fontFamily: FontConst.fal,
            ),
            color: ColorConst.darkerGray,
            size: 20.0,
          ),
        ),
      ),
    );

    return new Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      appBar: new CupertinoNavigationBar(
        heroTag: 3,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        transitionBetweenRoutes: false,
        backgroundColor: ColorConst.white,
        border: Border(
          bottom: BorderSide.none,
        ),
        trailing: t,
      ),
      body: new SingleChildScrollView(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: items,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  /// Show error when error not empty
  void _showSnackBar(String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? ColorConst.darkRed : ColorConst.dark,
    );

    _sk.currentState.showSnackBar(snackBar);
  }

  /// Get waterfall posts widget
  Widget _getWaterFall() {
    final builder = (context, index) {
      return new PostCard(
        post: _posts[index],
      );
    };

    return ListView.builder(
      shrinkWrap: true,
      controller: _sc,
      padding: new EdgeInsets.only(top: 8.0, bottom: 8.0),
      itemCount: _posts.length,
      itemBuilder: builder,
    );
  }

  /// Get waterfall posts
  void _getPosts() {
    dev.log('Waterfall posts request sent.');

    // Log timestamp value for debugging
    if (_timestamp != null) {
      dev.log('Waterfall active pagination is $_timestamp');
    }

    final c = (WaterFallResponse r) {
      if (!r.status) {
        // Show snackbar error indicator
        _showSnackBar(r.message, isError: false);
        return;
      }

      // Add posts into the posts sequence
      _posts.addAll(r.posts);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Show snackbar error indicator
      _showSnackBar(msg);
    };

    // Complete callback
    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    // Prepare request
    final s = WaterFallService.call(_session, _timestamp);

    s.then(c).catchError(e).whenComplete(cc);
  }
}
