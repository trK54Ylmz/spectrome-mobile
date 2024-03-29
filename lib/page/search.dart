import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/page/me.dart';
import 'package:spectrome/page/profile.dart';
import 'package:spectrome/service/query/user.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';

class SearchPage extends StatefulWidget {
  static final tag = 'search';

  SearchPage() : super();

  @override
  _SearchState createState() => new _SearchState();
}

class _SearchState extends State<SearchPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Search input controller
  final _sc = new TextEditingController();

  // List of suggestions
  final _suggests = <SimpleProfile>[];

  // Loading indicator
  bool _loading = false;

  // My username
  String _me;

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
          page: SearchPage.tag,
          argument: _session == null,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
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
      fontWeight: FontWeight.normal,
    );

    // Trailing button
    final b = new Button(
      background: ColorConst.transparent,
      color: ColorConst.darkerGray,
      width: 60.0,
      text: 'Clear',
      disabled: _sc.text.length == 0,
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 4.0,
      ),
      onPressed: () {
        // Clear user results
        _suggests.clear();

        // Clear text field
        setState(() => _sc.clear());
      },
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        heroTag: 7,
        transitionBetweenRoutes: false,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        backgroundColor: ColorConst.white,
        border: new Border(bottom: BorderSide.none),
        middle: new FormText(
          hint: 'Type something',
          hintStyle: hs,
          style: ts,
          controller: _sc,
          onChange: (t) {
            if (t.length < 2) {
              // Clear current list
              setState(() => _suggests.clear());

              return null;
            }

            // Send request and collect suggestions
            _fetch();

            return null;
          },
          borderColor: ColorConst.gray,
        ),
        trailing: b,
      ),
      child: new Container(
        child: new Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          child: new ListView.builder(
            itemCount: _suggests.length,
            itemBuilder: _suggestBuilder,
          ),
        ),
      ),
    );
  }

  /// Suggested users list builder
  Widget _suggestBuilder(BuildContext context, int i) {
    // Http headers for image request
    final h = {Http.TOKEN_HEADER: _session};

    // Request profile photo from server
    final p = new Container(
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
          _suggests[i].photoUrl,
          headers: h,
          width: 40.0,
          height: 40.0,
          errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
        ),
      ),
    );

    final pt = new Padding(
      padding: EdgeInsets.only(top: 2.0),
    );

    // Username text
    final un = new Text(
      _suggests[i].username,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.black,
        fontSize: 16.0,
        letterSpacing: 0.33,
      ),
    );

    // Real name text
    final nm = new Text(
      _suggests[i].name,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.darkGray,
        fontSize: 12.0,
        letterSpacing: 0.33,
      ),
    );

    // Information container
    final d = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 2.0,
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          un,
          pt,
          nm,
        ],
      ),
    );

    return new Semantics(
      focusable: true,
      button: true,
      child: new GestureDetector(
        onTap: () async {
          dev.log('User "${_suggests[i].username}" selected.');

          final u = _suggests[i].username;
          final t = u == _me ? MePage.tag : ProfilePage.tag;

          // Route to profile page
          await Navigator.of(context).pushNamed(t, arguments: u);
        },
        behavior: HitTestBehavior.opaque,
        child: new Container(
          child: new Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                p,
                d,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fetch users by using query filter
  void _fetch() {
    dev.log('User search triggered.');

    if (_loading) {
      return;
    }

    dev.log('User search request sending for "${_sc.text}".');

    // Set loading true
    setState(() => _loading = true);

    // Handle HTTP response
    final c = (UserQueryResponse r) async {
      dev.log('User search request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          // _message = r.message;
        }

        return;
      }

      // Set my username
      _me = r.me;

      // Clear current list
      _suggests.clear();

      // Add all users
      _suggests.addAll(r.users);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown suggestion error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
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
    final s = UserQueryService.call(_session, _sc.text);

    s.then(c).catchError(e).whenComplete(cc);
  }
}
