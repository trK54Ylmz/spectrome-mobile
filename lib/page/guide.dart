import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/page/home.dart';
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
  // Animation controller
  AnimationController _ac;

  // Animation side, 1 is right, -1 is left
  int _side = 1;

  // Active image ID
  int _active = 1;

  // Carousel drag is blocked or not
  bool _blocked = false;

  // Carousel messages
  final _texts = <String>[
    'See what people shared.',
    'Share your post.',
    'Send to the friends.',
  ];

  @override
  void initState() {
    super.initState();

    // Initiate animation controller
    _ac = new AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 100.0,
      duration: const Duration(milliseconds: 200),
    );

    // Generate widget every tick
    _ac.addListener(() => setState(() => null));

    // Add animation listener to manage animation
    _ac.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        dev.log('Animation completed.');

        // Reset animation
        _ac.reset();

        // Unlock lock
        _blocked = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose animation controller
    _ac.dispose();
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
    final images = <Widget>[
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

    // Carousel offset value
    double offset = ((width - (hp * 2)) * (_active - 1));
    double difference = (_side * (width - (hp * 2)) * (_ac.value / 100.0));

    // Animated carousel with images
    final carousel = new Expanded(
      child: new Opacity(
        opacity: 1.0,
        child: new GestureDetector(
          onHorizontalDragEnd: _dragEnd,
          child: new Stack(
            children: <Widget>[
              new Positioned(
                bottom: 0.0,
                left: -(offset + difference),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Guide message
    final msg = new Opacity(
      opacity: _ac.value >= 50 ? (_ac.value - 50) / 50 : (50 - _ac.value) / 50,
      child: new Text(
        _texts[_active - 1],
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          color: ColorConst.darkGrayColor,
          letterSpacing: 0.0,
        ),
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
        color: ColorConst.darkGrayColor,
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
        color: ColorConst.grayColor,
        size: 6.0,
      ),
    );

    // Dot group
    final dots = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _active == 1 ? ad : pd,
        _active == 2 ? ad : pd,
        _active == 3 ? ad : pd,
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
          color: ColorConst.grayColor,
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
          children: <Widget>[
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

  /// Decide actiom after the horizontal drag operation
  void _dragEnd(DragEndDetails details) {
    // Do not do anything if animation running
    if (_blocked) {
      return;
    }

    _blocked = true;

    // Side of the slide action
    final dx = details.velocity.pixelsPerSecond.dx;

    if (dx > 0) {
      // App shows the first screen
      if (_active <= 1) {
        _blocked = false;
        return;
      }

      // Move carousel to left
      _side = -1;

      final cb = (_) {
        setState(() => _active -= 1);
      };

      // Start animation
      _ac.forward().then(cb);
    } else {
      // App shows the last screen
      if (_active >= 3) {
        _blocked = false;
        return;
      }

      // Move carousel to right
      _side = 1;

      final cb = (_) {
        setState(() => _active += 1);
      };

      // Start animation
      _ac.forward().then(cb);
    }
  }

  /// Complete the guide statement
  void _end(BuildContext context) {
    dev.log('Guide ended');

    final cb = (SharedPreferences sb) {
      sb.setBool('guided', true);

      // Redirect to home page
      Navigator.of(context).pushReplacementNamed(HomePage.tag);
    };

    Storage.load().then(cb);
  }
}
