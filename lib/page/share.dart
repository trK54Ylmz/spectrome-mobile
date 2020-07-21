import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spectrome/item/button.dart';
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

  // Temporary directory
  Directory _temp;

  // Camera is active or not
  bool _ca = false;

  // Gallery is active or not
  bool _ga = false;

  @override
  void initState() {
    super.initState();

    // Update camera activity
    _camera.currentState.active.addListener(() {
      setState(() => _ca = _camera.currentState.active.value);
    });

    // Update gallery activity
    _gallery.currentState.active.addListener(() {
      setState(() => _ga = _gallery.currentState.active.value);
    });

    // Directory callback
    final c = (Directory d) {
      // Remove temporary directory if exists
      if (d.existsSync()) {
        // Remove temporary directory
        d.deleteSync(recursive: true);

        // Create temporary directory
        d.createSync();
      }

      setState(() => _temp = d);
    };

    // Get temporary directory
    getTemporaryDirectory().then(c);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final totalHeight = MediaQuery.of(context).size.height;
    final paddings = MediaQuery.of(context).padding;
    final extras = paddings.bottom + paddings.top;
    final h = totalHeight - extras - w - 51.5;

    final pt = new Padding(
      padding: EdgeInsets.only(top: 1.0),
    );

    // Next button
    final b = new Button(
      text: 'Next',
      color: ColorConst.dark,
      background: ColorConst.white,
      width: w,
      onPressed: _next,
      disabled: !(_ca ^ _ga) || _temp == null,
      radius: BorderRadius.zero,
      padding: EdgeInsets.all(16.0),
      border: new Border(
        top: BorderSide(
          width: 0.5,
          color: ColorConst.grayColor,
        ),
      ),
    );

    final ci = <Widget>[
      new Container(width: w, height: w, child: _camera),
    ];

    // Disable camera if gallery is active
    if (_ga) {
      final dc = new Container(
        width: w,
        height: w,
        color: ColorConst.grayColor,
      );

      ci.add(dc);
    }

    // Camera widget
    final c = new Stack(
      alignment: Alignment.topLeft,
      children: ci,
    );

    final gi = <Widget>[
      new Container(width: w, height: h, child: _gallery),
    ];

    // Disable gallery if camera is active
    if (_ca) {
      final dc = new Container(
        width: w,
        height: h,
        color: ColorConst.grayColor,
      );

      gi.add(dc);
    }

    // Gallery widget
    final g = new Stack(
      fit: StackFit.loose,
      children: gi,
    );

    return Scaffold(
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            c,
            pt,
            g,
            b,
          ],
        ),
      ),
    );
  }

  /// Move to next stop on share
  void _next() {
   
  }
}
