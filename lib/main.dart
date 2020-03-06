import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:spectrome/page/home.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/sign_up.dart';

void main() => runApp(App());

final routes = <String, WidgetBuilder>{
  HomePage.tag: (c) => new HomePage(),
  SignInPage.tag: (c) => new SignInPage(),
  SignUpPage.tag: (c) => new SignUpPage(),
};

class App extends StatelessWidget {
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

    return new CupertinoApp(
      title: 'Spectrome',
      debugShowCheckedModeBanner: false,
      home: new HomePage(),
      routes: routes,
    );
  }
}
