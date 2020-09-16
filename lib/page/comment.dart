import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/comment.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/comment/detail.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/comment/history.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class CommentPage extends StatefulWidget {
  static final tag = 'comment';

  CommentPage() : super();

  @override
  _CommentState createState() => new _CommentState();
}

class _CommentState extends State<CommentPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // List of post comments
  final _comments = <CommentDetail>[];

  // Loading indicator
  bool _loading = true;

  // Post object
  PostDetail _post;

  // Account session key
  String _session;

  // Error message
  ErrorMessage _error;

  // Cursor timestamp value
  String _timestamp;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final sc = (SharedPreferences sp) {
      final session = sp.getString('_session');

      // Update session
      setState(() => _session = session);

      // Get owned comment
      _getComments();
    };

    // Post detail callback
    final ac = (_) {
      final post = ModalRoute.of(context).settings.arguments as PostDetail;

      // Load route arguments if specified
      if (post != null) {
        _post = post;
      }

      // Get storage kv
      Storage.load().then(sc);
    };

    // Add callback for argument
    WidgetsBinding.instance.addPostFrameCallback(ac);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: AppConst.loader(
          page: CommentPage.tag,
          argument: _session == null,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get main page widget
  Widget _getPage() {
    // Back button
    final l = new GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: new Icon(
        IconData(0xf104, fontFamily: FontConst.fal),
        color: ColorConst.darkerGray,
      ),
    );

    final s = new ListView.builder(
      itemCount: _loading ? _comments.length + 1 : _comments.length,
      itemBuilder: _builder,
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        heroTag: 2,
        transitionBetweenRoutes: false,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        backgroundColor: ColorConst.white,
        border: new Border(
          bottom: BorderSide.none,
        ),
        middle: new Text(
          'Comments',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
            fontSize: 16.0,
          ),
        ),
        leading: l,
      ),
      child: s,
    );
  }

  /// Comment list builder
  Widget _builder(BuildContext context, int index) {
    if (_loading && index >= _comments.length) {
      return new Loading();
    }

    return new CommentRow(
      comment: _comments[index].comment,
      user: _comments[index].user,
      me: _comments[index].me,
      session: _session,
    );
  }

  /// Show error when error not empty
  void _showSnackBar(String message, {bool isError = true}) {
    final snackBar = SnackBar(
      content: new Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: new Text(
          message,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
          ),
        ),
      ),
      backgroundColor: isError ? ColorConst.darkRed : ColorConst.dark,
    );

    _sk.currentState.showSnackBar(snackBar);
  }

  /// Load comments history
  void _getComments() async {
    dev.log('Comment history is loading.');

    // Handle HTTP response
    final sc = (CommentHistoryResponse r) async {
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
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown comments load error. Please try again later.';

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
    final r = CommentHistoryService.call(
      session: _session,
      code: _post.post.code,
      timestamp: _timestamp,
    );

    await r.then(sc).catchError(e).whenComplete(cc);
  }
}
