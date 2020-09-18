import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/service/system/term.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';

class TermPage extends StatefulWidget {
  static final tag = 'term';

  TermPage() : super();

  @override
  _TermState createState() => new _TermState();
}

class _TermState extends State<TermPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();

  // Term items
  final _items = <MapEntry<String, String>>[];

  // Loading indicator
  bool _loading = true;

  // Error message
  ErrorMessage _error;

  @override
  void initState() {
    super.initState();

    final c = (TermResponse v) async {
      dev.log('Term request sent.');

      if (!v.status) {
        if (v.isNetErr ?? false) {
          // Create network error
          _error = ErrorMessage.network();
        } else {
          // Create custom error
          _error = ErrorMessage.custom(v.message);
        }
        return;
      }

      // Populate items
      _items.addAll(v.items);
    };

    // Error callback
    final e = (e, s) {
      final msg = 'Unknown error. Please try again later.';

      dev.log(msg, stackTrace: s);

      // Create error message
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

    TermService.call().then(c).catchError(e).whenComplete(cc);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: AppConst.loader(
        page: TermPage.tag,
        argument: _loading,
        error: _error,
        callback: _getPage,
      ),
    );
  }

  /// Get content of the version page
  Widget _getPage() {
    // Back button
    final l = new GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: new Icon(
        IconData(0xf104, fontFamily: FontConst.fal),
        color: ColorConst.darkerGray,
      ),
    );

    final c = new ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: _items.length,
      itemBuilder: _builder,
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
        leading: l,
        middle: new Text(
          'Terms',
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
            fontSize: 16.0,
          ),
        ),
      ),
      body: new SafeArea(
        child: new Padding(
          padding: EdgeInsets.all(8.0),
          child: c,
        ),
      ),
    );
  }

  /// Terms widgets builder
  Widget _builder(BuildContext context, int index) {
    switch (_items[index].key) {
      case 'padding':
        return new Padding(
          padding: EdgeInsets.only(
            top: double.parse(_items[index].value),
          ),
        );
      case 'text':
        return new Text(
          _items[index].value,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            letterSpacing: 0.33,
            fontSize: 12.0,
            color: ColorConst.darkGray,
            height: 1.33,
          ),
        );
      case 'title':
        return new Text(
          _items[index].value,
          style: new TextStyle(
            fontFamily: FontConst.bold,
            letterSpacing: 0.33,
            fontSize: 14.0,
            color: ColorConst.darkerGray,
            height: 2.33,
          ),
        );
      case 'subtitle':
        return new Text(
          _items[index].value,
          style: new TextStyle(
            fontFamily: FontConst.bold,
            letterSpacing: 0.33,
            fontSize: 13.0,
            color: ColorConst.darkerGray,
            height: 2.33,
          ),
        );
      case 'list':
        return new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.5),
              child: new Icon(
                new IconData(0xf111, fontFamily: FontConst.fa),
                color: ColorConst.darkGray,
                size: 4.0,
              ),
            ),
            new Expanded(
              child: new Text(
                _items[index].value,
                style: new TextStyle(
                  fontFamily: FontConst.primary,
                  letterSpacing: 0.33,
                  fontSize: 12.0,
                  color: ColorConst.darkGray,
                  height: 1.33,
                ),
              ),
            ),
          ],
        );
      default:
        return new Container(width: 0, height: 0);
    }
  }
}
