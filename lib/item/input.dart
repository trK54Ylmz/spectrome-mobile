import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

typedef CallbackFunc<T> = T Function(T value);

class TextInput extends StatefulWidget {
  final TextEditingController controller;

  final String initialValue;

  final FocusNode focusNode;

  final CallbackFunc<String> onSaved;

  final CallbackFunc<String> validator;

  final List<TextInputFormatter> inputFormatters;

  final CallbackFunc<String> onChange;

  final String hint;

  final TextStyle style;

  final TextStyle hintStyle;

  final TextInputType inputType;

  final EdgeInsetsGeometry padding;

  final double radius;

  final bool enabled;

  final bool obscure;

  TextInput({
    Key key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.hint,
    this.style,
    this.hintStyle,
    this.inputType = TextInputType.text,
    this.onChange,
    this.radius = 8.0,
    this.enabled = true,
    this.obscure = false,
    this.padding = const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 6.0,
    ),
  });

  @override
  TextInputState createState() => new TextInputState();
}

class TextInputState extends State<TextInput> {
  @override
  Widget build(BuildContext context) {
    return new DecoratedBox(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(widget.radius),
        color: const Color(0xffffffff),
        border: new Border.all(
          width: 1.0,
        ),
      ),
      child: new CupertinoTextField(
        enabled: widget.enabled,
        onChanged: widget.onChange,
        obscureText: widget.obscure,
        style: widget.style,
        padding: widget.padding,
        placeholder: widget.hint,
        placeholderStyle: widget.hintStyle,
        keyboardType: widget.inputType,
      ),
    );
  }

  String validate() {
    return null;
  }
}
