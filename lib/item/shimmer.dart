import 'package:flutter/cupertino.dart';
import 'package:spectrome/theme/color.dart';

class Shimmer extends StatefulWidget {
  final Widget child;

  final Duration duration;

  const Shimmer({
    this.child,
    this.duration,
  });

  _ShimmerState createState() => new _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  // Animation controller for mask
  AnimationController _ac;

  @override
  void initState() {
    super.initState();

    _ac = new AnimationController(
      lowerBound: 0.0,
      upperBound: 100.0,
      vsync: this,
      duration: widget.duration,
    );

    _ac.addListener(() => setState(() => null));

    // Update animation state
    _ac.repeat();
  }

  @override
  void dispose() {
    if (_ac != null) {
      _ac.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = (Rect r) {
      // Calculate current value of animation for gradient
      final c = ((_ac.value - 50) / (_ac.upperBound - 50)) * 2.0;

      final g = LinearGradient(
        begin: Alignment(c - 1, c - 1),
        end: Alignment(c + 1, c + 1),
        colors: [
          ColorConst.lightGray,
          ColorConst.gray,
          ColorConst.lightGray,
        ],
        stops: [0, 0.5, 1],
        tileMode: TileMode.clamp,
      );

      return g.createShader(r);
    };

    return new Container(
      child: new ShaderMask(
        shaderCallback: c,
        blendMode: BlendMode.srcIn,
        child: widget.child,
      ),
    );
  }
}
