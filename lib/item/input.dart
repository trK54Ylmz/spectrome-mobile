import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final String hint;

  final TextStyle style;

  final TextStyle hintStyle;

  final Function onChange;

  final EdgeInsetsGeometry padding;

  final double radius;

  final bool enabled;

  final bool obscure;

  TextInput({
    this.hint,
    this.style,
    this.hintStyle,
    this.onChange,
    this.enabled = true,
    this.obscure = false,
    this.radius = 8.0,
    this.padding = const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 4.0,
    ),
  });

  @override
  _TextInputState createState() => new _TextInputState();
}

class _TextInputState extends State<TextInput> {
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
        placeholder: widget.hint,
        placeholderStyle: widget.hintStyle,
      ),
    );
  }
}
