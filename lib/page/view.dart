import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/page/home.dart';
import 'package:spectrome/page/select.dart';
import 'package:spectrome/theme/color.dart';

class ViewPage extends StatefulWidget {
  static final tag = 'view';

  ViewPage() : super();

  @override
  _ViewState createState() => new _ViewState();
}

class _ViewState extends State<ViewPage> {
  // Select home page as initial page
  final _pc = new PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new PageView(
        controller: _pc,
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          new SelectPage(),
          new HomePage(),
        ],
      ),
    ); 
  }
}