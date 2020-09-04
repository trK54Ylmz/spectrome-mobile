import 'package:flutter/material.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class Button extends StatefulWidget {
  // The text of the button
  final String text;

  // Minimum size of the button
  final double width;

  // The color of the button's text
  final Color color;

  // The color of the button's background
  final Color background;

  // Border of the button
  final Border border;

  // Border radius
  final BorderRadius radius;

  // Button padding value
  final EdgeInsets padding;

  // The callback that is called when the button is tapped or otherwise activated
  final VoidCallback onPressed;

  // Button is disabled or not
  final bool disabled;

  // Font size of button
  final double fontSize;

  const Button({
    Key key,
    this.text,
    this.onPressed,
    this.border,
    this.disabled = false,
    this.fontSize = 14.0,
    this.width = double.infinity,
    this.color = ColorConst.white,
    this.background = ColorConst.button,
    this.padding = const EdgeInsets.all(12.0),
    this.radius = const BorderRadius.vertical(
      top: Radius.circular(8.0),
      bottom: Radius.circular(8.0),
    ),
  })  : assert(text != null),
        super(key: key);

  @override
  _ButtonState createState() => new _ButtonState();
}

class _ButtonState extends State<Button> {
  // Whether the button is enabled or disabled. Buttons are deactivated by default
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    bool b, c;
    if (widget.background == ColorConst.transparent) {
      b = false;
      c = _active || widget.disabled;
    } else {
      b = _active || widget.disabled;
      c = true;
    }

    return new GestureDetector(
      onTapDown: (_) {
        setState(() => _active = true);
      },
      onTapUp: (_) {
        setState(() => _active = false);
      },
      onTap: () {
        // Disable button should be un-clickable
        if (widget.disabled) return;

        widget.onPressed.call();
      },
      behavior: HitTestBehavior.opaque,
      child: new Semantics(
        button: true,
        focusable: true,
        child: new ConstrainedBox(
          constraints: new BoxConstraints(
            maxWidth: widget.width,
            minWidth: widget.width,
          ),
          child: new Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: b ? widget.background.withOpacity(0.67) : widget.background,
              border: widget.border,
              borderRadius: widget.radius,
            ),
            child: new Text(
              widget.text,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: new TextStyle(
                color: c ? widget.color.withOpacity(0.67) : widget.color,
                fontFamily: FontConst.primary,
                fontSize: widget.fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
