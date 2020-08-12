import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/model/profile/me.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/profile/me.dart';
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
      body: new Container(
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

    // Http headers for image request
    final h = {Http.CONTENT_HEADER: _session};

    // Profile picture
    final p = new Padding(
      padding: EdgeInsets.all(10.0),
      child: new Container(
        width: 40,
        height: 40,
        child: new CachedNetworkImage(
          imageUrl: _profile.photoUrl,
          httpHeaders: h,
        ),
      ),
    );

    final i = new Padding(
      padding: EdgeInsets.all(10.0),
      child: new Container(
        width: width - 40.0,
        height: 40.0,
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

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        f,
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
}
