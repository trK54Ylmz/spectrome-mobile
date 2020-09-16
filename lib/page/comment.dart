import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/comment.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/comment/detail.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/comment/add.dart';
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

  // Comment box controller
  final _cc = new TextEditingController();

  // List of post comments
  final _comments = <CommentDetail>[];

  // Loading indicator
  bool _loading = true;

  // Status of comment box and text
  bool _disabled = true;

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

    final s = new Expanded(
      child: new ListView.builder(
        itemCount: _loading ? _comments.length + 1 : _comments.length,
        itemBuilder: _builder,
      ),
    );

    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
    );

    final hs = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
      color: ColorConst.gray,
    );

    // Comment box
    final b = new Container(
      color: ColorConst.white,
      child: new Padding(
        padding: EdgeInsets.all(8.0),
        child: FormText(
          expands: true,
          maxLines: null,
          minLines: null,
          size: 4000,
          style: ts,
          hintStyle: hs,
          controller: _cc,
          hint: 'Type your comment ...',
          validator: (String i) {
            if (i.length == 0) {
              return 'The message is required.';
            }

            if (i.runes.length < 10) {
              return 'The message requires at least 10 characters.';
            }

            return null;
          },
        ),
      ),
    );

    final ec = new Container(width: 0, height: 0);

    // Create comment button
    final a = new Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      child: new Button(
        text: 'Send',
        background: ColorConst.darkGray,
        padding: EdgeInsets.all(8.0),
        disabled: _disabled,
        onPressed: _addComment,
      ),
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
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          s,
          b,
          _disabled ? ec : a,
        ],
      ),
    );
  }

  /// Comment list builder
  Widget _builder(BuildContext context, int index) {
    if (_loading && index >= _comments.length) {
      return new Loading();
    }

    final actions = <SwipeAction>[];

    final report = new SwipeAction(
      icon: new Icon(
        new IconData(0xf74c, fontFamily: FontConst.fal),
        color: ColorConst.white,
        size: 16.0,
      ),
      onTap: (CompletionHandler handler) async {},
      color: ColorConst.darkGray,
    );

    actions.add(report);

    if (_comments[index].me) {
      final remove = new SwipeAction(
        icon: new Icon(
          new IconData(0xf2ed, fontFamily: FontConst.fal),
          color: ColorConst.white,
          size: 16.0,
        ),
        onTap: (CompletionHandler handler) async {
          // Remove comment from array
          setState(() => _comments.removeAt(index));
        },
        color: ColorConst.darkRed,
      );

      actions.add(remove);
    }

    return new SwipeActionCell(
      key: ObjectKey(_comments[index].comment),
      actions: actions,
      child: new CommentRow(
        comment: _comments[index].comment,
        user: _comments[index].user,
        me: _comments[index].me,
        session: _session,
      ),
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

      setState(() => _comments.addAll(r.comments));
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

  /// Add new comment
  void _addComment() async {
    dev.log('Comment create triggered.');

    if (_cc.text.length < 2) {
      return;
    }

    // Handle HTTP response
    final sc = (CommentAddResponse r) async {
      dev.log('Create comment request sent.');

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

      // Populate with new comment
      _comments.add(r.comment);

      if (_comments.length > 2) {
        // Remove first comment
        setState(() => _comments.removeAt(0));
      }
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown comments add error. Please try again later.';

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
    final r = CommentAddService.call(
      session: _session,
      code: _post.post.code,
      message: _cc.text,
    );

    await r.then(sc).catchError(e).whenComplete(cc);
  }
}
