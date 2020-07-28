import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/item/fatal.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/util/error.dart';

class ScreenConst {
  static const short = [720, 480];

  static const square = [720, 720];

  static const tall = [720, 860];
}

class AppConst {
  // Application version
  static const version = 0.1;

  // Photo item identity
  static const photo = 1;

  // Video item identity
  static const video = 2;

  // Post screen sizes
  static const screen = ScreenConst;

  /// Get widget according to scenario
  static Widget loader({
    String page,
    bool argument,
    ErrorMessage error,
    Function callback,
  }) {
    // Get loading indicator
    if (argument) return new Loading();

    // Get error page
    if (error != null) return Fatal(error: error, page: page);

    return callback.call();
  }
}
