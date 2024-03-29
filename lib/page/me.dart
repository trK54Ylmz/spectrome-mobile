import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/grid.dart';
import 'package:spectrome/item/thumb.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/model/profile/me.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/page/circle.dart';
import 'package:spectrome/page/request.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/page/update.dart';
import 'package:spectrome/service/account/sign_out.dart';
import 'package:spectrome/service/post/my.dart';
import 'package:spectrome/service/profile/me.dart';
import 'package:spectrome/service/response.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/request.dart';
import 'package:spectrome/util/storage.dart';

class MePage extends StatefulWidget {
  static final tag = 'me';

  // View page controller
  final PageController controller;

  MePage({this.controller}) : super();

  @override
  _MeState createState() => new _MeState();
}

class _MeState extends State<MePage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // List of my posts
  final _posts = <PostDetail>[];

  // Loading indicator
  bool _loading = true;

  // Action loading indicator
  bool _action = true;

  // Has username
  bool _hu = false;

  // Request count
  int _count = 0;

  // Post loader timer
  Timer _timer;

  // Shared preferences instance
  SharedPreferences _sp;

  // Account session key
  String _session;

  // Cursor timestamp value
  String _timestamp;

  // Error message
  ErrorMessage _error;

  // Profile object
  MyProfile _profile;

  // Settings overlay entry
  OverlayEntry _oe;

  @override
  void initState() {
    super.initState();

    final n = RequestNotifier.getNotifier();

    // Set default value
    _count = n.value;

    // Add listener on request count notifier
    n.addListener(() {
      setState(() => _count = n.value);
    });

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      final session = s.getString('_session');

      _session = session;

      _sp = s;

      // Load profile if exists in the cache
      _getProfile();

      // Load profile from API
      _loadProfile();

      // Set periodic tasks for prefile updates
      _timer = Timer.periodic(Duration(seconds: 60), (_) => _loadProfile());
    };

    Storage.load().then(spc);

    // Argument callback
    final ac = (_) {
      final username = ModalRoute.of(context).settings.arguments;

      // Set has username
      _hu = username != null;
    };

    // Add callback for argument
    WidgetsBinding.instance.addPostFrameCallback(ac);
  }

  @override
  void dispose() {
    // Cancel timer
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: AppConst.loader(
          page: MePage.tag,
          argument: _loading,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
    final pts = const Padding(
      padding: EdgeInsets.only(top: 4.0),
    );

    // Http headers for image request
    final h = {Http.TOKEN_HEADER: _session};

    // Profile picture
    final p = new Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: new Container(
        decoration: new BoxDecoration(
          border: new Border.all(
            width: 0.5,
            color: ColorConst.gray.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        child: new ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: new Container(
            width: 60.0,
            height: 60.0,
            child: new Image.network(
              _profile.photoUrl,
              headers: h,
              width: 60.0,
              height: 60.0,
              errorBuilder: (c, o, s) => new Image.asset('assets/images/default.1.jpg'),
            ),
          ),
        ),
      ),
    );

    final un = new Text(
      _profile.username,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.black,
        fontSize: 15.0,
        letterSpacing: 0.33,
      ),
    );

    final nm = new Text(
      _profile.name,
      style: new TextStyle(
        fontFamily: FontConst.primary,
        color: ColorConst.darkGray,
        fontSize: 13.0,
        letterSpacing: 0.33,
      ),
    );

    // Circles callback
    final cpc = () async {
      // Create simple profile based on my profile object
      final p = new SimpleProfile(
        name: _profile.name,
        photoUrl: _profile.photoUrl,
        username: _profile.username,
      );

      await Navigator.of(context).pushNamed(CirclePage.tag, arguments: p);
    };

    final cc = new GestureDetector(
      onTap: cpc,
      behavior: HitTestBehavior.opaque,
      child: new RichText(
        textAlign: TextAlign.left,
        text: new TextSpan(
          text: _profile.circles.toString(),
          style: new TextStyle(
            fontFamily: FontConst.bold,
            fontSize: 13.0,
            color: ColorConst.darkGray,
            fontWeight: FontWeight.normal,
          ),
          children: [
            new TextSpan(
              text: '  Circles',
              style: new TextStyle(
                fontFamily: FontConst.primary,
                fontSize: 13.0,
                color: ColorConst.darkGray,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );

    // Profile details
    final i = new Padding(
      padding: EdgeInsets.only(left: 20.0, bottom: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          un,
          pts,
          nm,
          pts,
          cc,
        ],
      ),
    );

    final f = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        p,
        i,
      ],
    );

    // Share post button callback
    final sc = () {
      final d = new Duration(milliseconds: 250);
      final c = Curves.easeInOut;

      // Move to share page
      widget.controller.animateToPage(0, duration: d, curve: c);
    };

    // Share button
    final fl = new Expanded(
      flex: 1,
      child: new Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: new Button(
          text: 'Share',
          fontSize: 13.0,
          color: ColorConst.darkerGray,
          background: ColorConst.lightGray,
          padding: EdgeInsets.all(6.0),
          border: new Border.all(color: ColorConst.transparent),
          onPressed: sc,
        ),
      ),
    );

    // Circle button container
    final b = new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          fl,
        ],
      ),
    );

    // User detail container
    final u = new Container(
      height: 124.0,
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: ColorConst.gray,
          ),
        ),
      ),
      child: new Padding(
        padding: EdgeInsets.only(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
          top: 0.0,
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            f,
            b,
          ],
        ),
      ),
    );

    // Back button
    final l = new GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: new Icon(
        IconData(0xf104, fontFamily: FontConst.fal),
        color: ColorConst.darkerGray,
      ),
    );

    final t = new Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 12.0,
      ),
      child: new Icon(
        IconData(
          0xf0c9,
          fontFamily: FontConst.fal,
        ),
        color: ColorConst.darkGray,
        size: 20.0,
      ),
    );

    final ec = new Container(width: 0, height: 0);

    final rc = new Padding(
      padding: EdgeInsets.only(left: 32.0),
      child: new Container(
        width: 6.0,
        height: 6.0,
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(6.0),
          color: ColorConst.darkRed,
        ),
      ),
    );

    // Show settings button
    final ts = new Semantics(
      button: true,
      child: new GestureDetector(
        onTap: _showSettings,
        behavior: HitTestBehavior.opaque,
        child: new Stack(
          children: [
            t,
            _count > 0 ? rc : ec,
          ],
        ),
      ),
    );

    final dg = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 1 / 1,
    );

    // List of my posts
    final s = new Expanded(
      child: new GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: dg,
        physics: const ClampingScrollPhysics(),
        itemCount: _posts.length,
        itemBuilder: _postBuilder,
      ),
    );

    // Shimmer loading
    final a = new Expanded(
      child: new GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: dg,
        physics: const ClampingScrollPhysics(),
        itemCount: 6,
        itemBuilder: _shimmerBuilder,
      ),
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        heroTag: 4,
        transitionBetweenRoutes: false,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        backgroundColor: ColorConst.white,
        border: new Border(bottom: BorderSide.none),
        leading: _hu ? l : ec,
        trailing: ts,
        middle: new Text(
          'Me',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
            fontSize: 16.0,
          ),
        ),
      ),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          u,
          _action ? a : s,
        ],
      ),
    );
  }

  /// Get post content
  Widget _postBuilder(BuildContext context, int index) {
    // Get thumbnail card
    return new Padding(
      padding: EdgeInsets.only(
        left: index % 2 == 1 ? 0.5 : 0.0,
        right: index % 2 == 0 ? 0.5 : 0.0,
        top: index > 1 ? 1.0 : 0.0,
      ),
      child: new PostThumbCard(
        key: new Key(_posts[index].post.code),
        detail: _posts[index],
        session: _session,
      ),
    );
  }

  /// Get shimmer loading
  Widget _shimmerBuilder(BuildContext context, int index) {
    return new Padding(
      padding: EdgeInsets.only(
        left: index % 2 == 1 ? 0.5 : 0.0,
        right: index % 2 == 0 ? 0.5 : 0.0,
        top: index > 1 ? 1.0 : 0.0,
      ),
      child: new GridShimmer(),
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

  /// Show settings overlay
  void _showSettings() {
    // Overlay builder
    final b = (BuildContext context) {
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;

      final hr = new Divider(
        color: ColorConst.gray,
        height: 1.0,
      );

      final eb = new Button(
        color: ColorConst.darkerGray,
        background: ColorConst.transparent,
        radius: BorderRadius.zero,
        text: 'Update profile',
        onPressed: _updateProfile,
      );

      final sb = new Button(
        color: ColorConst.darkRed,
        background: ColorConst.transparent,
        radius: BorderRadius.zero,
        text: 'Sign Out',
        onPressed: _signOut,
      );

      final cb = new Button(
        color: ColorConst.darkGray,
        background: ColorConst.transparent,
        radius: BorderRadius.zero,
        text: 'Close',
        onPressed: _closeSettings,
      );

      // Circle requets text
      final rbt = new Text(
        'Incoming requests',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          color: ColorConst.darkerGray,
          fontSize: 14.0,
          letterSpacing: 0.33,
        ),
      );

      // Circle request button request count
      final rbc = new Padding(
        padding: EdgeInsets.all(6.0),
        child: new ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: new Container(
            color: ColorConst.darkRed,
            width: 16.0,
            height: 16.0,
            child: new Center(
              child: new Text(
                _count.toString(),
                style: new TextStyle(
                  fontFamily: FontConst.primary,
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: ColorConst.white,
                ),
              ),
            ),
          ),
        ),
      );

      // Circle request button
      final rb = new Semantics(
        button: true,
        focusable: true,
        child: new GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(RequestPage.tag),
          behavior: HitTestBehavior.opaque,
          child: new Container(
            height: 40.0,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                rbt,
                _count > 0 ? rbc : new Container(),
              ],
            ),
          ),
        ),
      );

      // List of buttons
      final it = new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          eb,
          hr,
          rb,
          hr,
          sb,
          hr,
          cb,
        ],
      );

      return new Container(
        width: width,
        height: height,
        color: ColorConst.darkerGray.withOpacity(0.67),
        child: new Center(
          child: new FittedBox(
            child: new Listener(
              onPointerUp: (_) => _closeSettings(),
              child: new Container(
                width: width - 120,
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: ColorConst.lightGray,
                ),
                child: new Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: it,
                ),
              ),
            ),
          ),
        ),
      );
    };

    _oe = OverlayEntry(builder: b);

    // Show overlay
    Overlay.of(context).insert(_oe);
  }

  /// Close settings
  void _closeSettings() {
    if (_oe == null) {
      return;
    }

    // Remove overlay from page
    _oe.remove();
    _oe = null;
  }

  /// Get profile data from cache
  void _getProfile() {
    // Check if profile is in the cache
    if (!_sp.containsKey('_me')) {
      return;
    }

    final pb = _sp.getString('_me');

    // Decode profile string
    _profile = MyProfile.fromJson(pb);

    // Load profile
    setState(() => _loading = false);
  }

  /// Load profile from API
  void _loadProfile() {
    dev.log('Profile is loading.');

    // Handle HTTP response
    final sc = (MyProfileResponse r) async {
      dev.log('My profile request sent.');

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

      // Update profile instance
      _profile = r.profile;

      // Load posts if number of posts are greater then zero
      if (_profile.posts > 0) {
        _loadPosts();
      } else {
        _action = false;
      }

      // Update profile cache
      _sp.setString('_me', r.profile.toJson());
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown profile load error. Please try again later.';

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

    MyProfileService.call(_session).then(sc).catchError(e).whenComplete(cc);
  }

  /// Load my posts
  void _loadPosts() async {
    dev.log('My posts are loading.');

    // Handle HTTP response
    final sc = (MySharedPostResponse r) async {
      dev.log('My posts request sent.');

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

      // Clear posts
      _posts.clear();

      // Populate my posts
      _posts.addAll(r.posts);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown my posts load error. Please try again later.';

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
    final request = MySharedPostService.call(_session, _timestamp);

    request.then(sc).catchError(e).whenComplete(cc);
  }

  /// Go to profile update page
  void _updateProfile() async {
    await Navigator.of(context).pushNamed(UpdatePage.tag);
  }

  /// Sign out from current session
  void _signOut() async {
    // Handle HTTP response
    final sc = (BasicResponse r) async {
      dev.log('Sign in request sent.');

      if (!r.status) {
        if (r.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _showSnackBar(r.message, isError: true);
        }

        return;
      }

      // Create new auth key
      _sp.remove('_session');
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown sign out error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    // Complete callback
    final cc = () async {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      final r = (Route<dynamic> route) => false;
      await Navigator.of(context).pushNamedAndRemoveUntil(SignInPage.tag, r);
    };

    await SignOutService.call(_session).then(sc).catchError(e).whenComplete(cc);
  }
}
