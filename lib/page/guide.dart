import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/page/session.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuidePage extends StatefulWidget {
  static final tag = 'guide';

  GuidePage() : super();

  @override
  _GuideState createState() => new _GuideState();
}

class _GuideState extends State<GuidePage> with TickerProviderStateMixin {
  // Page view controller
  final _pc = new PageController();

  // Carousel messages
  final _texts = <String>[
    'See what people shared.',
    'Share your post.',
    'Send to the friends.',
  ];

  // Current index
  int _ci = 0;

  @override
  void initState() {
    super.initState();

    // Initiate page controller
    _pc.addListener(() {
      if (_pc.page.round() != _ci) {
        setState(() => _ci = _pc.page.round());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final vp = height > 800.0 ? 64.0 : 48.0;
    final hp = width > 400.0 ? 64.0 : 32.0;
    final tp = const Padding(padding: EdgeInsets.only(top: 16.0));
    final stp = const Padding(padding: EdgeInsets.only(top: 8.0));

    // Carousel image group
    final i = <Widget>[
      new Container(
        width: width - (hp * 2),
        height: height - ((vp * 2) + 110),
        color: const Color(0xffff3333),
      ),
      new Container(
        width: width - (hp * 2),
        height: height - ((vp * 2) + 110),
        color: const Color(0xff33ff33),
      ),
      new Container(
        width: width - (hp * 2),
        height: height - ((vp * 2) + 110),
        color: const Color(0xff3333ff),
      ),
    ];

    // Animated carousel with images
    final carousel = new Expanded(
      child: new PageView(
        physics: const ClampingScrollPhysics(),
        controller: _pc,
        children: i,
      ),
    );

    // Guide message
    final msg = new Text(
      _texts[_ci],
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        color: ColorConst.darkGray,
        letterSpacing: 0.0,
      ),
    );

    // Active dot icon
    final ad = new Padding(
      padding: EdgeInsets.all(2.0),
      child: new Icon(
        new IconData(
          0xf111,
          fontFamily: FontConst.fa,
        ),
        color: ColorConst.darkGray,
        size: 6.0,
      ),
    );

    // Passive dot icon
    final pd = new Padding(
      padding: EdgeInsets.all(2.0),
      child: new Icon(
        new IconData(
          0xf111,
          fontFamily: FontConst.fa,
        ),
        color: ColorConst.gray,
        size: 6.0,
      ),
    );

    // Dot group
    final dots = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ci == 0 ? ad : pd,
        _ci == 1 ? ad : pd,
        _ci == 2 ? ad : pd,
      ],
    );

    // Skip button
    final skip = new GestureDetector(
      onTap: () => _end(context),
      child: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: new Text(
          'skip',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            color: ColorConst.gray,
            fontSize: 14.0,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );

    // Show loading icon
    return new Container(
      color: ColorConst.white,
      width: width,
      height: height,
      child: new Padding(
        padding: EdgeInsets.symmetric(
          horizontal: hp,
          vertical: vp,
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            tp,
            carousel,
            tp,
            msg,
            tp,
            dots,
            stp,
            skip,
          ],
        ),
      ),
    );
  }

  /// Complete the guide statement
  void _end(BuildContext context) {
    dev.log('Guide ended');

    final cb = (SharedPreferences sb) {
      sb.setBool('_guided', true);

      // Redirect to home page
      Navigator.of(context).pushReplacementNamed(SessionPage.tag);
    };

    Storage.load().then(cb);
  }
}
