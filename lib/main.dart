import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/page/activation.dart';
import 'package:spectrome/page/forgot.dart';
import 'package:spectrome/page/guide.dart';
import 'package:spectrome/page/home.dart';
import 'package:spectrome/page/me.dart';
import 'package:spectrome/page/profile.dart';
import 'package:spectrome/page/restriction.dart';
import 'package:spectrome/page/session.dart';
import 'package:spectrome/page/invite.dart';
import 'package:spectrome/page/reset.dart';
import 'package:spectrome/page/select.dart';
import 'package:spectrome/page/share.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/sign_up.dart';
import 'package:spectrome/page/sign_up_done.dart';
import 'package:spectrome/page/view.dart';
import 'package:spectrome/page/waterfall.dart';
import 'package:spectrome/page/version.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MainPage());

final routes = <String, WidgetBuilder>{
  ForgotPage.tag: (c) => new ForgotPage(),
  GuidePage.tag: (c) => new GuidePage(),
  HomePage.tag: (c) => new HomePage(),
  InvitePage.tag: (c) => new InvitePage(),
  MePage.tag: (c) => new MePage(),
  ProfilePage.tag: (c) => new ProfilePage(),
  ResetPage.tag: (c) => new ResetPage(),
  RestrictionPage.tag: (c) => new RestrictionPage(),
  SessionPage.tag: (c) => new SessionPage(),
  SelectPage.tag: (c) => new SelectPage(),
  SharePage.tag: (c) => new SharePage(),
  SignInPage.tag: (c) => new SignInPage(),
  SignUpPage.tag: (c) => new SignUpPage(),
  SignUpDonePage.tag: (c) => new SignUpDonePage(),
  ActivationPage.tag: (c) => new ActivationPage(),
  WaterFallPage.tag: (c) => new WaterFallPage(),
  VersionPage.tag: (c) => new VersionPage(),
  ViewPage.tag: (c) => new ViewPage(),
};

class MainPage extends StatefulWidget {
  MainPage() : super();

  _MainState createState() => new _MainState();
}

class _MainState extends State<MainPage> {
  // If API domain selected
  bool _domain = false;

  // Custom API domain error
  bool _error = false;

  // Selected page tag
  String _tag;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final cb = (SharedPreferences sp) {
      // Figure out the selected page
      final t = sp.containsKey('guided') ? VersionPage.tag : GuidePage.tag;

      dev.log('Selected page is $t');

      setState(() => _tag = t);
    };

    // Load shared preferences
    Storage.load().then(cb);
  }

  @override
  Widget build(BuildContext context) {
    // Change UI appearance according to platform
    if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    } else {
      const w = const Color(0xffffffff);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: w,
          systemNavigationBarDividerColor: w,
          statusBarColor: w,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }

    // Define theme
    final theme = CupertinoThemeData(
      scaffoldBackgroundColor: ColorConst.white,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: ColorConst.dark,
        ),
      ),
    );

    if (kReleaseMode) {
      // Select API endpoint domain, if app is in release mode
      return new CupertinoApp(
        title: 'Spectrome',
        debugShowCheckedModeBanner: false,
        home: _tag == null ? const Loading() : routes[_tag](context),
        routes: routes,
        theme: theme,
      );
    } else {
      // Select API endpoint domain, if app not in release mode
      return new CupertinoApp(
        title: 'Spectrome',
        debugShowCheckedModeBanner: false,
        home: _tag == null ? const Loading() : _getDevelop(),
        routes: routes,
        theme: theme,
      );
    }
  }

  /// Get develop widgets for main page
  Widget _getDevelop() {
    // Show loading indicator if any tag have not selected yet
    if (_tag == null) {
      return const Loading();
    }

    // Show domain name selector widgets
    // This will be used only for development purposes
    if (!_domain) {
      final pt = const Padding(
        padding: EdgeInsets.only(top: 8.0),
      );

      final t = new Text(
        'Please select API domain',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkGray,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
      );

      // Default API domain button
      final b = new Button(
        text: 'Default',
        onPressed: () {
          Http.domain = 'api.spectrome.app';

          setState(() => _domain = true);
        },
      );

      final controller = new TextEditingController();
      final cb = (i) {
        if (i == null || i.length == 0) {
          controller.text = '192.168.1.';
        }
      };

      // Fill IP controller after 3 seconds if empty
      Future.delayed(Duration(seconds: 2)).then(cb);

      final ip = FormText(
        hint: '192.168.X.Y',
        inputType: TextInputType.number,
        controller: controller,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
        hintStyle: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: ColorConst.gray,
        ),
        borderColor: _error ? ColorConst.darkRed : ColorConst.gray,
      );

      // Default API domain button
      final ib = new Button(
        text: 'Custom',
        onPressed: () {
          if (ip.controller.text.length == 0) {
            setState(() => _error = true);
            return;
          }

          setState(() => _error = false);

          // Set custom http client parameters
          Http.domain = ip.controller.text;
          Http.client.badCertificateCallback = (c, h, p) => true;

          setState(() => _domain = true);
        },
      );

      return new Container(
        color: ColorConst.white,
        child: new Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 100.0,
            vertical: 16.0,
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              t,
              pt,
              b,
              pt,
              pt,
              ip,
              pt,
              ib,
            ],
          ),
        ),
      );
    }

    // Select route and redirect
    return routes[_tag](context);
  }
}
