import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/comment.dart';
import 'package:spectrome/item/detail.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/model/post/comment.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/comment/owned.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class DetailPage extends StatefulWidget {
  static final tag = 'detail';

  DetailPage() : super();

  @override
  _DetailState createState() => new _DetailState();
}

class _DetailState extends State<DetailPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // List of selected users
  PostDetail _post;

  // Owned comment
  Comment _owned;

  // Account session key
  String _session;

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
      _getOwned();
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
          page: DetailPage.tag,
          argument: _session == null,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
    final th = MediaQuery.of(context).size.height;
    final sp = MediaQuery.of(context).padding.top;

    final h = th - sp;

    // Back button
    final l = new GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: new Icon(
        IconData(0xf104, fontFamily: FontConst.fal),
        color: ColorConst.darkerGray,
      ),
    );

    // Post detail card
    final p = new PostDetailCard(
      detail: _post,
      session: _session,
    );

    final ci = <Widget>[];
    if (_owned != null) {
      // Create owned comment
      final ct = new CommentRow(
        user: _post.user,
        comment: _owned,
        session: _session,
        me: _post.me,
      );

      ci.add(ct);
    }

    final c = new Column(
      children: ci,
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
    final b = new Padding(
      padding: EdgeInsets.all(8.0),
      child: FormText(
        expands: true,
        maxLines: null,
        minLines: null,
        size: 4000,
        style: ts,
        hintStyle: hs,
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
    );

    final m = new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          p,
          c,
        ],
      ),
    );

    final s = new Stack(
      alignment: Alignment.bottomLeft,
      children: [
        m,
        b,
      ],
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
        border: new Border(
          bottom: BorderSide.none,
        ),
        leading: l,
      ),
      child: new Container(
        height: h,
        child: s,
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

  /// Get owned comment
  void _getOwned() async {
    dev.log('Owned comment is loading.');

    // Handle HTTP response
    final sc = (CommentOwnedResponse r) async {
      dev.log('Owned comment request sent.');

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

      // Update profile instance
      setState(() => _owned = r.comment);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown profile load error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    // Prepare request
    final r = CommentOwnedService.call(_session, _post.post.code);

    await r.then(sc).catchError(e);
  }
}
