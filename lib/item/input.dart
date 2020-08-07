import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:spectrome/item/form.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

typedef CallbackFunc<T> = T Function(T value);

class FormText extends StatefulWidget {
  final TextEditingController controller;

  final ScrollController scrollController;

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

  final TextAlign textAlign;

  final Color borderColor;

  final double cursorWidth;

  final double radius;

  final bool enabled;

  final bool obscure;

  final bool showObscure;

  final int size;

  final int maxLines;

  final int minLines;

  final bool expands;

  FormText({
    Key key,
    this.controller,
    this.scrollController,
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
    this.maxLines,
    this.minLines,
    this.size = 1000,
    this.radius = 8.0,
    this.cursorWidth = 1.0,
    this.enabled = true,
    this.obscure = false,
    this.expands = false,
    this.showObscure = false,
    this.textAlign = TextAlign.start,
    this.borderColor = const Color(0xffcccccc),
    this.padding = const EdgeInsets.only(
      top: 10.0,
      bottom: 8.0,
      left: 8.0,
      right: 8.0,
    ),
  });

  @override
  TextInputState createState() => new TextInputState();
}

class TextInputState extends State<FormText> {
  final TextEditingController _c = new TextEditingController();

  bool obscure = false;

  @override
  void initState() {
    super.initState();

    obscure = widget.obscure;
  }

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
    Widget suffix = new Container(width: 0.0, height: 0.0);

    // Create password to text field conversion
    if (widget.showObscure) {
      final icon = obscure ? 0xf070 : 0xf06e;

      suffix = new GestureDetector(
        onTap: () => setState(() => obscure = obscure != true),
        child: new Padding(
          padding: widget.padding,
          child: new Icon(
            IconData(icon, fontFamily: FontConst.fa),
            color: ColorConst.gray,
            size: widget.style.fontSize,
          ),
        ),
      );
    }

    return new CupertinoTextField(
      controller: widget.controller ?? _c,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      onChanged: widget.onChange,
      onSubmitted: widget.onSaved,
      style: widget.style,
      padding: widget.padding,
      placeholder: widget.hint,
      placeholderStyle: widget.hintStyle,
      keyboardType: widget.inputType,
      maxLength: widget.size,
      cursorWidth: widget.cursorWidth,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      expands: widget.expands,
      scrollController: widget.scrollController,
      obscureText: obscure,
      suffix: suffix,
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(widget.radius),
        color: widget.enabled ? ColorConst.white : ColorConst.gray.withOpacity(0.33),
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
