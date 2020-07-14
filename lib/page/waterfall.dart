import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/service/post/waterfall.dart';
import 'package:spectrome/theme/color.dart';

class WaterFallPage extends StatefulWidget {
  static final tag = 'waterfall';

  WaterFallPage() : super();

  @override
  _WaterFallState createState() => new _WaterFallState();
}

class _WaterFallState extends State<WaterFallPage> with AutomaticKeepAliveClientMixin {
  // Account session key
  String _session;

  // Cursor timestamp value
  double _timestamp;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final c = (SharedPreferences sp) {
      final session = sp.getString('_session');

      setState(() => _session = session);
    };

    // Get shared preferences
    SharedPreferences.getInstance().then(c);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SingleChildScrollView(
        child: new Container(
          child: getWaterFall(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  /// Get waterfall posts
  Future<List<Post>> getPosts() async {
    dev.log('Waterfall posts request sent.');

    final c = (WaterFallResponse r) {
      if (r.status) {
        return r.posts;
      }

      return null;
    };

    return WaterFallService.call(_session, _timestamp).then(c);
  }

  /// Get waterfall posts widget
  Widget getWaterFall() {
    if (_session == null) {
      return new Center(
        child: new Image.asset(
          'assets/images/loading.gif',
          width: 60.0,
          height: 60.0,
        ),
      );
    }

    return new FutureBuilder(
      builder: (context, res) {
        if (res.connectionState == ConnectionState.none && res.hasData == null) {
          return new Container();
        }

        return ListView();
      },
      future: getPosts(),
    );
  }
}
