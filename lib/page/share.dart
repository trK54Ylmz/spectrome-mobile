import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/item/video.dart';
import 'package:spectrome/page/view.dart';
import 'package:spectrome/service/share/share.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';
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

  // List of shared users
  final _users = <String>[];

  // Session value
  String _session;

  // Is page view scrollable
  bool _scrollable = true;

  // Loading indicator
  bool _loading = true;

  // Post is disposible
  bool _disposible = false;

  // Post is restricted for users
  bool _restricted = false;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final c = (SharedPreferences sp) {
      _session = sp.getString('_session');

      setState(() => _loading = false);
    };

    // Get shared preferences
    Storage.load().then(c);
  }

  @override
  Widget build(BuildContext context) {
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
          color: _loading ? ColorConst.darkRed.withOpacity(0.33) : ColorConst.darkRed,
        ),
      ),
    );

    final clr = ColorConst.darkerGray;
    final _sb = new Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: new Text(
        'Share',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: _loading ? clr.withOpacity(0.33) : clr,
        ),
      ),
    );

    List<BottomNavigationBarItem> items;
    if (_loading) {
      items = [
        BottomNavigationBarItem(
          icon: new Container(),
        ),
        BottomNavigationBarItem(
          icon: new Loading(iconWidth: 40.0, iconHeight: 40.0),
        ),
        BottomNavigationBarItem(
          icon: new Container(),
        )
      ];
    } else {
      items = [
        BottomNavigationBarItem(
          icon: _cb,
          activeIcon: _cb,
        ),
        BottomNavigationBarItem(
          icon: _sb,
          activeIcon: _sb,
        ),
      ];
    }

    return new Scaffold(
      key: _sk,
      body: new CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: ColorConst.white,
          border: Border(
            top: BorderSide(
              color: ColorConst.gray.withOpacity(0.67),
              width: 0.5,
            ),
          ),
          onTap: (index) async {
            // Disable click while loading
            if (_loading) {
              return;
            }

            if (index == 0) {
              await Navigator.of(context).pushReplacementNamed(ViewPage.tag);
            } else {
              setState(() => _loading = true);

              // Create post
              await _share(files);
            }
          },
          items: items,
        ),
        tabBuilder: (context, index) {
          return _getForm(files);
        },
      ),
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
      content: new Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: new Text(
          message,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
          ),
        ),
      ),
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
    dev.log('Share button clicked.');

    final c = (SharePostResponse r) async {
      dev.log('Share post request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          final msg = ErrorMessage.network().error;

          _showSnackBar(msg, isError: true);
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
      print(e);
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      _showSnackBar(msg, isError: true);
    };

    final cc = () {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    // Create http request
    final r = ShareService.call(
      session: _session,
      disposible: _disposible,
      restricted: _restricted,
      comment: _cc.text,
      files: files,
      scales: _scales,
      users: _users,
    );

    return r.then(c).catchError(e).whenComplete(cc);
  }
}
