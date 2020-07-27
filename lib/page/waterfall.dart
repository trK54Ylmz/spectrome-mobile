import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/post.dart';
import 'package:spectrome/service/post/post.dart';
import 'package:spectrome/service/post/waterfall.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/storage.dart';

class WaterFallPage extends StatefulWidget {
  static final tag = 'waterfall';

  WaterFallPage() : super();

  @override
  _WaterFallState createState() => new _WaterFallState();
}

class _WaterFallState extends State<WaterFallPage> with AutomaticKeepAliveClientMixin {
  final _sk = GlobalKey<ScaffoldState>();

  // Post items
  final _posts = <Post>[];

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
    final c = (SharedPreferences sp) {
      final session = sp.getString('_session');

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
      items.add(AppConst.shimmer());
    }

    return new Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
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
  void _showSnackBar(String message, {isError = true}) {
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

    WaterFallService.call(_session, _timestamp).then(c).catchError(e);
  }
}
