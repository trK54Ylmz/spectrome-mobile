import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrome/item/input.dart';
import 'package:spectrome/model/profile/me.dart';
import 'package:spectrome/model/profile/simple.dart';
import 'package:spectrome/service/query/following.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';
import 'package:spectrome/util/storage.dart';

class RestrictionPage extends StatefulWidget {
  static final tag = 'restriction';

  RestrictionPage() : super();

  _RestrictionState createState() => new _RestrictionState();
}

class _RestrictionState extends State<RestrictionPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Page view controller
  final _pc = new PageController();

  // Search input controller
  final _sc = new TextEditingController();

  // User typing or not
  final _typing = new ValueNotifier<bool>(false);

  // List of selected users
  final _users = <SimpleProfile>[];

  // List of suggestions
  final _suggests = <SimpleProfile>[];

  // Check if argument is loaded
  bool _loaded = false;

  // Loading indicator
  bool _loading = true;

  // Account session key
  String _session;

  // Error message
  ErrorMessage _error;

  @override
  void initState() {
    super.initState();

    // User typing listener callback
    final lc = () {
      final d = Duration(seconds: 1);
      final c = Curves.easeIn;

      // Move between pages according value
      if (_typing.value) {
        _pc.animateToPage(1, duration: d, curve: c);
      } else {
        _pc.animateToPage(0, duration: d, curve: c);
      }
    };

    // Shared preferences callback
    final sc = (SharedPreferences sp) {
      _session = sp.getString('_session');
    };

    _typing.addListener(lc);

    Storage.load().then(sc);
  }

  @override
  Widget build(BuildContext context) {
    final users = ModalRoute.of(context).settings.arguments;

    // Load route arguments if specified
    if (!_loaded && users != null) {
      _loaded = true;
      _users.addAll(users);
    }

    return Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: AppConst.loader(
          page: RestrictionPage.tag,
          argument: _loading,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
    final ts = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
    );

    final hs = new TextStyle(
      fontFamily: FontConst.primary,
      fontSize: 14.0,
      letterSpacing: 0.33,
      color: ColorConst.gray,
      fontWeight: FontWeight.normal,
    );

    // Selected users list builder
    final lb = (BuildContext context, int i) {};

    // Suggested users list builder
    final sb = (BuildContext context, int i) {};

    // Selected users
    final l = new Container(
      child: new ListView.builder(
        itemBuilder: lb,
      ),
    );

    // User suggestions
    final s = new Container(
      child: new ListView.builder(
        itemBuilder: sb,
      ),
    );

    return new CupertinoPageScaffold(
      backgroundColor: ColorConst.white,
      navigationBar: new CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.only(top: 4.0, bottom: 4.0),
        backgroundColor: ColorConst.white,
        leading: new GestureDetector(
          onTap: () => Navigator.of(context).pop(_users),
          child: new Icon(
            IconData(0xf104, fontFamily: FontConst.fal),
            color: ColorConst.darkerGray,
          ),
        ),
        middle: new FormText(
          hint: 'Type username',
          hintStyle: hs,
          style: ts,
          controller: _sc,
          onChange: (t) {
            if (t.length < 2) {
              return null;
            }

            // Select typing
            if (!_typing.value) {
              setState(() => _typing.value = true);
            }

            // Send request and collect suggestions
            fetch();

            return null;
          },
          borderColor: ColorConst.gray,
        ),
      ),
      child: new PageView(
        physics: const ClampingScrollPhysics(),
        children: [
          l,
          s,
        ],
      ),
    );
  }

  /// Fetch users by using query filter
  void fetch() {
    dev.log('User search triggered.');

    if (_loading) {
      return;
    }

    final t = _sc.text;

    dev.log('User search request sending for "$t".');

    // Set loading true
    setState(() => _loading = true);

    // Handle HTTP response
    final c = (FollowingQueryResponse r) async {
      dev.log('User search request sent.');

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

      // Clear current list
      _suggests.clear();

      // Add all users
      _suggests.addAll(r.users);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

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

    FollowingQueryService.call(_session, t).then(c).catchError(e).whenComplete(cc);
  }
}
