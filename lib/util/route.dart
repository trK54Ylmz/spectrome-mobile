import 'package:flutter/material.dart';

class DefaultRoute<T> extends PageRoute<T> {
  // Route settings
  final RouteSettings settings;

  // Route widget
  final Widget widget;

  DefaultRoute({
    this.widget,
    this.settings = const RouteSettings(),
  }) : super(settings: settings);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return widget;
  }

  @override
  bool get maintainState => true;

  @override
  String get barrierLabel => null;

  @override
  Color get barrierColor => const Color(0xffffffff);
}
