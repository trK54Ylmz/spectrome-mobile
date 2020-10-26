import 'package:flutter/cupertino.dart';

class RequestNotifier {
  // Request counter
  static ValueNotifier<int> _notifier;

  /// Create and get requsest notifier
  static ValueNotifier<int> getNotifier() {
    if (_notifier == null) {
      _notifier = new ValueNotifier<int>(0);
    }

    return _notifier;
  }
}
