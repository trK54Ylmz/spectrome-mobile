import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/page/me.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/waterfall.dart';
import 'package:spectrome/service/user/count.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/storage.dart';

class HomePage extends StatefulWidget {
  static final tag = 'home';

  HomePage() : super();

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage> {
  // Account session key
  String _session;

  // Number of active follow requests
  int _count = 0;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final sc = (SharedPreferences sp) {
      // Set session key
      _session = sp.getString('_session');

      // Load number of requests
      _getRequests();

      // Set periodic tasks for follow requests
      Timer.periodic(Duration(seconds: 60), (_) => _getRequests());
    };

    Storage.load().then(sc);
  }

  @override
  Widget build(BuildContext context) {
    // Home page item
    final h = new BottomNavigationBarItem(
      icon: new Icon(
        IconData(
          0xf90d,
          fontFamily: FontConst.fal,
        ),
        color: ColorConst.gray,
        size: 18.0,
      ),
      activeIcon: new Icon(
        IconData(
          0xf90d,
          fontFamily: FontConst.fa,
        ),
        color: ColorConst.darkerGray,
        size: 18.0,
      ),
    );

    // Comments item
    final c = new BottomNavigationBarItem(
      icon: new Icon(
        IconData(
          0xf086,
          fontFamily: FontConst.fal,
        ),
        color: ColorConst.gray,
        size: 18.0,
      ),
      activeIcon: new Icon(
        IconData(
          0xf086,
          fontFamily: FontConst.fa,
        ),
        color: ColorConst.darkerGray,
        size: 18.0,
      ),
    );

    // Profile item
    final p = new BottomNavigationBarItem(
      icon: new Icon(
        IconData(
          0xf007,
          fontFamily: FontConst.fal,
        ),
        color: _count > 0 ? ColorConst.darkRed : ColorConst.gray,
        size: 18.0,
      ),
      activeIcon: new Icon(
        IconData(
          0xf007,
          fontFamily: FontConst.fa,
        ),
        color: _count > 0 ? ColorConst.darkRed : ColorConst.darkerGray,
        size: 18.0,
      ),
    );

    return new CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: ColorConst.white,
        border: Border(
          top: BorderSide(
            color: ColorConst.gray.withOpacity(0.67),
            width: 0.5,
          ),
        ),
        items: [
          h,
          c,
          p,
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 2:
            return new MePage();
            break;
          default:
            return new WaterFallPage();
            break;
        }
      },
    );
  }

  /// Get number of follow requests sent to user
  void _getRequests() async {
    dev.log('Follow request count is loading.');

    // Handle HTTP response
    final sc = (IntentionCountResponse r) async {
      dev.log('Follow request count request sent.');

      if (!r.status) {
        // Route to sign page, if session is expired
        if (r.expired) {
          final r = (Route<dynamic> route) => false;
          await Navigator.of(context).pushNamedAndRemoveUntil(SignInPage.tag, r);
        }

        return;
      }

      // Clear items
      setState(() => _count  = r.count);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      // Create unknown error message
      dev.log(msg);
    };

    // Prepare request
    final s = IntentionCountService.call(_session);

    await s.then(sc).catchError(e);
  }
}
