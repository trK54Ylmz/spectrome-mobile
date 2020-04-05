import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:spectrome/page/guide.dart';
import 'package:spectrome/page/home.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/sign_up.dart';
import 'package:spectrome/page/timeline.dart';
import 'package:spectrome/util/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MainPage());

final routes = <String, WidgetBuilder>{
  GuidePage.tag: (c) => new GuidePage(),
  HomePage.tag: (c) => new HomePage(),
  SignInPage.tag: (c) => new SignInPage(),
  SignUpPage.tag: (c) => new SignUpPage(),
  TimeLinePage.tag: (c) => new TimeLinePage(),
};

class MainPage extends StatefulWidget {
  MainPage() : super();

  _MainState createState() => new _MainState();
}

class _MainState extends State<MainPage> {
  // Selected page tag
  String tag;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final cb = (SharedPreferences sp) {
      // Figure out the selected page
      final t = sp.containsKey('guided') ? HomePage.tag : GuidePage.tag;

      dev.log('Selected page is $t');

      setState(() => tag = t);
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

    return new CupertinoApp(
      title: 'Spectrome',
      debugShowCheckedModeBanner: false,
      home: tag == null ? loading : routes[tag](context),
      routes: routes,
    );
  }
}
