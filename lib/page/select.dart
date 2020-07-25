import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/page/camera.dart';
import 'package:spectrome/page/gallery.dart';
import 'package:spectrome/page/share.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class SelectPage extends StatefulWidget {
  static final tag = 'select';

  SelectPage() : super();

  @override
  _SelectState createState() => new _SelectState();
}

class _SelectState extends State<SelectPage> {
  // Camera widget global key
  final _ck = new GlobalKey<CameraState>();

  // Gallery widget global key
  final _gk = new GlobalKey<GalleryState>();

  // Camera page
  CameraPage _camera;

  // Gallery page
  GalleryPage _gallery;

  // Camera is active or not
  bool _ca = false;

  // Gallery is active or not
  bool _ga = false;

  @override
  void initState() {
    super.initState();

    // Create camera page
    _camera = new CameraPage(key: _ck);

    // Create gallery page
    _gallery = new GalleryPage(key: _gk);

    // Gallery value listener
    final gc = (_) {
      // Skip if gallery state is empty
      if (_gk.currentState == null) {
        return;
      }

      _gk.currentState.active.addListener(() {
        setState(() => _ga = _gk.currentState.active.value);
      });
    };

    // Camera value listener
    final cc = (_) {
      // Skip if camera state is empty
      if (_ck.currentState == null) {
        return;
      }

      _ck.currentState.active.addListener(() {
        setState(() => _ca = _ck.currentState.active.value);
      });
    };

    // Camera and gallery active listeners
    final ac = (_) {
      _gallery.ready(gc);

      _camera.ready(cc);
    };

    // Run after page build
    WidgetsBinding.instance.addPostFrameCallback(ac);
  }

  @override
  Widget build(BuildContext context) {
    return (_ca || _ga) ? _getReady() : _getSelector();
  }

  /// Get default tab selector widget
  Widget _getSelector() {
    return new CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: ColorConst.white,
        border: Border(
          top: BorderSide(
            color: ColorConst.gray.withOpacity(0.67),
            width: 0.5,
          ),
        ),
        onTap: (index) {
          if (index == 1) {
            // Camera value listener
            final cc = (_) {
              _ck.currentState.active.addListener(() {
                setState(() => _ca = _ck.currentState.active.value);
              });
            };

            _camera.ready(cc);
          } else {
            // Gallery value listener
            final gc = (_) {
              _gk.currentState.active.addListener(() {
                setState(() => _ga = _gk.currentState.active.value);
              });
            };

            _gallery.ready(gc);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              IconData(
                0xf87c,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.gray,
              size: 20.0,
            ),
            activeIcon: Icon(
              IconData(
                0xf87c,
                fontFamily: FontConst.fa,
              ),
              color: ColorConst.darkerGray,
              size: 20.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconData(
                0xf030,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.gray,
              size: 20.0,
            ),
            activeIcon: Icon(
              IconData(
                0xf030,
                fontFamily: FontConst.fa,
              ),
              color: ColorConst.darkerGray,
              size: 20.0,
            ),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 1:
            return _camera;
            break;
          default:
            return _gallery;
            break;
        }
      },
    );
  }

  /// Get ready widget after made selection from gallery or recording from camera
  Widget _getReady() {
    final width = MediaQuery.of(context).size.width;
    final ch = MediaQuery.of(context).padding.bottom + 50.0;

    final w = _ca ? _camera : _gallery;

    // Cancel button
    final cb = new Expanded(
      flex: 1,
      child: new GestureDetector(
        onTap: () {
          // Reset selection on camera
          if (_ck.currentState != null) {
            _ck.currentState.active.value = false;
          }

          // Reset selection on gallery
          if (_gk.currentState != null) {
            _gk.currentState.active.value = false;
          }
        },
        child: new Container(
          child: new Center(
            child: new Icon(
              IconData(
                0xf00d,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.darkerGray,
              size: 20.0,
            ),
          ),
        ),
      ),
    );

    // Next button
    final nb = new Expanded(
      flex: 1,
      child: new GestureDetector(
        onTap: () async {
          // Lock selection on camera
          if (_ck.currentState != null) {
            _ck.currentState.done.value = true;
          }

          // Lock selection on gallery
          if (_gk.currentState != null) {
            _gk.currentState.done.value = true;
          }

          // Go to share page
          await _next();
        },
        child: new Center(
          child: new Icon(
            IconData(
              0xf00c,
              fontFamily: FontConst.fal,
            ),
            color: ColorConst.success,
            size: 20.0,
          ),
        ),
      ),
    );

    // Controllers
    final c = new Container(
      width: width,
      height: ch,
      decoration: new BoxDecoration(
        color: ColorConst.white,
        border: Border(
          top: BorderSide(
            color: ColorConst.gray.withOpacity(0.67),
            width: 0.5,
          ),
        ),
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          cb,
          nb,
        ],
      ),
    );

    return new Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        w,
        c,
      ],
    );
  }

  /// Move to next stop on share
  Future<void> _next() async {
    final c = (List<File> files) async {
      await Navigator.of(context).pushReplacementNamed(SharePage.tag, arguments: files);
    };

    if (_ca) {
      await _ck.currentState.getFiles().then(c);
    }

    if (_ga) {
      await _gk.currentState.getFiles().then(c);
    }
  }
}
