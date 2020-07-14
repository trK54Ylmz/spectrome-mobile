import 'package:flutter/material.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';

class Button extends StatefulWidget {
  // The text of the button
  final String text;

  // Minimum size of the button
  final double width;

  // The color of the button's background
  final Color color;

  // The callback that is called when the button is tapped or otherwise activated
  final VoidCallback onPressed;

  final bool disabled;

  const Button({
    Key key,
    this.text,
    this.onPressed,
    this.disabled = false,
    this.width = double.infinity,
    this.color = const Color(0xff007aff),
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
    final c = _active || widget.disabled;

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
      child: new Semantics(
        button: true,
        child: new ConstrainedBox(
          constraints: new BoxConstraints(
            maxWidth: widget.width,
            minWidth: widget.width,
          ),
          child: new Container(
            padding: new EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: c ? widget.color.withOpacity(0.67) : widget.color,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: new Text(
              widget.text,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: new TextStyle(
                color: ColorConst.white,
                fontFamily: FontConst.primary,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
