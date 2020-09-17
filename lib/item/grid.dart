import 'package:flutter/cupertino.dart';
import 'package:spectrome/theme/color.dart';

class GridShimmer extends StatefulWidget {
  const GridShimmer() : super();

  _GridShimmerState createState() => new _GridShimmerState();
}

class _GridShimmerState extends State<GridShimmer> with SingleTickerProviderStateMixin {
  // Animation controller for mask
  AnimationController _ac;

  // Animation curve
  CurvedAnimation _ca;

  @override
  void initState() {
    super.initState();

    _ac = new AnimationController(
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _ac.addListener(() => setState(() => null));

    // Update animation state
    _ac.repeat();

    _ca = new CurvedAnimation(
      parent: _ac,
      curve: Curves.linear,
    );
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
      final c = (((_ca.value - 0.5).abs() / (_ac.upperBound - 0.5)) * 10).toInt() + 220;

      final color = new Color.fromRGBO(c, c, c, 1.0);

      final g = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, color],
        tileMode: TileMode.clamp,
      );

      return g.createShader(r);
    };

    return new Container(
      child: new ShaderMask(
        shaderCallback: c,
        blendMode: BlendMode.srcIn,
        child: new Container(color: ColorConst.gray),
      ),
    );
  }
}
