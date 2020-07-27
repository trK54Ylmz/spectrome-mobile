import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/video.dart';
import 'package:spectrome/page/view.dart';
import 'package:spectrome/service/share/share.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:vector_math/vector_math_64.dart';

class SharePage extends StatefulWidget {
  static final tag = 'share';

  SharePage() : super();

  @override
  _ShareState createState() => new _ShareState();
}

class _ShareState extends State<SharePage> {
  final _sk = GlobalKey<ScaffoldState>();

  // Comment input controller
  final _cc = new TextEditingController();

  // Scale group of items
  final _scales = <double>[];

  // Is page view scrollable
  bool _scrollable = true;

  // Loading indicator
  bool _loading = false;

  // Error message
  ErrorMessage _error;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return new Container(
        color: ColorConst.white,
        child: AppConst.loading(),
      );
    }

    if (_error != null) {
      return AppConst.fatal(context, _error);
    }

    final List<File> files = ModalRoute.of(context).settings.arguments;
    if (_scales.isEmpty) {
      final l = new List<double>.generate(files.length, (_) => 1);
      _scales.addAll(l);
    }

    return _getPage(files);
  }

  /// Get page widget
  Widget _getPage(List<File> files) {
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
      key: _sk,
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
          } else {
            setState(() => _loading = true);

            // Create post
            await _share(files);
          }
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
        // Create resizable photo or video widget
        Widget b;
        if (_scales.elementAt(i) == 1.0) {
          b = new FittedBox(
            fit: BoxFit.cover,
            child: _getItem(files[i]),
          );
        } else {
          b = new Transform(
            transform: new Matrix4.diagonal3(
              new Vector3(
                _scales[i],
                _scales[i],
                _scales[i],
              ),
            ),
            alignment: AlignmentDirectional.center,
            child: _getItem(files[i]),
          );
        }

        final c = new GestureDetector(
          onScaleStart: _scaleStart,
          onScaleEnd: _scaleEnd,
          onScaleUpdate: (d) => _scaleUpdate(d, i),
          child: new Container(
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
                child: b,
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
          physics: _scrollable ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
          children: items,
        ),
      );
    } else {
      // Create resizable photo or video widget
      Widget b;
      if (_scales.elementAt(0) == 1.0) {
        b = new FittedBox(
          fit: BoxFit.cover,
          child: _getItem(files[0]),
        );
      } else {
        b = new Transform(
          transform: new Matrix4.diagonal3(
            new Vector3(
              _scales[0],
              _scales[0],
              _scales[0],
            ),
          ),
          alignment: AlignmentDirectional.center,
          child: _getItem(files[0]),
        );
      }

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
            child: b,
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

  /// Show error when error not empty
  void _showSnackBar(String message, {isError = true}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? ColorConst.darkRed : ColorConst.dark,
    );

    _sk.currentState.showSnackBar(snackBar);
  }

  /// Stop scrollability when scale start
  void _scaleStart(ScaleStartDetails details) {
    setState(() => _scrollable = false);
  }

  /// Update scale value when scale operation on going
  void _scaleUpdate(ScaleUpdateDetails details, int index) {
    setState(() => _scales[index] = details.scale);
  }

  /// Start scrollability when scale stop
  void _scaleEnd(ScaleEndDetails details) {
    setState(() => _scrollable = true);
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

  /// Create new post
  Future<void> _share(List<File> files) async {
    final c = (SharePostResponse r) async {
      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Show error
          _showSnackBar(r.message, isError: true);
        }

        return;
      }

      dev.log('Post created with ${r.code}.');

      // Route to view page with code arguments
      await Navigator.of(context).pushReplacementNamed(ViewPage.tag);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    return ShareService.call(_cc.text, files).then(c).catchError(e);
  }
}
