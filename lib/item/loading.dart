import 'package:flutter/cupertino.dart';
import 'package:spectrome/theme/color.dart';

class Loading extends StatelessWidget {
  final double width;

  final double height;

  final double iconWidth;

  final double iconHeight;

  final Color color;

  const Loading({
    this.width,
    this.height,
    this.iconWidth = 60.0,
    this.iconHeight = 60.0,
    this.color = ColorConst.white,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: this.width,
      height: this.height,
      color: this.color,
      child: new Center(
        child: new Image.asset(
          'assets/images/loading.gif',
          width: this.iconWidth,
          height: this.iconHeight,
        ),
      ),
    );
  }
}
