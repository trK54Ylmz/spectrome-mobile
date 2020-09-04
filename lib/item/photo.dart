import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/item/button.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

typedef LoadError = Widget Function();

class Photo extends StatefulWidget {
  final Key key;

  final String url;

  final double width;

  final double height;

  final Map<String, String> headers;

  final LoadError onError;

  final int retry;

  final bool trace;

  const Photo({
    this.key,
    this.url,
    this.width,
    this.height,
    this.headers,
    this.onError,
    this.retry = 3,
    this.trace = false,
  })  : assert(width != null),
        assert(height != null),
        super(key: key);

  _PhotoState createState() => new _PhotoState();
}

class _PhotoState extends State<Photo> {
  // Image widget
  Image _image;

  // How many times request sent
  int _retried = 0;

  @override
  void initState() {
    super.initState();

    _image = new Image(
      width: widget.width,
      height: widget.height,
      key: new ValueKey(widget.url),
      errorBuilder: _callback,
      image: new NetworkImage(
        widget.url,
        headers: widget.headers,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Precache image
    precacheImage(_image.image, context);
  }

  @override
  Widget build(BuildContext context) {
    return _image;
  }

  /// Network image error callback widget
  Widget _callback(BuildContext context, Object obj, StackTrace s) {
    final msg = 'Image load error from "${widget.url}"';

    if (widget.trace) {
      dev.log(msg, stackTrace: s);
    } else {
      dev.log(msg);
    }

    // Call callback function
    if (widget.onError != null) {
      widget.onError.call();
    }

    final c = new Container(
      width: widget.width,
      height: widget.height,
      color: ColorConst.lightGray,
    );

    if (widget.retry > 0 && _retried < widget.retry) {
      final b = new Button(
        text: 'Retry',
        color: ColorConst.black,
        background: ColorConst.transparent,
        width: widget.width / 2,
        border: Border.all(width: 0.0, color: ColorConst.transparent),
        onPressed: _retry,
      );

      return new Stack(
        alignment: Alignment.center,
        children: [
          c,
          b,
        ],
      );
    } else {
      final e = new Text(
        'Could not load.',
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          color: ColorConst.black,
          letterSpacing: 0.33,
        ),
      );

      return new Stack(
        alignment: Alignment.center,
        children: [
          c,
          e,
        ],
      );
    }
  }

  /// For image to retry
  void _retry() {
    setState(() => _retried += 1);
  }
}
