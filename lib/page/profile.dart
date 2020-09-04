import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/model/profile/user.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/profile/user.dart';
import 'package:spectrome/service/user/cancel.dart';
import 'package:spectrome/service/user/follow.dart';
import 'package:spectrome/service/user/unfollow.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';

class ProfilePage extends StatefulWidget {
  static final tag = 'profile';

  ProfilePage() : super();

  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Account session key
  String _session;

  // Username of current user
  String _username;

  // Error message
  ErrorMessage _error;

  // Profile object
  UserProfile _profile;

  // Is user following
  bool _followed = false;

  // Is following request sent
  bool _requested = false;

  // Loading indicator
  bool _loading = true;

  // Action loading indicator
  bool _action = false;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      final session = s.getString('_session');

      _session = session;

      // Load profile from API
      _getProfile();
    };

    // Username argument callback
    final ac = (_) {
      final username = ModalRoute.of(context).settings.arguments;

      // Set username
      _username = username;

      // Get storage kv
      Storage.load().then(spc);
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
          page: ProfilePage.tag,
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

    final pts = const Padding(
      padding: EdgeInsets.only(top: 4.0),
    );

    final pt = const Padding(
      padding: EdgeInsets.only(top: 8.0),
    );

    // Http headers for image request
    final h = {Http.TOKEN_HEADER: _session};

    // Profile picture
    final p = new Padding(
      padding: EdgeInsets.all(8.0),
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
            child: new Image.network(
              _profile.photoUrl,
              headers: h,
              width: 60.0,
              height: 60.0,
              errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
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
        fontSize: 14.0,
        letterSpacing: 0.33,
      ),
    );

    // Profile details
    final i = new Padding(
      padding: EdgeInsets.only(left: 20.0),
      child: new Container(
        width: width - ((hp * 3) + 38.0 + 1.0),
        height: 48.0,
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
      flex: 1,
      fit: FlexFit.tight,
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: new RichText(
          textAlign: TextAlign.left,
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
      flex: 1,
      fit: FlexFit.tight,
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: new RichText(
          textAlign: TextAlign.center,
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
      flex: 1,
      fit: FlexFit.tight,
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: new RichText(
          textAlign: TextAlign.right,
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

    // Following, followers and settings
    final d = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ps,
        fr,
        to,
      ],
    );

    final fl = new Button(
      text: 'Follow',
      disabled: _action,
      fontSize: 13.0,
      padding: EdgeInsets.all(6.0),
      background: ColorConst.button,
      color: ColorConst.white,
      border: new Border.all(
        color: ColorConst.button,
      ),
      onPressed: _follow,
    );

    final rq = new Button(
      text: 'Request sent',
      disabled: _action,
      fontSize: 13.0,
      padding: EdgeInsets.all(6.0),
      background: ColorConst.transparent,
      color: ColorConst.darkGray,
      border: new Border.all(
        color: ColorConst.gray,
      ),
      onPressed: _cancel,
    );

    final uf = new Button(
      text: 'Unfollow',
      disabled: _action,
      fontSize: 13.0,
      padding: EdgeInsets.all(6.0),
      background: ColorConst.button,
      color: ColorConst.white,
      border: new Border.all(
        color: ColorConst.button,
      ),
      onPressed: _unfollow,
    );

    final fb = new Expanded(
      flex: 1,
      child: new Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: _followed ? uf : _requested ? rq : fl,
      ),
    );

    // Follow button container
    final b = new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          fb,
        ],
      ),
    );

    // User detail container
    final u = new Container(
      height: 168.0,
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: ColorConst.gray,
          ),
        ),
      ),
      child: new Padding(
        padding: EdgeInsets.only(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
          top: 0.0,
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            f,
            pt,
            d,
            pt,
            b,
          ],
        ),
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
        leading: new GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: new Icon(
            IconData(0xf104, fontFamily: FontConst.fal),
            color: ColorConst.darkerGray,
          ),
        ),
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          u,
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

  /// Get profile from API
  void _getProfile() async {
    dev.log('User rofile is loading.');

    // Handle HTTP response
    final sc = (UserProfileResponse r) async {
      dev.log('User profile request sent.');

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
      _profile = r.profile;
      _requested = r.request;
      _followed = r.follow;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown profile load error. Please try again later.';

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
    final s = UserProfileService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }

  /// Follow user
  void _follow() async {
    dev.log('Follow button clicked.');

    if (_action) {
      return;
    }

    setState(() => _action = true);

    dev.log('Follow request sending.');

    final sc = (FollowingResponse r) async {
      dev.log('Follow request sent.');

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

      // Set request sent
      _requested = true;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown follow error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _action = false);
    };

    // Prepare request
    final s = FollowingService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }

  /// Unfollow current user
  void _unfollow() async {
    dev.log('Unfollow button clicked.');

    if (_action) {
      return;
    }

    setState(() => _action = true);

    dev.log('Unfollow request sending.');

    final sc = (UnfollowingResponse r) async {
      dev.log('Unfollow request sent.');

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

      // Set following as false
      _followed = false;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown unfollow error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _action = false);
    };

    // Prepare request
    final s = UnfollowingService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }

  /// Cancel follow request
  void _cancel() async {
    dev.log('Intention cancel button clicked.');

    if (_action) {
      return;
    }

    setState(() => _action = true);

    dev.log('Intention cancel request sending.');

    final sc = (IntentionCancelResponse r) async {
      dev.log('Intention cancel request sent.');

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

      // Set request sent as false
      _requested = false;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown cancel error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _action = false);
    };

    // Prepare request
    final s = IntentionCancelService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }
}
