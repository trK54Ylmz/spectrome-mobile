import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/model/profile/user.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/profile/user.dart';
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

  // Loading indicator
  bool _loading = true;

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

  /// Get profile from API
  void _getProfile() async {
    dev.log('User rofile is loading.');

    // Handle HTTP response
    final sc = (UserProfileResponse r) async {
      dev.log('User profile request sent.');

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
    final s = UserProfileService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }
}
