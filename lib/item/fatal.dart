import 'package:flutter/cupertino.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/main.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/route.dart';

class Fatal extends StatelessWidget {
  final ErrorMessage error;

  final String page;

  const Fatal({
    this.error,
    this.page,
  })  : assert(page != null),
        assert(error != null);

  @override
  Widget build(BuildContext context) {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 13.0,
      letterSpacing: 0.33,
    );

    final icon = new Icon(
      new IconData(
        this.error.icon,
        fontFamily: FontConst.fa,
      ),
      color: ColorConst.gray,
      size: 32.0,
    );

    final message = new Padding(
      padding: EdgeInsets.only(top: 24.0),
      child: new Text(this.error.error, style: ts),
    );

    // Create route
    final route = new DefaultRoute(routes[this.page](context));

    // Add re-try button
    final button = new Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: new Button(
        width: 120.0,
        background: ColorConst.gray,
        onPressed: () => Navigator.of(context).pushReplacement(route),
        text: 'Try again',
      ),
    );

    // Handle error
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          message,
          button,
        ],
      ),
    );
  }
}
