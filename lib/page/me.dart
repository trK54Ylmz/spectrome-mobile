import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/profile/me.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/account/sign_out.dart';
import 'package:spectrome/service/profile/me.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';

class MePage extends StatefulWidget {
  static final tag = 'me';

  MePage() : super();

  @override
  _MeState createState() => new _MeState();
}

class _MeState extends State<MePage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Loading indicator
  bool _loading = true;

  // Shared preferences instance
  SharedPreferences _sp;

  // Account session key
  String _session;

  // Error message
  ErrorMessage _error;

  // Profile object
  MyProfile _profile;

  // Settings overlay entry
  OverlayEntry _oe;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      final session = s.getString('_session');

      setState(() => _session = session);

      _sp = s;

      // Load profile if exists in the cache
      _loadProfile();

      // Load profile from API
      _getProfile();
    };

    Storage.load().then(spc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: AppConst.loader(
          page: MePage.tag,
          argument: _loading,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
    final width = MediaQuery.of(context).size.width;
    final hp = width > 400.0 ? 64.0 : 32.0;
    final hps = width > 400.0 ? 32.0 : 16.0;

    final pts = const Padding(
      padding: EdgeInsets.only(top: 4.0),
    );

    final pt = const Padding(
      padding: EdgeInsets.only(top: 8.0),
    );

    // Http headers for image request
    final h = {Http.CONTENT_HEADER: _session};

    // Profile picture
    final p = new Padding(
      padding: EdgeInsets.all(hps),
      child: new Container(
        decoration: new BoxDecoration(
          border: new Border.all(
            width: 0.5,
            color: ColorConst.gray.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        child: new ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: new Container(
            width: 60.0,
            height: 60.0,
            child: new CachedNetworkImage(
              width: 60.0,
              height: 60.0,
              imageUrl: _profile.photoUrl,
              httpHeaders: h,
              fadeInDuration: Duration.zero,
              placeholder: (c, u) => new Loading(width: 60.0, height: 60.0),
              errorWidget: (c, u, e) => new Image.asset('assets/images/default.1.webp'),
            ),
          ),
        ),
      ),
    );

    final un = new Text(
      _profile.username,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.black,
        fontSize: 16.0,
        letterSpacing: 0.33,
      ),
    );

    final nm = new Text(
      _profile.name,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.darkGray,
        fontSize: 16.0,
        letterSpacing: 0.33,
      ),
    );

    // Profile details
    final i = new Padding(
      padding: EdgeInsets.all(hps),
      child: new Container(
        width: width - ((hp * 3) + 60.0 + 1.0),
        height: 60.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            un,
            pts,
            nm,
          ],
        ),
      ),
    );

    final f = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        p,
        i,
      ],
    );

    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
      color: ColorConst.darkerGray,
      fontWeight: FontWeight.bold,
    );

    final sts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      color: ColorConst.gray,
      fontWeight: FontWeight.normal,
    );

    // Posts count text
    final ps = new Flexible(
      flex: 2,
      fit: FlexFit.tight,
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: new RichText(
          text: new TextSpan(
            text: _profile.posts.toString(),
            style: ts,
            children: [
              new TextSpan(
                text: '  Posts',
                style: sts,
              ),
            ],
          ),
        ),
      ),
    );

    // Following count text
    final fr = new Flexible(
      flex: 3,
      fit: FlexFit.tight,
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: new RichText(
          overflow: TextOverflow.visible,
          text: new TextSpan(
            text: _profile.followings.toString(),
            style: ts,
            children: [
              new TextSpan(
                text: '  Followings',
                style: sts,
              ),
            ],
          ),
        ),
      ),
    );

    // Followers count text
    final to = new Flexible(
      flex: 3,
      fit: FlexFit.tight,
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: new RichText(
          text: new TextSpan(
            text: _profile.followers.toString(),
            style: ts,
            children: [
              new TextSpan(
                text: '  Followers',
                style: sts,
              ),
            ],
          ),
        ),
      ),
    );

    // Settings button
    final st = new Expanded(
      flex: 1,
      child: new Semantics(
        button: true,
        child: new GestureDetector(
          onTap: _showSettings,
          child: new Icon(
            IconData(
              0xf141,
              fontFamily: FontConst.fal,
            ),
            color: ColorConst.darkGray,
            size: 32.0,
          ),
        ),
      ),
    );

    // Following, followers and settings
    final d = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ps,
        fr,
        to,
        st,
      ],
    );

    // User detail container
    final u = new Container(
      height: 180.0,
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: ColorConst.gray,
          ),
        ),
      ),
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            pt,
            f,
            pt,
            d,
            pt,
          ],
        ),
      ),
    );

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        u,
      ],
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

  /// Show settings overlay
  void _showSettings() {
    _oe = OverlayEntry(builder: (BuildContext context) {
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;

      final hr = new Divider(
        color: ColorConst.gray,
        height: 1.0,
      );

      final eb = new Button(
        color: ColorConst.button,
        background: ColorConst.transparent,
        radius: BorderRadius.zero,
        text: 'Edit profile',
        onPressed: _editProfile,
      );

      final sb = new Button(
        color: ColorConst.darkRed,
        background: ColorConst.transparent,
        radius: BorderRadius.zero,
        text: 'Sign Out',
        onPressed: _signOut,
      );

      final cb = new Button(
        color: ColorConst.darkGray,
        background: ColorConst.transparent,
        radius: BorderRadius.zero,
        text: 'Close',
        onPressed: _closeSettings,
      );

      // List of buttons
      final it = new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          eb,
          hr,
          sb,
          hr,
          cb,
        ],
      );

      return new Container(
        width: width,
        height: height,
        color: ColorConst.darkerGray.withOpacity(0.67),
        child: new Center(
          child: new FittedBox(
            child: new Container(
              width: width - 120,
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: ColorConst.lightGray,
              ),
              child: new Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: it,
              ),
            ),
          ),
        ),
      );
    });

    // Show overlay
    Overlay.of(context).insert(_oe);
  }

  /// Close settings
  void _closeSettings() {
    if (_oe == null) {
      return;
    }

    // Remove overlay from page
    _oe.remove();
    _oe = null;
  }

  /// Load profile data from cache
  void _loadProfile() {
    // Check if profile is in the cache
    if (!_sp.containsKey('_me')) {
      return;
    }

    final pb = _sp.getString('_me');

    // Decode profile string
    _profile = MyProfile.fromJson(pb);

    // Load profile
    setState(() => _loading = false);
  }

  /// Get profile from API
  void _getProfile() {
    dev.log('Profile is loading.');

    // Handle HTTP response
    final sc = (MyProfileResponse r) async {
      dev.log('My profile request sent.');

      if (!r.status) {
        // Route to sign page, if session is expired
        if (r.expired) {
          await Navigator.of(context).pushReplacementNamed(SignInPage.tag);
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
      _profile = r.profile;

      // Update profile cache
      _sp.setString('_me', r.profile.toJson());
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

    MyProfileService.call(_session).then(sc).catchError(e).whenComplete(cc);
  }

  /// Go to profile edit page
  void _editProfile() async {
    await Navigator.of(context).pushNamed(MePage.tag);
  }

  /// Sign out from current session
  void _signOut() {
    // Handle HTTP response
    final sc = (BasicResponse r) async {
      dev.log('Sign in request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _showSnackBar(r.message, isError: true);
        }

        return;
      }

      // Create new auth key
      _sp.remove('_session');
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    // Complete callback
    final cc = () async {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      await Navigator.of(context).pushReplacementNamed(SignInPage.tag);
    };

    SignOutService.call().then(sc).catchError(e).whenComplete(cc);
  }
}
