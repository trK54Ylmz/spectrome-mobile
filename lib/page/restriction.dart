import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/query/following.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';

class RestrictionPage extends StatefulWidget {
  static final tag = 'restriction';

  RestrictionPage() : super();

  _RestrictionState createState() => new _RestrictionState();
}

class _RestrictionState extends State<RestrictionPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Page view controller
  final _pc = new PageController();

  // Search input controller
  final _sc = new TextEditingController();

  // User typing or not
  final _typing = new ValueNotifier<bool>(false);

  // List of selected users
  final _users = <SimpleProfile>[];

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

    // User typing listener callback
    final lc = () {
      final d = Duration(seconds: 1);
      final c = Curves.ease;

      // Move between pages according value
      if (_typing.value) {
        _pc.animateToPage(2, duration: d, curve: c);
      } else {
        _pc.animateToPage(1, duration: d, curve: c);
      }
    };

    // Shared preferences callback
    final sc = (SharedPreferences sp) {
      final session = sp.getString('_session');

      // Update session
      setState(() => _session = session);
    };

    _typing.addListener(lc);

    // Selected users callback
    final ac = (_) {
      final users = ModalRoute.of(context).settings.arguments as List<SimpleProfile>;

      // Load route arguments if specified
      if (_users.isNotEmpty) {
        _users.addAll(users);
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
          page: RestrictionPage.tag,
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

    // Selected users list builder
    final lb = (BuildContext context, int i) {};

    // Selected users
    final l = new Container(
      child: new ListView.builder(
        itemCount: _users.length,
        itemBuilder: lb,
      ),
    );

    // User suggestions
    final s = new Container(
      child: new ListView.builder(
        itemCount: _suggests.length,
        itemBuilder: _suggestBuilder,
      ),
    );

    // Trailing callback
    final tc = () {
      if (_typing.value) {
        // Clear text value
        _sc.clear();

        setState(() => _typing.value = false);
      } else {
        setState(() => _typing.value = true);
      }
    };

    // Trailing button
    final b = new Button(
      background: ColorConst.transparent,
      color: _typing.value ? ColorConst.darkGray : ColorConst.button,
      width: 60.0,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      text: _typing.value ? 'Clear' : 'Edit',
      onPressed: tc,
    );

    // Empty container
    final bc = new Container(width: 60.0);

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        heroTag: 1,
        transitionBetweenRoutes: false,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        border: new Border(bottom: BorderSide.none),
        backgroundColor: ColorConst.white,
        leading: new GestureDetector(
          onTap: () {
            final users = _users.map((e) => e.username).toList();

            // Go back with usernames
            Navigator.of(context).pop(users);
          },
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
              return null;
            }

            // Select typing
            if (!_typing.value) {
              setState(() => _typing.value = true);
            }

            // Send request and collect suggestions
            _fetch();

            return null;
          },
          borderColor: ColorConst.gray,
        ),
        trailing: _sc.text.length == 0 ? bc : b,
      ),
      child: new PageView(
        controller: _pc,
        physics: const ClampingScrollPhysics(),
        children: [
          l,
          s,
        ],
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
          filterQuality: FilterQuality.high,
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
        onTap: () {
          dev.log('User "${_suggests[i].username}" selected.');

          // Add users to suggestion
          _users.add(_suggests[i]);
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
    final c = (FollowingQueryResponse r) async {
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
    final s = FollowingQueryService.call(_session, _sc.text);

    s.then(c).catchError(e).whenComplete(cc);
  }
}
