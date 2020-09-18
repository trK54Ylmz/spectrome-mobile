import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/page/home.dart';
import 'package:spectrome/page/me.dart';
import 'package:spectrome/page/select.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/user/count.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/util/storage.dart';

class ViewPage extends StatefulWidget {
  static final tag = 'view';

  ViewPage() : super();

  @override
  _ViewState createState() => new _ViewState();
}

class _ViewState extends State<ViewPage> {
  // Select home page as initial page
  final _pc = new PageController(initialPage: 1);

  // Number of active follow requests
  final _request = new ValueNotifier<int>(0);

  // Account session key
  String _session;

  @override
  void initState() {
    super.initState();

    final sc = (SharedPreferences sp) {
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
    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new PageView(
        controller: _pc,
        physics: const ClampingScrollPhysics(),
        children: [
          new SelectPage(),
          new HomePage(controller: _pc, request: _request),
          new MePage(controller: _pc),
        ],
      ),
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
      _request.value = r.count;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown request count error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      dev.log(msg);
    };

    // Prepare request
    final s = IntentionCountService.call(_session);

    await s.then(sc).catchError(e);
  }
}
