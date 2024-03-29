import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/item/grid.dart';
import 'package:spectrome/item/thumb.dart';
import 'package:spectrome/model/post/detail.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/model/profile/user.dart';
import 'package:spectrome/page/circle.dart';
import 'package:spectrome/page/sign_in.dart';
import 'package:spectrome/service/post/shared.dart';
import 'package:spectrome/service/profile/user.dart';
import 'package:spectrome/service/user/cancel.dart';
import 'package:spectrome/service/user/add.dart';
import 'package:spectrome/service/user/remove.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/http.dart';
import 'package:spectrome/util/storage.dart';

class ProfilePage extends StatefulWidget {
  static final tag = 'profile';

  ProfilePage() : super();

  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // List of my posts
  final _posts = <PostDetail>[];

  // Is user in circle
  bool _circled = false;

  // Is circle request sent
  bool _requested = false;

  // Loading indicator
  bool _loading = true;

  // Action loading indicator
  bool _action = false;

  // Account session key
  String _session;

  // Username of current user
  String _username;

  // Error message
  ErrorMessage _error;

  // Profile object
  UserProfile _profile;

  // Cursor timestamp value
  String _timestamp;

  @override
  void initState() {
    super.initState();

    // Shared preferences callback
    final spc = (SharedPreferences s) {
      final session = s.getString('_session');

      _session = session;

      // Load profile from API
      _getProfile();
    };

    // Username argument callback
    final ac = (_) {
      final username = ModalRoute.of(context).settings.arguments;

      // Set username
      _username = username;

      // Get storage kv
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
          page: ProfilePage.tag,
          argument: _loading,
          error: _error,
          callback: _getPage,
          arguments: _username,
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
      // User should be in circle
      if (!_circled) {
        return;
      }

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

    final fl = new Button(
      text: 'Add',
      disabled: _action,
      fontSize: 13.0,
      padding: EdgeInsets.all(6.0),
      background: ColorConst.button,
      color: ColorConst.white,
      border: new Border.all(
        color: ColorConst.button,
      ),
      onPressed: _addCircle,
    );

    final rq = new Button(
      text: 'Request sent',
      disabled: _action,
      fontSize: 13.0,
      padding: EdgeInsets.all(6.0),
      background: ColorConst.transparent,
      color: ColorConst.darkGray,
      border: new Border.all(
        color: ColorConst.gray,
      ),
      onPressed: _cancel,
    );

    final uf = new Button(
      text: 'Remove',
      disabled: _action,
      fontSize: 13.0,
      padding: EdgeInsets.all(6.0),
      background: ColorConst.button,
      color: ColorConst.white,
      border: new Border.all(
        color: ColorConst.button,
      ),
      onPressed: _removeCircle,
    );

    final fb = new Expanded(
      flex: 1,
      child: new Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: _circled ? uf : (_requested ? rq : fl),
      ),
    );

    // Circle button container
    final b = new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          fb,
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
        heroTag: 5,
        transitionBetweenRoutes: false,
        padding: EdgeInsetsDirectional.only(
          top: 4.0,
          bottom: 4.0,
        ),
        backgroundColor: ColorConst.white,
        border: new Border(bottom: BorderSide.none),
        leading: new GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: new Icon(
            IconData(0xf104, fontFamily: FontConst.fal),
            color: ColorConst.darkerGray,
          ),
        ),
        middle: new Text(
          'Profile',
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

  /// Get profile from API
  void _getProfile() async {
    dev.log('User rofile is loading.');

    // Handle HTTP response
    final sc = (UserProfileResponse r) async {
      dev.log('User profile request sent.');

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
          _error = ErrorMessage.custom(r.message);
        }

        return;
      }

      // Update profile instance
      _profile = r.profile;
      _requested = r.request;
      _circled = r.circle;

      // Load posts if number of posts are greater then zero
      if (_profile.posts > 0) {
        _loadPosts();
      } else {
        _action = false;
      }
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

    // Prepare request
    final s = UserProfileService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }

  /// Load my posts
  void _loadPosts() async {
    dev.log('User posts are loading.');

    // Handle HTTP response
    final sc = (UserSharedPostResponse r) async {
      dev.log('User posts request sent.');

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
      final msg = 'Unknown user posts load error. Please try again later.';

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
    final request = UserSharedPostService.call(
      session: _session,
      username: _profile.username,
      timestamp: _timestamp,
    );

    request.then(sc).catchError(e).whenComplete(cc);
  }

  /// Add user in circle
  void _addCircle() async {
    dev.log('Add circle button clicked.');

    if (_action) {
      return;
    }

    setState(() => _action = true);

    dev.log('Add circle request sending.');

    final sc = (CircleAddResponse r) async {
      dev.log('Add circle request sent.');

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

      // Set request sent
      _requested = true;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown add circle error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _action = false);
    };

    // Prepare request
    final s = CircleAddService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }

  /// Remove user from circle
  void _removeCircle() async {
    dev.log('Remove circle button clicked.');

    if (_action) {
      return;
    }

    setState(() => _action = true);

    dev.log('Remove circle request sending.');

    final sc = (CircleRemoveResponse r) async {
      dev.log('Remove circle request sent.');

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

      // Set circle as false
      _circled = false;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown remove circle error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _action = false);
    };

    // Prepare request
    final s = CircleRemoveService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }

  /// Cancel circle request
  void _cancel() async {
    dev.log('Intention cancel button clicked.');

    if (_action) {
      return;
    }

    setState(() => _action = true);

    dev.log('Intention cancel request sending.');

    final sc = (IntentionCancelResponse r) async {
      dev.log('Intention cancel request sent.');

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

      // Set request sent as false
      _requested = false;
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown cancel error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create unknown error message
      _error = ErrorMessage.custom(msg);
    };

    final cc = () {
      // Skip if dispose method called from application
      if (!this.mounted) {
        return;
      }

      setState(() => _action = false);
    };

    // Prepare request
    final s = IntentionCancelService.call(_session, _username);

    await s.then(sc).catchError(e).whenComplete(cc);
  }
}
