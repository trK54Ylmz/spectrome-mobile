import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/comment.dart';
import 'package:spectrome/item/detail.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/comment/comment.dart';
import 'package:spectrome/model/comment/detail.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/page/comment.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/comment/add.dart';
import 'package:spectrome/service/comment/owned.dart';
import 'package:spectrome/service/comment/recent.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
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

  // Comment box controller
  final _cc = new TextEditingController();

  // List of recent comments
  final _comments = <CommentDetail>[];

  // List of suggested users
  final _suggests = <SimpleProfile>[];

  // Loading indicator
  bool _loading = false;

  // Status of comment box and text
  bool _disabled = true;

  // Post detail object
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

      // Load comment if there are comments
      if (_post.post.comments > 0) {
        _loading = true;

        // Load comments
        _getComments();
      }
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
    } else {
      ci.add(new Loading());
    }

    // Add show comments button
    if (_post.post.comments >= 2) {
      final mt = new Text(
        'show all ${_post.post.comments} comments',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: ColorConst.gray,
        ),
      );

      final mi = new Padding(
        padding: EdgeInsets.only(left: 4.0, top: 2.0),
        child: new Icon(
          new IconData(0xf178, fontFamily: FontConst.fal),
          color: ColorConst.gray,
          size: 14.0,
        ),
      );

      final mb = new Semantics(
        focusable: true,
        button: true,
        child: new GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(CommentPage.tag, arguments: _post),
          child: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                mt,
                mi,
              ],
            ),
          ),
        ),
      );

      ci.add(mb);
    }

    // Create list of recent comments
    if (!_loading) {
      for (int i = 0; i < _comments.length; i++) {
        // Create user comment
        final ct = new CommentRow(
          user: _comments[i].user,
          comment: _comments[i].comment,
          session: _session,
          me: _comments[i].me,
        );

        ci.add(ct);
      }
    } else {
      ci.add(new Loading());
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
    final b = new Container(
      color: ColorConst.white,
      child: new Padding(
        padding: EdgeInsets.all(8.0),
        child: FormText(
          expands: true,
          maxLines: null,
          minLines: null,
          size: 1024,
          style: ts,
          hintStyle: hs,
          controller: _cc,
          hint: 'Type your comment ...',
          onChange: (String i) {
            setState(() => _disabled = i.length < 2);

            // Check if autocomplete is usable
            if (i[0] == '@') {

            }

            return i.replaceAll('\n', ' ');
          },
          validator: (String i) {
            if (i.length == 0) {
              return 'The message is required.';
            }

            if (i.runes.length < 2) {
              return 'The message requires at least 2 characters.';
            }

            return null;
          },
        ),
      ),
    );

    // Group of post and comments
    final m = new Expanded(
      child: new ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        children: [
          p,
          c,
        ],
      ),
    );

    final ec = new Container(width: 0, height: 0);

    // Suggested users
    final u = new ListView.builder(
      itemCount: _suggests.length,
      itemBuilder: _suggestionBuilder,
    );

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

    final s = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        m,
        _suggests.isNotEmpty ? u : ec,
        b,
        _disabled ? ec : a,
      ],
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        heroTag: 3,
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
          'Post',
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

  /// Get suggested users
  Widget _suggestionBuilder(BuildContext context, int index) {
    // Http headers for profile image request
    final h = {Http.TOKEN_HEADER: _session};

    // Profile photo
    final pp = new Container(
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
          _suggests[index].photoUrl,
          headers: h,
          width: 40.0,
          height: 40.0,
          errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
        ),
      ),
    );

    final ur = new Container(
      width: 120.0,
      height: 20.0,
      alignment: Alignment.centerLeft,
      child: new Text(
        _suggests[index].username,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.black,
          fontSize: 14.0,
          letterSpacing: 0.33,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final un = new Container(
      width: 120.0,
      height: 14.0,
      child: new Text(
        _suggests[index].name,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkGray,
          fontSize: 12.0,
          letterSpacing: 0.33,
        ),
      ),
    );

    final uu = new Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ur,
          un,
        ],
      ),
    );

    final c = () {};

    return new GestureDetector(
      onTap: c,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          pp,
          uu,
        ],
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
      final msg = 'Unknown comment load error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    // Prepare request
    final r = CommentOwnedService.call(_session, _post.post.code);

    await r.then(sc).catchError(e);
  }

  /// Get recent comments
  void _getComments() async {
    // Handle HTTP response
    final sc = (CommentRecentResponse r) async {
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

      // Update profile instance
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
    final r = CommentRecentService.call(_session, _post.post.code);

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

      // Clear comment text
      _cc.clear();

      // Hide comment send button
      _disabled = true;

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
