import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/history/comment.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/history/comment.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class HistoryPage extends StatefulWidget {
  static final tag = 'history';

  HistoryPage() : super();

  @override
  _HistoryState createState() => new _HistoryState();
}

class _HistoryState extends State<HistoryPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Scroll controller
  final _sc = new ScrollController();

  // Post items
  final _posts = <CommentHistory>[];

  // Loading indicator
  bool _loading = true;

  // Account session key
  String _session;

  // Cursor timestamp value
  String _timestamp;

  // Error message
  ErrorMessage _error;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final sc = (SharedPreferences sp) {
      final session = sp.getString('_session');

      // Update session
      setState(() => _session = session);

      // Get owned comment
      _getHistory();
    };

    Storage.load().then(sc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: AppConst.loader(
          page: HistoryPage.tag,
          argument: _session == null,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
    // History item list builder
    final i = new ListView.builder(
      controller: _sc,
      physics: const ClampingScrollPhysics(),
      itemCount: _loading ? _posts.length + 1 : _posts.length,
      itemBuilder: _postBuilder,
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        heroTag: 4,
        transitionBetweenRoutes: false,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        backgroundColor: ColorConst.white,
        border: new Border(bottom: BorderSide.none),
        middle: new Text(
          'History',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
            fontSize: 16.0,
          ),
        ),
      ),
      child: new Container(
        child: new Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          child: i,
        ),
      ),
    );
  }

  // History post widget builder
  Widget _postBuilder(BuildContext context, int index) {
    // Get loading indicator if something is loading
    if (_loading && index == 0) {
      return new Loading();
    }

    return new Container();
  }

  /// Show error when error not empty
  void _showSnackBar(String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? ColorConst.darkRed : ColorConst.dark,
    );

    _sk.currentState.showSnackBar(snackBar);
  }

  /// Load comments history
  void _getHistory() async {
    dev.log('Comment history is loading.');

    // Handle HTTP response
    final sc = (HistoryCommentResponse r) async {
      dev.log('Recent comment request sent.');

      if (!r.status) {
        // Route to sign page, if session is expired
        if (r.expired) {
          final r = (Route<dynamic> route) => false;
          await Navigator.of(context).pushNamedAndRemoveUntil(SignInPage.tag, r);
          return;
        }

        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _showSnackBar(r.message, isError: true);
        }

        return;
      }

      _posts.addAll(r.posts);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown history load error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    // Prepare request
    final r = HistoryCommentService.call(_session, _timestamp);

    await r.then(sc).catchError(e).whenComplete(cc);
  }
}
