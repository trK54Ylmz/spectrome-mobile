import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:spectrome/item/form.dart';

typedef CallbackFunc<T> = T Function(T value);

class FormText extends StatefulWidget {
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

  final Color borderColor;

  final double cursorWidth;

  final double radius;

  final bool enabled;

  final bool obscure;

  final int size;

  FormText({
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
    this.size = 1000,
    this.radius = 8.0,
    this.cursorWidth = 1.0,
    this.enabled = true,
    this.obscure = false,
    this.borderColor = const Color(0xffcccccc),
    this.padding = const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 6.0,
    ),
  });

  @override
  TextInputState createState() => new TextInputState();
}

class TextInputState extends State<FormText> {
  final TextEditingController _c = new TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Register form input
    FormValidation.of(context)?.unregister(this);
    FormValidation.of(context)?.register(this);
  }

  @override
  void deactivate() {
    super.deactivate();

    FormValidation.of(context)?.unregister(this);
  }

  @override
  Widget build(BuildContext context) {
    return new CupertinoTextField(
      controller: widget.controller ?? _c,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      onChanged: widget.onChange,
      onSubmitted: widget.onSaved,
      obscureText: widget.obscure,
      style: widget.style,
      padding: widget.padding,
      placeholder: widget.hint,
      placeholderStyle: widget.hintStyle,
      keyboardType: widget.inputType,
      maxLength: widget.size,
      cursorWidth: widget.cursorWidth,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(widget.radius),
        color: const Color(0xffffffff),
        border: new Border.all(
          width: 1.0,
          color: widget.borderColor.withOpacity(0.67),
        ),
      ),
    );
  }

  /// Validate input by using validator and text
  String validate() {
    if (widget.validator == null) {
      return null;
    }

    return widget.validator.call((widget.controller ?? _c).text);
  }
}
