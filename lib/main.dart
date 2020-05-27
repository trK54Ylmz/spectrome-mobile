import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/input.dart' as i;
import 'package:spectrome/page/activation.dart';
import 'package:spectrome/page/guide.dart';
import 'package:spectrome/page/home.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/sign_up.dart';
import 'package:spectrome/page/timeline.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MainPage());

final routes = <String, WidgetBuilder>{
  GuidePage.tag: (c) => new GuidePage(),
  HomePage.tag: (c) => new HomePage(),
  SignInPage.tag: (c) => new SignInPage(),
  SignUpPage.tag: (c) => new SignUpPage(),
  ActivationPage.tag: (c) => new ActivationPage(),
  TimeLinePage.tag: (c) => new TimeLinePage(),
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
      final t = sp.containsKey('guided') ? HomePage.tag : GuidePage.tag;

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

    if (kReleaseMode) {
      final loading = new Container(
        color: const Color(0xffffffff),
        child: new Center(
          child: new Image.asset(
            'assets/images/loading.gif',
            width: 60.0,
            height: 60.0,
          ),
        ),
      );

      // Select API endpoint domain, if app is in release mode
      return new CupertinoApp(
        title: 'Spectrome',
        debugShowCheckedModeBanner: false,
        home: _tag == null ? loading : routes[_tag](context),
        routes: routes,
      );
    } else {
      final pt = const Padding(
        padding: EdgeInsets.only(top: 8.0),
      );

      // Figure out the widget
      Widget w;
      if (_tag == null) {
        w = new Container(
          color: const Color(0xffffffff),
          child: new Center(
            child: new Image.asset(
              'assets/images/loading.gif',
              width: 60.0,
              height: 60.0,
            ),
          ),
        );
      } else if (!_domain) {
        final t = new Text(
          'Please select API domain',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            color: ColorConst.darkGrayColor,
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

        final ip = i.TextInput(
          hint: '192.168.X.Y',
          inputType: TextInputType.number,
          controller: new TextEditingController(),
          style: new TextStyle(
            fontFamily: FontConst.primary,
            fontSize: 14.0,
            letterSpacing: 0.33,
          ),
          hintStyle: new TextStyle(
            fontFamily: FontConst.primary,
            fontSize: 14.0,
            letterSpacing: 0.33,
            color: ColorConst.grayColor,
          ),
          borderColor: _error ? ColorConst.darkRed : ColorConst.grayColor,
        );

        // Default API domain button
        final ib = new Button(
          text: 'Custom',
          width: 160.0,
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

        w = new Container(
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
      } else {
        w = routes[_tag](context);
      }

      // Select API endpoint domain, if app not in release mode
      return new CupertinoApp(
        title: 'Spectrome',
        debugShowCheckedModeBanner: false,
        home: w,
        routes: routes,
      );
    }
  }
}
