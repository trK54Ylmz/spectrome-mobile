import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class RestrictionPage extends StatefulWidget {
  static final tag = 'restriction';

  RestrictionPage() : super();

  _RestrictionState createState() => new _RestrictionState();
}

class _RestrictionState extends State<RestrictionPage> {
  // Search input controller
  final _sc = new TextEditingController();

  // List of selected users
  final _users = <String>[];

  @override
  Widget build(BuildContext context) {
    final users = ModalRoute.of(context).settings.arguments;
    if (users != null) {
      _users.addAll(users);
    }

    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
    );

    final hs = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
      color: ColorConst.gray,
      fontWeight: FontWeight.normal,
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.only(top: 4.0, bottom: 4.0),
        backgroundColor: ColorConst.white,
        leading: new GestureDetector(
          onTap: () => Navigator.of(context).pop(_users),
          child: new Icon(
            IconData(0xf104, fontFamily: FontConst.fal),
            color: ColorConst.darkerGray,
          ),
        ),
        middle: new FormText(
          hint: 'Type username',
          hintStyle: hs,
          style: ts,
          controller: _sc,
          borderColor: ColorConst.gray,
        ),
      ),
      child: new Container(),
    );
  }
}
