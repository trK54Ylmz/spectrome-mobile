import 'package:flutter/cupertino.dart';
import 'package:spectrome/page/me.dart';
import 'package:spectrome/page/waterfall.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class HomePage extends StatefulWidget {
  static final tag = 'home';

  HomePage() : super();

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
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
                0xf90d,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.gray,
              size: 20.0,
            ),
            activeIcon: Icon(
              IconData(
                0xf90d,
                fontFamily: FontConst.fa,
              ),
              color: ColorConst.darkerGray,
              size: 20.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconData(
                0xf086,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.gray,
              size: 20.0,
            ),
            activeIcon: Icon(
              IconData(
                0xf086,
                fontFamily: FontConst.fa,
              ),
              color: ColorConst.darkerGray,
              size: 20.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              IconData(
                0xf007,
                fontFamily: FontConst.fal,
              ),
              color: ColorConst.gray,
              size: 20.0,
            ),
            activeIcon: Icon(
              IconData(
                0xf007,
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
}
