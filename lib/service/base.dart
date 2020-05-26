import 'dart:io';
import 'package:spectrome/service/response.dart';

abstract class Service {
  /// Handle HTTP IO errors
  static T handleError<T extends BasicResponse>(e, StackTrace s, T t) {
    t.status = false;
    if (e is SocketException) {
      t.isNetErr = true;
      t.message = 'Please check your network connection';
    } else {
      t.message = 'An error occurred';
    }

    return t;
  }
}
