import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/post.dart';
import 'package:spectrome/item/shimmer.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/service/post/waterfall.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/storage.dart';

class WaterFallPage extends StatefulWidget {
  static final tag = 'waterfall';

  // View page controller
  final PageController controller;

  // Number of active follow requests
  final ValueNotifier<int> request;

  WaterFallPage({this.controller, this.request}) : super();

  @override
  _WaterFallState createState() => new _WaterFallState();
}

class _WaterFallState extends State<WaterFallPage> with AutomaticKeepAliveClientMixin {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Scroll controller
  final _sc = new ScrollController();

  // Post items
  final _posts = <PostDetail>[];

  // Loading indicator
  bool _loading = true;

  // Is scroll operation has made or not
  bool _scrolled = false;

  // Account session key
  String _session;

  // Cursor timestamp value
  double _timestamp;

  @override
  void initState() {
    super.initState();

    // Posts list view scroll controller
    _sc.addListener(() {
      setState(() => _scrolled = (_sc.position.pixels > 1.0));

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
  void dispose() {
    // Dispose scroll controller
    _sc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final sh = new Shimmer();

    // Use multiple widgets to show shimmer
    final items = <Widget>[];

    final builder = (context, index) {
      // Create post card
      return new PostCard(detail: _posts[index], session: _session);
    };

    final b = new Expanded(
      child: new ListView.builder(
        controller: _sc,
        physics: const ClampingScrollPhysics(),
        padding: new EdgeInsets.only(top: 8.0, bottom: 8.0),
        itemCount: _posts.length,
        itemBuilder: builder,
      ),
    );

    items.add(b);

    // Add shimmer in case of loading state
    if (_loading) {
      items.add(sh);
    }

    // Share post button callback
    final sc = () {
      final d = new Duration(milliseconds: 500);
      final c = Curves.easeInOut;

      // Move to profile page
      widget.controller.animateToPage(0, duration: d, curve: c);
    };

    // Share post page button
    final l = new Semantics(
      button: true,
      child: new GestureDetector(
        onTap: sc,
        child: new Padding(
          padding: EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 12.0,
          ),
          child: new Icon(
            IconData(
              0xf0fe,
              fontFamily: FontConst.fal,
            ),
            color: ColorConst.darkGray,
            size: 20.0,
          ),
        ),
      ),
    );

    // Profile button callback
    final pc = () {
      final d = new Duration(milliseconds: 500);
      final c = Curves.easeInOut;

      // Move to profile page
      widget.controller.animateToPage(2, duration: d, curve: c);
    };

    // Profile page button
    final t = new Semantics(
      button: true,
      child: new GestureDetector(
        onTap: pc,
        child: new Padding(
          padding: EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 12.0,
          ),
          child: new Icon(
            IconData(
              0xf007,
              fontFamily: FontConst.fal,
            ),
            color: widget.request.value > 0 ? ColorConst.darkRed : ColorConst.darkGray,
            size: 20.0,
          ),
        ),
      ),
    );

    final eb = Border(
      bottom: BorderSide.none,
    );

    final gb = new Border(
      bottom: BorderSide(
        color: ColorConst.lightGray,
        width: 0.5,
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
        border: _scrolled ? gb : eb,
        leading: l,
        trailing: t,
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items,
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
      final msg = 'Unknown post load error. Please try again later.';

      dev.log(msg, stackTrace: s);

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
