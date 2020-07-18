import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/theme/color.dart';

class MePage extends StatefulWidget {
  static final tag = 'me';

  MePage() : super();

  @override
  _MeState createState() => new _MeState();
}

class _MeState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.white,
    );
  }
}