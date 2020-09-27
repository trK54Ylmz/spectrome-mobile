import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/page/profile.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/profile/follower.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';

class FollowerPage extends StatefulWidget {
  static final tag = 'follower';

  FollowerPage() : super();

  @override
  _FollowerState createState() => new _FollowerState();
}

class _FollowerState extends State<FollowerPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Scroll controller
  final _sc = new ScrollController();

  // List of follower users
  final _followers = <SimpleProfile>[];

  // Loading indicator
  bool _loading = true;

  // User profile
  SimpleProfile _profile;

  // Account session key
  String _session;

  // Error message
  ErrorMessage _error;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      final session = s.getString('_session');

      _session = session;

      // Get follower users
      _getFollowers();
    };

    Storage.load().then(spc);

    // Argument callback
    final ac = (_) {
      final profile = ModalRoute.of(context).settings.arguments;

      // Set user profile
      if (profile != null) {
        _profile = profile;
      }
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
          page: FollowerPage.tag,
          argument: _loading,
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
        leading: l,
        middle: new Text(
          'Followers',
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
          child: new ListView.builder(
            controller: _sc,
            physics: const ClampingScrollPhysics(),
            itemCount: _followers.length,
            itemBuilder: _followerBuilder,
          ),
        ),
      ),
    );
  }

  // Follower user widget builder
  Widget _followerBuilder(BuildContext context, int index) {
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
          _followers[index].photoUrl,
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
      _followers[index].username,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.black,
        fontSize: 16.0,
        letterSpacing: 0.33,
      ),
    );

    // Real name text
    final nm = new Text(
      _followers[index].name,
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
          dev.log('User "${_followers[index].username}" selected.');

          final u = _followers[index].username;

          // Route to profile page
          await Navigator.of(context).pushNamed(ProfilePage.tag, arguments: u);
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

  /// Get follower users
  void _getFollowers() async {
    dev.log('Follower users are loading.');

    // Handle HTTP response
    final sc = (FollowerUserResponse r) async {
      dev.log('Follower users request sent.');

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
          // Create network error
          _error = ErrorMessage.custom(r.message);
        }

        return;
      }

      // Update follower users
      _followers.addAll(r.users);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown followers load error. Please try again later.';

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
    final r = FollowerUserService.call(
      session: _session,
      username: _profile.username,
    );

    await r.then(sc).catchError(e).whenComplete(cc);
  }
}
