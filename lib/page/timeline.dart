import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class TimeLinePage extends StatefulWidget {
  static final tag = 'timeline';

  TimeLinePage() : super();

  @override
  _TimeLineState createState() => new _TimeLineState();
}

class _TimeLineState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SingleChildScrollView(
        child: new Container(
          
        ),
      ),
    );
  }
}
