import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/page/profile.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/user/accept.dart';
import 'package:spectrome/service/user/request.dart';
import 'package:spectrome/service/user/seen.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';

class RequestPage extends StatefulWidget {
  static final tag = 'request';

  RequestPage() : super();

  @override
  _RequestState createState() => new _RequestState();
}

class _RequestState extends State<RequestPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // List of requests
  final _requests = <Request>[];

  // Loading indicator
  bool _loading = true;

  // Action loading indicator
  bool _action = false;

  // Account session key
  String _session;

  // Error message
  ErrorMessage _error;

  // Number of requests count
  int _count = 0;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      final session = s.getString('_session');

      setState(() => _session = session);

      // Load follow requests from API
      _getRequests();

      if (_count > 0) {
        // Set request count as seen
        _setSeen();
      }
    };

    // Request count callback
    final ac = (_) {
      final count = ModalRoute.of(context).settings.arguments as int;

      if (count != null && count > 0) {
        _count = count;
      }

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
        child: AppConst.loader(
          page: RequestPage.tag,
          argument: _loading,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
    final width = MediaQuery.of(context).size.width;
    final hp = width > 400.0 ? 64.0 : 32.0;

    // Create list builder
    final l = new ListView.builder(
      itemCount: _requests.length,
      itemBuilder: _requestBuilder,
    );

    // No any requests container
    final e = new Center(
      child: new Padding(
        padding: EdgeInsets.all(hp),
        child: new Text(
          'You do not have any requests yet.',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            fontSize: 14.0,
            color: ColorConst.darkGray,
            letterSpacing: 0.33,
          ),
        ),
      ),
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        heroTag: 6,
        transitionBetweenRoutes: false,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        backgroundColor: ColorConst.white,
        border: new Border(bottom: BorderSide.none),
        leading: new GestureDetector(
          onTap: () => Navigator.of(context).pop(true),
          child: new Icon(
            IconData(0xf104, fontFamily: FontConst.fal),
            color: ColorConst.darkerGray,
          ),
        ),
        middle: new Text(
          'Requests',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
            fontSize: 16.0,
          ),
        ),
      ),
      child: new Container(
        child: _requests.isEmpty ? e : l,
      ),
    );
  }

  /// Follow request users list builder
  Widget _requestBuilder(BuildContext context, int i) {
    final width = MediaQuery.of(context).size.width;

    // Http headers for image request
    final h = {Http.TOKEN_HEADER: _session};

    // Request profile photo from server
    final p = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4.0,
      ),
      child: new ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: new Container(
          width: 40.0,
          height: 40.0,
          child: new Image.network(
            _requests[i].user.photoUrl,
            headers: h,
            width: 40.0,
            height: 40.0,
            errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
          ),
        ),
      ),
    );

    final pt = new Padding(
      padding: EdgeInsets.only(top: 2.0),
    );

    // Username text
    final un = new Text(
      _requests[i].user.username,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.black,
        fontSize: 16.0,
        letterSpacing: 0.33,
      ),
    );

    // Real name text
    final nm = new Text(
      _requests[i].user.name,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.darkGray,
        fontSize: 12.0,
        letterSpacing: 0.33,
      ),
    );

    // Information container
    final d = new Container(
      width: width - 136.0,
      child: new Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 2.0,
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            un,
            pt,
            nm,
          ],
        ),
      ),
    );

    // Accept button
    final a = new Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 3.0,
      ),
      child: new Button(
        text: 'Accept',
        width: 64.0,
        disabled: _action,
        padding: EdgeInsets.symmetric(
          vertical: 6.0,
        ),
        onPressed: () => _accept(i),
      ),
    );

    return new Semantics(
      focusable: true,
      button: true,
      child: new GestureDetector(
        onTap: () async {
          dev.log('User "${_requests[i].user.username}" selected.');

          final u = _requests[i].user.username;

          // Route to profile page
          await Navigator.of(context).pushNamed(ProfilePage.tag, arguments: u);
        },
        child: new Container(
          child: new Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                p,
                d,
                a,
              ],
            ),
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

  /// Get list of follow requests
  void _getRequests() async {
    dev.log('Follow requests is loading.');

    // Handle HTTP response
    final sc = (IntentionResponse r) async {
      dev.log('Follow requests request sent.');

      if (!r.status) {
        // Route to sign page, if session is expired
        if (r.expired) {
          final r = (Route<dynamic> route) => false;
          await Navigator.of(context).pushNamedAndRemoveUntil(SignInPage.tag, r);
          return;
        }

        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _showSnackBar(r.message, isError: true);
        }

        return;
      }

      // Clear items
      _requests.clear();

      // Update intention instances
      _requests.addAll(r.intentions);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown request count error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    // Complete callback
    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    // Prepare request
    final s = IntentionService.call(_session);

    await s.then(sc).catchError(e).whenComplete(cc);
  }

  /// Set request count as seen
  void _setSeen() async {
    dev.log('Follow requests seen request sending.');

    // Handle HTTP response
    final sc = (IntentionSeenResponse r) async {
      dev.log('Follow requests seen request sent.');

      if (!r.status) {
        // Route to sign page, if session is expired
        if (r.expired) {
          final r = (Route<dynamic> route) => false;
          await Navigator.of(context).pushNamedAndRemoveUntil(SignInPage.tag, r);
        }

        return;
      }
    };

    // Prepare request
    await IntentionSeenService.call(_session).then(sc);
  }

  /// Accept following request
  void _accept(int index) async {
    dev.log('Follow accept button clicked.');

    if (_action) {
      return;
    }

    dev.log('Follow accept request sending.');

    // Set loading true
    setState(() => _action = true);

    // Handle HTTP response
    final c = (FollowAcceptResponse r) async {
      dev.log('Follow accept request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          // _message = r.message;
        }

        return;
      }

      // Remove accepted request
      setState(() => _requests.removeAt(index));
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown following accept error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
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
    final s = FollowAcceptService.call(_session, _requests[index].intention.code);

    s.then(c).catchError(e).whenComplete(cc);
  }
}
