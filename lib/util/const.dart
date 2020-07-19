import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/error.dart';

class AppConst {
  static const version = 0.1;

  /// Get widget according to scenario
  static Widget loader(
    BuildContext context,
    bool loading,
    ErrorMessage error,
    Function callback,
  ) {
    // Get loading indicator
    if (loading) return AppConst.loading();

    // Get error page
    if (error != null) return AppConst.fatal(context, error);

    return callback.call();
  }

  /// Get shimmer widget
  static Widget shimmer() {
    return new Container(

    );
  }

  /// Get loading indicator
  static Widget loading() {
    return new Container(
      color: ColorConst.white,
      child: new Center(
        child: new Image.asset(
          'assets/images/loading.gif',
          width: 60.0,
          height: 60.0,
        ),
      ),
    );
  }

  /// Get error page
  ///
  /// Build context is required for re-routing
  static Widget fatal(BuildContext context, ErrorMessage e) {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
    );

    final icon = new Icon(
      new IconData(
        e.icon,
        fontFamily: FontConst.fa,
      ),
      color: ColorConst.grayColor,
      size: 32.0,
    );

    final message = new Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: new Text(e.error, style: ts),
    );

    // Add re-try button
    final button = new Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: new CupertinoButton(
        color: ColorConst.grayColor,
        onPressed: () => Navigator.of(context).pushReplacementNamed(SignInPage.tag),
        child: new Text(
          'Try again',
          style: new TextStyle(
            color: ColorConst.white,
            fontFamily: FontConst.primary,
            fontSize: 14.0,
            letterSpacing: 0.33,
          ),
        ),
      ),
    );

    // Handle error
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        icon,
        message,
        button,
      ],
    );
  }

  /// Get error widget
  static Widget error(String message) {
    return SizedBox.expand(
      child: new Center(
        child: new Text(
          message,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            fontSize: 14.0,
            letterSpacing: 0.33,
          ),
        ),
      ),
    );
  }
}
