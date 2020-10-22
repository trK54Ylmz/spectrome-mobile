import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/page/view.dart';
import 'package:spectrome/service/share/report.dart';
import 'package:spectrome/service/share/status.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class StatusPage extends StatefulWidget {
  static final tag = 'status';

  StatusPage() : super();

  @override
  _StatusState createState() => new _StatusState();
}

class _StatusState extends State<StatusPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Report button disabled or not
  bool _disabled = false;

  // Status of progress
  bool _done = false;

  // Status of process
  bool _failed = false;

  // Request counter
  int _counter = 0;

  // Current state of the progress
  String _state;

  // Status callback timer
  Timer _timer;

  // Error message
  ErrorMessage _error;

  // Post code
  String _code;

  // Account session key
  String _session;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences sp) {
      _session = sp.getString('_session');

      // Hit the first status
      _getState();

      // Run periodic task to check status
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) => _getState());
    };

    // Post code argument callback
    final ac = (_) {
      final String code = ModalRoute.of(context).settings.arguments;

      if (code != null) {
        _code = code;
      }

      // Get storage kv
      Storage.load().then(spc);
    };

    // Add callback for argument
    WidgetsBinding.instance.addPostFrameCallback(ac);
  }

  @override
  void dispose() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: AppConst.loader(
        page: StatusPage.tag,
        argument: _session == null,
        error: _error,
        callback: _getPage,
      ),
    );
  }

  /// Get content of the version page
  Widget _getPage() {
    var status;

    // Create status text by using state constants
    switch (_state) {
      case 'uploaded':
        status = 'The content has sent.';
        break;
      case 'processing':
        status = 'The content is processing.';
        break;
      case 'created':
        status = 'The post almost ready.';
        break;
      case 'activated':
        status = 'The post is ready. Redirecting.';
        break;
      case 'banned':
        status = 'The post contains non-safe content.';
        break;
      case 'deleted':
        status = 'The post creation is failed. We are sorry.';
        break;
    }

    // Status text
    final t = new Text(
      status,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        fontSize: 14.0,
        color: ColorConst.darkGray,
      ),
    );
    
    final l = new Loading();
    final ec = new Container(height: 41.0, width: 60.0);
    
    // Report button
    final b = new Button(
      text: 'Report',
      disabled: _disabled,
      background: ColorConst.darkGray,
      color: ColorConst.white,
      onPressed: _report,
    );

    return new Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      appBar: new CupertinoNavigationBar(
        heroTag: 8,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        transitionBetweenRoutes: false,
        backgroundColor: ColorConst.white,
        border: Border(
          bottom: BorderSide.none,
        ),
      ),
      body: new SafeArea(
        child: new Padding(
          padding: EdgeInsets.all(8.0),
          child: new Center(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                l,
                t,
                _failed ? b : ec,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get state of the share post
  void _getState() async {
    // Stop counter if too many request sent
    if (_counter >= 120) {
      _done = true;
      _failed = true;
      _timer.cancel();
    }

    dev.log('Share status request sending.');

    final c = (ShareStatusResponse r) async {
      dev.log('Share status request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _error = ErrorMessage.custom(r.message);
        }
        return;
      }

      _done = r.done;
      _failed = r.failed;
      _state = r.state;

      // Finish the periodic task
      if (r.done) {
        _timer.cancel();
      }
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create error message
      _error = ErrorMessage.custom(msg);
    };

    // Request complete callback
    final cc = () {
      setState(() => _counter += 1);

      // Everything is fine so go to view page
      if (_done && _state == 'activated') {
        Navigator.of(context).pushReplacementNamed(ViewPage.tag);
      }
    };

    // Prepare request
    final r = ShareStatusService.call(
      session: _session,
      code: _code,
    );

    await r.then(c).catchError(e).whenComplete(cc);
  }

  // Send status report of the post when failed
  void _report() async {
    _disabled = true;

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create error message
      _error = ErrorMessage.custom(msg);
    };

    // Request complete callback
    final cc = () {
      Navigator.of(context).pushReplacementNamed(ViewPage.tag);
    };

    // Prepare request
    final r = ShareReportService.call(
      session: _session,
      code: _code,
    );

    await r.catchError(e).whenComplete(cc);
  }
}
