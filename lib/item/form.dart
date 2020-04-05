import 'package:flutter/cupertino.dart';
import 'package:spectrome/item/input.dart';

class FormValidation extends StatefulWidget {
  // Children widgets
  final Widget child;

  // Form input group from children widgets
  final List<TextInputState> fields;

  // Error messages
  final List<String> errors;

  const FormValidation({
    Key key,
    @required this.child,
    this.errors = const <String>[],
    this.fields = const <TextInputState>[],
  });

  /// Get the closest [_FormValidationState]
  /// 
  /// Helps to update state of the input group
  static FormValidationState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormValidationScope>();
    if (scope == null) {
      return null;
    }

    return scope.formState;
  }

  FormValidationState createState() => new FormValidationState();
}

class _FormValidationScope extends InheritedWidget {
  // Current generation of the form
  final int gen;

  // Form state
  final FormValidationState formState;

  _FormValidationScope({
    Key key,
    Widget child,
    this.formState,
    this.gen,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_FormValidationScope old) => gen != old.gen;
}

class FormValidationState extends State<FormValidation> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}
