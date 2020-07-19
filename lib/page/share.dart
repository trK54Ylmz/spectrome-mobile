import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/camera.dart';
import 'package:spectrome/item/gallery.dart';
import 'package:spectrome/theme/color.dart';

class SharePage extends StatefulWidget {
  static final tag = 'share';

  SharePage() : super();

  @override
  _ShareState createState() => new _ShareState();
}

class _ShareState extends State<SharePage> {
  // Camera widget
  final _camera = new Camera();

  // Gallery widget
  final _gallery = new Gallery();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final totalHeight = MediaQuery.of(context).size.height;
    final paddings = MediaQuery.of(context).padding;
    final extras = paddings.bottom + paddings.top;
    final h = totalHeight - extras - w - 1.0;

    return Scaffold(
      backgroundColor: ColorConst.white,
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: w,
            height: w,
            child: _camera,
          ),
          new Padding(padding: EdgeInsets.only(top: 1.0)),
          new Container(
            width: w,
            height: h,
            child: _gallery,
          )
        ],
      ),
    );
  }
}
