import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:spectrome/pages/home.dart';

void main() => runApp(App());

final routes = <String, WidgetBuilder>{
  HomePage.tag: (c) => new HomePage(),
};

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Change UI appearance according to platform
    if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xffffffff),
          systemNavigationBarDividerColor: Color(0xffffffff),
          statusBarColor: Color(0xffffffff),
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
