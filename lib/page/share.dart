import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/video.dart';
import 'package:spectrome/page/view.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';

class SharePage extends StatefulWidget {
  static final tag = 'share';

  SharePage() : super();

  @override
  _ShareState createState() => new _ShareState();
}

class _ShareState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    final List<File> files = ModalRoute.of(context).settings.arguments;

    final _cb = new Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: new Text(
        'Cancel',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: ColorConst.darkRed,
        ),
      ),
    );

    final _sb = new Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: new Text(
        'Share',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: ColorConst.darkerGray,
        ),
      ),
    );

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: ColorConst.white,
        border: Border(
          top: BorderSide(
            color: ColorConst.gray.withOpacity(0.67),
            width: 0.5,
          ),
        ),
        onTap: (index) async {
          if (index == 0) {
            await Navigator.of(context).pushReplacementNamed(ViewPage.tag);
          } else {}
        },
        items: [
          BottomNavigationBarItem(
            icon: _cb,
            activeIcon: _cb,
          ),
          BottomNavigationBarItem(
            icon: _sb,
            activeIcon: _sb,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return _getForm(files);
      },
    );
  }

  /// Get share form
  Widget _getForm(List<File> files) {
    final width = MediaQuery.of(context).size.width;

    Widget w;
    if (files.length > 1) {
      final items = <Widget>[];

      for (int i = 0; i < files.length; i++) {
        final c = new Container(
          width: width,
          height: width,
          decoration: new BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ColorConst.gray.withOpacity(0.67),
                width: 0.5,
              ),
              bottom: BorderSide(
                color: ColorConst.gray.withOpacity(0.67),
                width: 0.5,
              ),
            ),
          ),
          child: new ClipRect(
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: _getItem(files[i]),
              ),
            ),
          ),
        );

        items.add(c);
      }

      w = new Container(
        width: width,
        height: width,
        child: new PageView(
          physics: const ClampingScrollPhysics(),
          children: items,
        ),
      );
    } else {
      w = new Container(
        width: width,
        height: width,
        decoration: new BoxDecoration(
          border: Border(
            top: BorderSide(
              color: ColorConst.gray.withOpacity(0.67),
              width: 0.5,
            ),
            bottom: BorderSide(
              color: ColorConst.gray.withOpacity(0.67),
              width: 0.5,
            ),
          ),
        ),
        child: new ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: _getItem(files[0]),
            ),
          ),
        ),
      );
    }

    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          w,
        ],
      ),
    );
  }

  /// Get file widget according to it's type
  Widget _getItem(File file) {
    final type = file.path.split('.').last == 'jpg' ? AppConst.photo : AppConst.video;

    if (type == AppConst.video) {
      return new Video(path: file.path, type: VideoType.FILE);
    } else {
      return new Image.file(file);
    }
  }
}
