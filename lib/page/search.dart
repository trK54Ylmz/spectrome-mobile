import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/profile/simple.dart';
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
      color: ColorConst.darkGray,
      width: 60.0,
      text: 'Clear',
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 4.0,
      ),
      onPressed: () => _sc.clear(),
    );

    // Empty container
    final bc = new Container(width: 60.0);

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        backgroundColor: ColorConst.white,
        leading: new GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: new Icon(
            IconData(0xf104, fontFamily: FontConst.fal),
            color: ColorConst.darkerGray,
          ),
        ),
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
        trailing: _sc.text.length == 0 ? bc : b,
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
    final h = {Http.CONTENT_HEADER: _session};

    // Request profile photo from server
    final p = new ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: new Container(
        width: 40.0,
        height: 40.0,
        child: new CachedNetworkImage(
          width: 40.0,
          height: 40.0,
          imageUrl: _suggests[i].photoUrl,
          httpHeaders: h,
          fadeInDuration: Duration.zero,
          placeholder: (c, u) => new Loading(width: 40.0, height: 40.0),
          errorWidget: (c, u, e) => new Image.asset('assets/images/default.1.webp'),
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

          await Navigator.of(context).pushNamed(ProfilePage.tag, arguments: _suggests[i]);
        },
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

      // Clear current list
      _suggests.clear();

      // Add all users
      _suggests.addAll(r.users);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

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
