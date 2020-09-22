import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/model/profile/me.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/profile/me.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class UpdatePage extends StatefulWidget {
  static final tag = 'update';

  UpdatePage() : super();

  @override
  _UpdateState createState() => new _UpdateState();
}

class _UpdateState extends State<UpdatePage> {
    // Form validation key
  final _fk = new GlobalKey<FormValidationState>();

  // User real name input controller
  final _name = new TextEditingController();

  // Loading indicator
  bool _loading = true;

  // Error message
  ErrorMessage _error;

  // Account session key
  String _session;

  // Profile object
  MyProfile _profile;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      final session = s.getString('_session');

      setState(() => _session = session);

      // Load profile if exists in the cache
      _getProfile();
    };

    Storage.load().then(spc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: AppConst.loader(
          page: UpdatePage.tag,
          argument: _loading,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get content of the version page
  Widget _getPage() {
    final pt = const Padding(
      padding: EdgeInsets.only(top: 8.0),
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

    // Create user name input
    final name = new FormText(
      hint: 'Name',
      controller: _name,
      style: ts,
      hintStyle: hs,
      validator: (i) {
        if (i.length == 0) {
          return 'The name is required.';
        }

        if (i.runes.length < 4) {
          return 'The name cannot be lower than 4 character.';
        }

        if (i.runes.length > 50) {
          return 'The name cannot be higher than 50 character.';
        }

        return null;
      },
    );

    // Profile update submit button
    final sub = new Button(
      text: 'Sign Up',
      disabled: _loading,
      onPressed: _update,
    );

    final form = new FormValidation(
      key: _fk,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          pt,
          name,
          pt,
          sub,
          pt,
        ],
      ),
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        heroTag: 8,
        transitionBetweenRoutes: false,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        backgroundColor: ColorConst.white,
        border: new Border(bottom: BorderSide.none),
        middle: new Text(
          'Update',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
            fontSize: 16.0,
          ),
        ),
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
          form,
        ],
      ),
    );
  }

  /// Get profile from API
  void _getProfile() async {
    dev.log('Profile is loading.');

    // Handle HTTP response
    final sc = (MyProfileResponse r) async {
      dev.log('My profile request sent.');

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

      // Update profile instance
      _profile = r.profile;

      // Set name of the user
      _name.text = _profile.name;
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

    await MyProfileService.call(_session).then(sc).catchError(e).whenComplete(cc);
  }

  void _update() async {}
}
