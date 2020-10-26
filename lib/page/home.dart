import 'package:flutter/cupertino.dart';
import 'package:spectrome/page/history.dart';
import 'package:spectrome/page/search.dart';
import 'package:spectrome/page/waterfall.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class HomePage extends StatefulWidget {
  static final tag = 'home';

  // View page controller
  final PageController controller;

  HomePage({this.controller}) : super();

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage> {
  // Tab controller
  final _tc = new CupertinoTabController(initialIndex: 1);

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
          0xf002,
          fontFamily: FontConst.fal,
        ),
        color: ColorConst.gray,
        size: 18.0,
      ),
      activeIcon: new Icon(
        IconData(
          0xf002,
          fontFamily: FontConst.fa,
        ),
        color: ColorConst.darkerGray,
        size: 18.0,
      ),
    );

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
        items: [
          p,
          h,
          c,
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return new SearchPage();
            break;
          case 2:
            return new HistoryPage();
            break;
          default:
            return new WaterFallPage(controller: widget.controller);
            break;
        }
      },
    );
  }
}
