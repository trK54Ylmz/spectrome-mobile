import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/page/home.dart';
import 'package:spectrome/page/me.dart';
import 'package:spectrome/page/share.dart';
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
        children: <Widget>[
          new SharePage(),
          new HomePage(),
          new MePage(),
        ],
      ),
    ); 
  }
}