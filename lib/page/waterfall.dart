import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/post.dart';
import 'package:spectrome/service/post/waterfall.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/util/error.dart';
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

// Error message
  ErrorMessage _error;

  // API response, validation error messages
  String _message;

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

    return new Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      body: new SingleChildScrollView(
        child: new Container(
          child: _getWaterFall(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  // Show error when error not empty
  void _showError() {
    final snackBar = SnackBar(
      content: Text(_error.error),
      backgroundColor: ColorConst.darkRed,
    );

    _sk.currentState.showSnackBar(snackBar);
  }

  /// Get waterfall posts widget
  Widget _getWaterFall() {
    // Clear error message
    _error = null;

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
        _message = r.message;
        return;
      }

      // Add posts into the posts sequence
      _posts.addAll(r.posts);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      _error = ErrorMessage.custom(msg);

      // Show snackbar error indicator
      _showError();
    };

    WaterFallService.call(_session, _timestamp).then(c).catchError(e);
  }
}
