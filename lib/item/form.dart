import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:spectrome/item/input.dart';

class FormValidation extends StatefulWidget {
  // Children widgets
  final Widget child;

  const FormValidation({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  /// Get the closest [_FormValidationState]
  ///
  /// Helps to update state of the input group
  static FormValidationState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormValidationScope>();
    return scope == null ? null : scope.formState;
  }

  FormValidationState createState() => new FormValidationState();
}

class FormValidationState extends State<FormValidation> {
  int _generation = 0;

  // Form input group from children widgets
  final List<TextInputState> _fields = <TextInputState>[];

  // Error messages
  final List<String> errors = <String>[];

  /// Register field to form
  void register(TextInputState field) {
    _fields.add(field);

    dev.log('Field "${field.widget.hint}" registered to form.');
  }

  /// Unregister field from form
  void unregister(TextInputState field) {
    _fields.remove(field);
  }

  /// Validate form according to given fields
  bool validate() {
    // Clear errors list
    errors.clear();

    for (int i = 0; i < _fields.length; i++) {
      // Validate input
      final result = _fields[i].validate();

      // Append error to errors list
      if (result != null) {
        errors.add(result);
      }
    }

    return errors.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return new _FormValidationScope(
      formState: this,
      gen: _generation,
      child: widget.child,
    );
  }
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
