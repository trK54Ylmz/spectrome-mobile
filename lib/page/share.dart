import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/item/video.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/page/status.dart';
import 'package:spectrome/page/view.dart';
import 'package:spectrome/service/query/circle.dart';
import 'package:spectrome/service/share/share.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';
import 'package:vector_math/vector_math_64.dart';

class SharePage extends StatefulWidget {
  static final tag = 'share';

  SharePage() : super();

  @override
  _ShareState createState() => new _ShareState();
}

class _ShareState extends State<SharePage> {
  // Tab controller
  final _tc = new CupertinoTabController(initialIndex: 1);

  // Form validation key
  final _fk = new GlobalKey<FormValidationState>();

  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Search input controller
  final _sc = new TextEditingController();

  // Page view controller
  final _pc = new PageController();

  // Suggestion page view controller
  final _spc = new PageController();

  // Comment input controller
  final _cc = new TextEditingController();

  // List of selected files
  final _files = <File>[];

  // Scale group of items
  final _scales = <double>[];

  // List of selected users
  final _users = <SimpleProfile>[];

  // List of suggestions
  final _suggests = <SimpleProfile>[];

  // Post screen size
  int _size = 2;

  // Scale operation is active or not
  bool _scale = false;

  // Loading indicator
  bool _loading = false;

  // Action loading indicator
  bool _action = false;

  // Post is disposable
  bool _disposable = false;

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
    final spc = (SharedPreferences sp) {
      final session = sp.getString('_session');

      setState(() => _session = session);
    };

    // Username argument callback
    final ac = (_) {
      final List<File> files = ModalRoute.of(context).settings.arguments;

      // Add files to parameter
      _files.addAll(files);

      final l = new List<double>.generate(files.length, (_) => 1);

      // Add scales to parameter
      _scales.addAll(l);

      // Get storage kv
      Storage.load().then(spc);
    };

    // Add callback for argument
    WidgetsBinding.instance.addPostFrameCallback(ac);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: _session == null ? new Loading() : _getPage(),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
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
              color: ColorConst.transparent,
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

    return new CupertinoTabScaffold(
      controller: _tc,
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
            await _share(_files);
          }
        },
        items: items,
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 1:
            return _getForm(_files);
          default:
            return new Loading();
        }
      },
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
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        right: 8.0,
      ),
      child: new Text(
        'Make this post disappear in 24 hours?',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkGray,
          fontSize: 13.0,
          letterSpacing: 0.33,
        ),
      ),
    );

    // Disposable button
    final db = new Button(
      text: _disposable ? 'Yes'.toUpperCase() : 'No'.toUpperCase(),
      width: 60.0,
      fontSize: 12.0,
      padding: EdgeInsets.all(6.0),
      color: _disposable ? ColorConst.white : ColorConst.darkGray,
      background: _disposable ? ColorConst.yellow : ColorConst.white,
      border: Border.all(
        color: _disposable ? ColorConst.yellow : ColorConst.gray,
      ),
      onPressed: () {
        if (_loading) {
          return;
        }

        // Update disposibility
        setState(() => _disposable = !_disposable);
      },
    );

    // Disposibility row
    final ds = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hp,
        vertical: 4.0,
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          dt,
          db,
        ],
      ),
    );

    final tsn = new TextStyle(
      fontFamily: FontConst.primary,
      color: ColorConst.darkGray,
      fontSize: 13.0,
      letterSpacing: 0.33,
    );

    final tsb = new TextStyle(
      fontFamily: FontConst.primary,
      color: ColorConst.darkGray,
      fontSize: 13.0,
      letterSpacing: 0.33,
      fontWeight: FontWeight.bold,
    );

    Widget sm;
    if (_restricted && _users.isNotEmpty) {
      final smi = <InlineSpan>[];

      if (_users.length > 3) {
        smi.add(new TextSpan(text: _users[0].username, style: tsb));
        smi.add(new TextSpan(text: ', ', style: tsn));
        smi.add(new TextSpan(text: _users[1].username, style: tsb));
        smi.add(new TextSpan(text: ' and ', style: tsn));
        smi.add(new TextSpan(text: '${_users.length - 2} more', style: tsb));
      } else if (_users.length == 2) {
        smi.add(new TextSpan(text: _users[0].username, style: tsb));
        smi.add(new TextSpan(text: ' and ', style: tsn));
        smi.add(new TextSpan(text: _users[1].username, style: tsb));
      } else {
        smi.add(new TextSpan(text: _users[0].username, style: tsb));
      }

      sm = new RichText(
        overflow: TextOverflow.ellipsis,
        text: new TextSpan(
          text: 'Share with ',
          style: tsn,
          children: smi,
        ),
      );
    } else {
      sm = new Text(
        'Select users in your circle to share with',
        style: tsn,
      );
    }

    // Share with friends text
    final st = new Expanded(
      child: new Padding(
        padding: EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
          right: 8.0,
        ),
        child: sm,
      ),
    );

    // Share with friends button
    final sb = new Button(
      text: _restricted ? 'Edit'.toUpperCase() : 'Select'.toUpperCase(),
      width: 60.0,
      fontSize: 12.0,
      padding: EdgeInsets.all(6.0),
      color: _restricted ? ColorConst.white : ColorConst.darkGray,
      background: _restricted ? ColorConst.button : ColorConst.white,
      border: Border.all(
        color: _restricted ? ColorConst.button : ColorConst.gray,
      ),
      onPressed: () async {
        if (_loading) {
          return;
        }

        final b = (BuildContext context) {
          // State builder for bottom sheet
          return new StatefulBuilder(builder: (context, setState) {
            return _getBottomSheet(context, setState);
          });
        };

        final c = (_) {
          // Update restriction
          setState(() => _restricted = _users.isEmpty ? false : true);
        };

        // Show restriction bottom sheet to add or remove users
        showCupertinoModalPopup(context: context, builder: b).then(c);
      },
    );

    // Share with friends row
    final sf = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hp,
        vertical: 4.0,
      ),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          st,
          sb,
        ],
      ),
    );

    // Comment text field hint value
    String cm;
    if (_restricted) {
      String um;
      if (_users.length > 2) {
        um = _users.sublist(0, 2).join(', ') + ' and others.';
      } else {
        um = _users.map((e) => e.username).join(' and ');
      }

      cm = 'message will be seen by $um';
    } else {
      cm = 'share a message with your friends';
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
    );

    // Comment text field
    final ct = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hp,
        vertical: 4.0,
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
        validator: (String i) {
          if (i.length == 0) {
            return 'The message is required.';
          }

          if (i.runes.length < 10) {
            return 'The message requires at least 10 characters.';
          }

          return null;
        },
      ),
    );

    return new SafeArea(
      child: new SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: new Container(
          child: new FormValidation(
            key: _fk,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ptl,
                i,
                pt,
                sf,
                ds,
                pt,
                ct,
                pt,
              ],
            ),
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
          children: [
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
              duration: Duration(milliseconds: 500),
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
              duration: Duration(milliseconds: 500),
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
      children: [
        pb,
        ic,
        nb,
      ],
    );

    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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

    final ptl = new Padding(
      padding: EdgeInsets.only(top: 16.0),
    );

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
          children: [
            wb,
            sb,
            tb,
          ],
        ),
      ),
    );

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

    final c = new GestureDetector(
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

    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        w,
        ptl,
        c,
      ],
    );
  }

  /// Show restricted users bottom sheet
  Widget _getBottomSheet(BuildContext context, StateSetter setState) {
    final height = MediaQuery.of(context).size.height;
    final pt = const Padding(padding: EdgeInsets.only(top: 8.0));

    // Share title text
    final tt = new Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: new Text(
        'Share',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 16.0,
          color: ColorConst.black,
          letterSpacing: 0.33,
        ),
      ),
    );

    // Close button
    final cb = new Semantics(
      focusable: true,
      button: true,
      child: new GestureDetector(
        onTap: () => Navigator.pop(context),
        child: new Container(
          decoration: new BoxDecoration(
            color: ColorConst.lightGray,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: new Padding(
            padding: EdgeInsets.all(4.0),
            child: new Icon(
              IconData(0xf00d, fontFamily: FontConst.fal),
              color: ColorConst.darkGray,
              size: 16.0,
            ),
          ),
        ),
      ),
    );

    // Title row
    final tr = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        tt,
        cb,
      ],
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
      fontWeight: FontWeight.normal,
    );

    final sb = new FormText(
      hint: 'Type something',
      hintStyle: hs,
      style: ts,
      controller: _sc,
      borderColor: ColorConst.gray,
      onChange: (t) {
        const d = const Duration(milliseconds: 250);

        if (t.length < 2) {
          _suggests.clear();

          // Move to selected users
          _spc.animateToPage(0, duration: d, curve: Curves.ease);

          setState(() => null);

          return null;
        }

        if (_spc.page.round() == 0) {
          // Move to suggestion users
          _spc.animateToPage(1, duration: d, curve: Curves.ease);
        }

        // Send request and collect suggestions
        _search();

        setState(() => null);

        return null;
      },
    );

    final gt = new Text(
      'Your can search to users in your circle',
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 12.0,
        color: ColorConst.gray,
      ),
    );

    // Suggested users list view
    final gl = new Expanded(
      child: new ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _suggests.length,
        itemBuilder: (c, i) => _suggestedBuilder(c, i, setState),
      ),
    );

    // Suggested users container
    final sg = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        gt,
        gl,
      ],
    );

    final st = new Text(
      'You can select up to 16 users',
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 12.0,
        color: ColorConst.gray,
      ),
    );

    // Selected users list view
    final sl = new Expanded(
      child: new ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        itemCount: _users.length,
        itemBuilder: (c, i) => _selectedBuilder(c, i, setState),
      ),
    );

    // Selected users container
    final su = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        st,
        sl,
      ],
    );

    // Suggestion and selected users page view
    final pv = new Expanded(
      child: new PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _spc,
        pageSnapping: false,
        onPageChanged: (_) => setState(() => null),
        children: [
          su,
          sg,
        ],
      ),
    );

    final c = new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        tr,
        pt,
        sb,
        pt,
        pv,
      ],
    );

    return new Container(
      decoration: new BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      child: new Padding(
        padding: EdgeInsets.all(8.0),
        child: new Container(
          height: (height / 3) * 2,
          child: c,
        ),
      ),
    );
  }

  /// Get suggested users builder
  Widget _suggestedBuilder(BuildContext context, int index, StateSetter setState) {
    // Http headers for profile image request
    final h = {Http.TOKEN_HEADER: _session};

    // Profile photo
    final pp = new Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: ColorConst.gray,
        border: new Border.all(
          width: 0.5,
          color: ColorConst.gray.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: new ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: new Image.network(
          _suggests[index].photoUrl,
          headers: h,
          width: 40.0,
          height: 40.0,
          errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
        ),
      ),
    );

    final ur = new Container(
      width: 120.0,
      height: 20.0,
      alignment: Alignment.centerLeft,
      child: new Text(
        _suggests[index].username,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.black,
          fontSize: 14.0,
          letterSpacing: 0.33,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final un = new Container(
      width: 120.0,
      height: 14.0,
      child: new Text(
        _suggests[index].name,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkGray,
          fontSize: 12.0,
          letterSpacing: 0.33,
        ),
      ),
    );

    final uu = new Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ur,
          un,
        ],
      ),
    );

    final c = () {
      bool exists = false;
      for (int i = 0; i < _users.length; i++) {
        if (_users[i].username == _suggests[index].username) {
          exists = true;
          break;
        }
      }

      if (!exists) {
        // Populate selected users
        _users.insert(0, _suggests[index]);
      }

      // Clear text field
      _sc.clear();

      const d = const Duration(milliseconds: 500);

      // Move to selected users
      _spc.animateToPage(0, duration: d, curve: Curves.ease);
    };

    return new Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: new GestureDetector(
        onTap: c,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            pp,
            uu,
          ],
        ),
      ),
    );
  }

  /// Get selected users builder
  Widget _selectedBuilder(BuildContext context, int index, StateSetter setState) {
    // Http headers for profile image request
    final h = {Http.TOKEN_HEADER: _session};

    // Profile photo
    final pp = new Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: ColorConst.gray,
        border: new Border.all(
          width: 0.5,
          color: ColorConst.gray.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: new ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: new Image.network(
          _users[index].photoUrl,
          headers: h,
          width: 40.0,
          height: 40.0,
          errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
        ),
      ),
    );

    final ur = new Container(
      width: 120.0,
      height: 20.0,
      alignment: Alignment.centerLeft,
      child: new Text(
        _users[index].username,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.black,
          fontSize: 14.0,
          letterSpacing: 0.33,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final un = new Container(
      width: 120.0,
      height: 14.0,
      child: new Text(
        _users[index].name,
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkGray,
          fontSize: 12.0,
          letterSpacing: 0.33,
        ),
      ),
    );

    // User information container
    final uu = new Expanded(
      child: new Padding(
        padding: EdgeInsets.only(left: 8.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ur,
            un,
          ],
        ),
      ),
    );

    // Close button
    final cb = new GestureDetector(
      onTap: () => setState(() => _users.removeAt(index)),
      child: new Container(
        decoration: new BoxDecoration(
          color: ColorConst.lightGray,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: new Padding(
          padding: EdgeInsets.all(6.0),
          child: new Icon(
            IconData(0xf00d, fontFamily: FontConst.fal),
            color: ColorConst.darkGray,
            size: 12.0,
          ),
        ),
      ),
    );

    return new Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          pp,
          uu,
          cb,
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

  /// Fetch users by using query filter
  void _search() {
    dev.log('User search triggered.');

    if (_action) {
      return;
    }

    dev.log('User search request sending for "${_sc.text}".');

    // Set loading true
    setState(() => _action = true);

    // Handle HTTP response
    final c = (CircleQueryResponse r) async {
      dev.log('User search request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          final error = ErrorMessage.network();

          // Show error message
          _showSnackBar(error.error, isError: true);
        } else {
          // Create custom error
          _showSnackBar(r.message, isError: true);
        }

        return;
      }

      // Clear current list
      _suggests.clear();

      // Add all users
      _suggests.addAll(r.users);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown suggestion error. Please try again later.';

      dev.log(msg, stackTrace: s);
    };

    // Complete callback
    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _action = false);
    };

    // Prepare request
    final s = CircleQueryService.call(_session, _sc.text);

    s.then(c).catchError(e).whenComplete(cc);
  }

  /// Create new post
  Future<void> _share(List<File> files) async {
    dev.log('Share button clicked.');

    // Validate form
    if (!_fk.currentState.validate()) {
      _loading = false;
      _showSnackBar(_fk.currentState.errors.first);
      return;
    }

    // User must be selected
    if (_users.isEmpty) {
      _loading = false;
      _showSnackBar('Please select users in your circle.');
      return;
    }

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
      await Navigator.of(context).pushReplacementNamed(StatusPage.tag, arguments: r.code);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown post share error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _showSnackBar(msg, isError: true);
    };

    final cc = () {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    // Populate user names
    final users = <String>[];
    for (int i = 0; i < _users.length; i++) {
      users.add(_users[i].username);
    }

    // Create http request
    final r = ShareService.call(
      session: _session,
      disposable: _disposable,
      restricted: _restricted,
      comment: _cc.text,
      size: _size,
      files: files,
      scales: _scales,
      message: _cc.text,
      users: users,
    );

    return r.then(c).catchError(e).whenComplete(cc);
  }
}
