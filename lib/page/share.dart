import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/item/video.dart';
import 'package:spectrome/page/restriction.dart';
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
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Page view controller
  final _pc = new PageController();

  // Comment input controller
  final _cc = new TextEditingController();

  // Scale group of items
  final _scales = <double>[];

  // List of shared users
  final _users = <String>[];

  // Post screen size
  int _size = 2;

  // Scale operation is active or not
  bool _scale = false;

  // Loading indicator
  bool _loading = true;

  // Post is disposible
  bool _disposible = false;

  // Post is restricted for users
  bool _restricted = false;

  // Current post index
  int _ci = 0;

  // Session value
  String _session;

  @override
  void initState() {
    super.initState();

    // Add page controller listener
    _pc.addListener(() {
      if (_pc.page.round() != _ci) {
        setState(() => _ci = _pc.page.round());
      }
    });

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
    final cb = new Padding(
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
    final sb = new Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: new Text(
        'Share',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          letterSpacing: 0.33,
          color: _loading || _scale ? clr.withOpacity(0.33) : clr,
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
          icon: new Center(
            child: new Loading(
              iconWidth: 40.0,
              iconHeight: 40.0,
            ),
          ),
        ),
        BottomNavigationBarItem(
          icon: new Container(),
        )
      ];
    } else {
      items = [
        BottomNavigationBarItem(
          icon: cb,
          activeIcon: cb,
        ),
        BottomNavigationBarItem(
          icon: sb,
          activeIcon: sb,
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

            // Disable click while post scaling
            if (_scale) {
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
    final hp = width > 400.0 ? 32.0 : 16.0;

    final pt = new Padding(
      padding: EdgeInsets.only(top: 8.0),
    );

    final ptl = new Padding(
      padding: EdgeInsets.only(top: 16.0),
    );

    // Get post item by number of files
    final i = (files.length > 1) ? _getCarousel(files) : _getSingle(files);

    // Disposibility text
    final dt = new Padding(
      padding: EdgeInsets.all(8.0),
      child: new Text(
        'Make this post disappear in 24 hours?',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkGray,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
      ),
    );

    // Disposible button
    final db = new Button(
      text: _disposible ? 'Yes'.toUpperCase() : 'No'.toUpperCase(),
      width: 64.0,
      onPressed: () {
        if (_loading) {
          return;
        }

        // Update disposibility
        setState(() => _disposible = !_disposible);
      },
      padding: EdgeInsets.all(6.0),
      color: _disposible ? ColorConst.white : ColorConst.gray,
      background: _disposible ? ColorConst.button : ColorConst.white,
      border: Border.all(
        color: _disposible ? ColorConst.button : ColorConst.gray,
      ),
    );

    // Disposibility row
    final ds = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hp,
        vertical: 8.0,
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          dt,
          db,
        ],
      ),
    );

    // Share with friends text
    final st = new Padding(
      padding: EdgeInsets.all(8.0),
      child: new Text(
        'Share post with only few followers?',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkGray,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
      ),
    );

    // Share with friends button
    final sb = new Button(
      text: _restricted ? 'Yes'.toUpperCase() : 'No'.toUpperCase(),
      width: 64.0,
      onPressed: () async {
        if (_loading) {
          return;
        }

        if (_restricted) {
          _users.clear();

          setState(() => _restricted = false);
        } else {
          // Open new screen to add or remove users from restriction
          final u = await Navigator.of(context).pushNamed(RestrictionPage.tag);

          // Clear users and populate new selection
          _users.clear();
          _users.addAll(u as List<String>);

          // Update restriction
          setState(() => _restricted = _users.isEmpty ? false : true);
        }
      },
      padding: EdgeInsets.all(6.0),
      color: _restricted ? ColorConst.white : ColorConst.gray,
      background: _restricted ? ColorConst.button : ColorConst.white,
      border: Border.all(
        color: _restricted ? ColorConst.button : ColorConst.gray,
      ),
    );

    // Share with friends row
    final sf = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hp,
        vertical: 8.0,
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          st,
          sb,
        ],
      ),
    );

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
    );

    // Comment text field hint value
    String cm;
    if (_restricted) {
      String um;
      if (_users.length > 2) {
        um = _users.sublist(0, 2).join(', ') + ' and others.';
      } else {
        um = _users.join(' and ');
      }

      cm = 'message $um';
    } else {
      cm = 'share message with your friends';
    }

    // Comment text field
    final ct = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hp,
        vertical: 8.0,
      ),
      child: new FormText(
        controller: _cc,
        hint: cm,
        style: ts,
        hintStyle: hs,
        expands: true,
        maxLines: null,
        minLines: null,
        size: 4000,
      ),
    );

    return new SafeArea(
      child: new SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              pt,
              ds,
              ptl,
              i,
              ptl,
              sf,
              pt,
              ct,
              pt,
            ],
          ),
        ),
      ),
    );
  }

  /// Get carousel post widget
  Widget _getCarousel(List<File> files) {
    final size = ScreenConst.fromValue(_size);

    final width = MediaQuery.of(context).size.width;
    final height = (width / size.first) * size.last;

    final ptl = new Padding(
      padding: EdgeInsets.only(top: 16.0),
    );

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

      // Scaleable gesture widget that contains post item
      final c = new GestureDetector(
        onScaleStart: _scaleStart,
        onScaleEnd: _scaleEnd,
        onScaleUpdate: (d) => _scaleUpdate(d, i),
        child: new Container(
          width: width,
          height: height,
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

    // Wide post button
    final wb = new Expanded(
      flex: 1,
      child: new Semantics(
        button: true,
        child: new GestureDetector(
          onTap: () {
            if (_loading) {
              return;
            }

            setState(() => _size = 1);
          },
          child: new Container(
            decoration: new BoxDecoration(
              color: _size == 1 ? ColorConst.white : ColorConst.gray.withOpacity(0.33),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              ),
            ),
            child: new Padding(
              padding: EdgeInsets.all(8.0),
              child: new Text(
                'Wide'.toUpperCase(),
                style: new TextStyle(
                  fontFamily: FontConst.primary,
                  fontSize: 12.0,
                  color: _size == 1 ? ColorConst.darkerGray : ColorConst.gray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    // Square post button
    final sb = new Expanded(
      flex: 1,
      child: new Semantics(
        button: true,
        child: new GestureDetector(
          onTap: () {
            if (_loading) {
              return;
            }

            setState(() => _size = 2);
          },
          child: new Container(
            decoration: new BoxDecoration(
              color: _size == 2 ? ColorConst.white : ColorConst.gray.withOpacity(0.33),
              border: Border(
                left: new BorderSide(
                  color: ColorConst.gray.withOpacity(0.67),
                ),
                right: new BorderSide(
                  color: ColorConst.gray.withOpacity(0.67),
                ),
              ),
            ),
            child: new Padding(
              padding: EdgeInsets.all(8.0),
              child: new Text(
                'Square'.toUpperCase(),
                style: new TextStyle(
                  fontFamily: FontConst.primary,
                  fontSize: 12.0,
                  color: _size == 2 ? ColorConst.darkerGray : ColorConst.gray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    // Tall post button
    final tb = new Expanded(
      flex: 1,
      child: new Semantics(
        button: true,
        child: new GestureDetector(
          onTap: () {
            if (_loading) {
              return;
            }

            setState(() => _size = 3);
          },
          child: new Container(
            decoration: new BoxDecoration(
              color: _size == 3 ? ColorConst.white : ColorConst.gray.withOpacity(0.33),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            child: new Padding(
              padding: EdgeInsets.all(8.0),
              child: new Text(
                'Tall'.toUpperCase(),
                style: new TextStyle(
                  fontFamily: FontConst.primary,
                  fontSize: 12.0,
                  color: _size == 3 ? ColorConst.darkerGray : ColorConst.gray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    // Post size row
    final w = new Center(
      child: new Container(
        width: 220.0,
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: new Border.all(
            color: ColorConst.gray.withOpacity(0.67),
          ),
        ),
        child: new Row(
          children: <Widget>[
            wb,
            sb,
            tb,
          ],
        ),
      ),
    );

    // Post items container
    final c = new Container(
      width: width,
      height: height,
      child: new PageView(
        controller: _pc,
        physics: NeverScrollableScrollPhysics(),
        children: items,
      ),
    );

    // Active dot icon
    final ad = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 2.0,
        vertical: 4.0,
      ),
      child: new Icon(
        const IconData(
          0xf111,
          fontFamily: FontConst.fa,
        ),
        color: const Color(0xff666666),
        size: 6.0,
      ),
    );

    // Passive dot icon
    final pd = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 2.0,
        vertical: 4.0,
      ),
      child: new Icon(
        const IconData(
          0xf111,
          fontFamily: FontConst.fa,
        ),
        color: const Color(0xffcccccc),
        size: 6.0,
      ),
    );

    // Previous button
    final pb = new Expanded(
      flex: 2,
      child: new Semantics(
        button: true,
        child: new GestureDetector(
          onTap: () {
            // Stop for out of bounds
            if (_ci == 0) {
              return;
            }

            // Go to previous page
            _pc.animateToPage(
              _ci - 1,
              duration: Duration(seconds: 1),
              curve: Curves.ease,
            );
          },
          child: new Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 16.0,
            ),
            child: new Text(
              'Previous',
              style: new TextStyle(
                fontFamily: FontConst.primary,
                fontSize: 14.0,
                letterSpacing: 0.33,
                color: _ci == 0 ? ColorConst.gray : ColorConst.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Next button
    final nb = new Expanded(
      flex: 2,
      child: new Semantics(
        button: true,
        child: new GestureDetector(
          onTap: () {
            // Stop for out of bounds
            if (_ci + 1 == files.length) {
              return;
            }

            // Go to next page
            _pc.animateToPage(
              _ci + 1,
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          },
          child: new Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 16.0,
            ),
            child: new Text(
              'Next',
              style: new TextStyle(
                fontFamily: FontConst.primary,
                fontSize: 14.0,
                letterSpacing: 0.33,
                color: _ci + 1 == files.length ? ColorConst.gray : ColorConst.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    final ici = <Widget>[];
    for (int i = 0; i < files.length; i++) {
      ici.add(_ci == i ? ad : pd);
    }

    // Post index indicator
    final ic = new Expanded(
      flex: 1,
      child: new Center(
        child: new Padding(
          padding: EdgeInsets.all(16.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: ici,
          ),
        ),
      ),
    );

    // Next and previous buttons
    final b = new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        pb,
        ic,
        nb,
      ],
    );

    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        w,
        ptl,
        c,
        ptl,
        b,
      ],
    );
  }

  /// Get single item post widget
  Widget _getSingle(List<File> files) {
    final size = ScreenConst.fromValue(_size);

    final width = MediaQuery.of(context).size.width;
    final height = (width / size.first) * size.last;

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

    return new GestureDetector(
      onScaleStart: _scaleStart,
      onScaleEnd: _scaleEnd,
      onScaleUpdate: (d) => _scaleUpdate(d, 0),
      child: new Container(
        width: width,
        height: height,
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
  }

  /// Show error when error not empty
  void _showSnackBar(String message, {bool isError = true}) {
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

  /// Start scroll operation, stops if video plays etc.
  void _scaleStart(ScaleStartDetails details) {
    setState(() => _scale = true);
  }

  /// Update scale value when scale operation on going
  void _scaleUpdate(ScaleUpdateDetails details, int index) {
    setState(() => _scales[index] = details.scale);
  }

  /// Stop scroll operation, starts video play etc.
  void _scaleEnd(ScaleEndDetails details) {
    setState(() => _scale = false);
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
