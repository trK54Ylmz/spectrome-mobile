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
    _camera = new CameraPage();

    // Create gallery page
    _gallery = new GalleryPage();

    // Camera value listener
    _camera.currentState.active.addListener(() {
      setState(() => _ca = _camera.currentState.active.value);
    });

    // Gallery value listener
    _gallery.currentState.active.addListener(() {
      setState(() => _ga = _gallery.currentState.active.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_ca || _ga) ? _getReady() : _getSelector();
  }

  /// Get default tab selector widget
  Widget _getSelector() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: ColorConst.white,
        border: Border(
          top: BorderSide(
            color: ColorConst.gray.withOpacity(0.67),
            width: 0.5,
          ),
        ),
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
          if (index == 1) {
            // Go to share page
            await _next();
          } else {
            // Reset selection on camera
            _camera.currentState.active.value = false;

            // Reset selection on gallery
            _gallery.currentState.active.value = false;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              IconData(
                0xf00d,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.darkerGray,
              size: 20.0,
            ),
            activeIcon: Icon(
              IconData(
                0xf00d,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.darkerGray,
              size: 20.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconData(
                0xf00c,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.success,
              size: 20.0,
            ),
            activeIcon: Icon(
              IconData(
                0xf00c,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.success,
              size: 20.0,
            ),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 1:
            return _ca ? _camera : _gallery;
            break;
          default:
            return _ga ? _gallery : _camera;
            break;
        }
      },
    );
  }

  /// Move to next stop on share
  Future<void> _next() async {
    final c = (List<String> files) async {
      await Navigator.of(context).pushReplacementNamed(SharePage.tag, arguments: files);
    };

    if (_ca) {
      await _camera.currentState.getFiles().then(c);
    }

    if (_ga) {
      await _gallery.currentState.getFiles().then(c);
    }
  }
}
