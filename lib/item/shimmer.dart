import 'package:flutter/cupertino.dart';
import 'package:spectrome/theme/color.dart';

class Shimmer extends StatefulWidget {
  const Shimmer() : super();

  _ShimmerState createState() => new _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  // Animation controller for mask
  AnimationController _ac;

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
    final width = MediaQuery.of(context).size.width;
    final pt = new Padding(padding: EdgeInsets.only(top: 12.0));
    final pts = new Padding(padding: EdgeInsets.only(top: 4.0));

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

    final pp = new Container(
      width: 30.0,
      height: 30.0,
      decoration: new BoxDecoration(
        color: ColorConst.gray,
        border: new Border.all(
          width: 0.5,
          color: ColorConst.gray.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
    );

    final ur = new Container(
      width: 120.0,
      height: 14.0,
      color: ColorConst.gray,
    );

    final un = new Container(
      width: 120.0,
      height: 10.0,
      color: ColorConst.gray,
    );

    final uu = new Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ur,
          pts,
          un,
        ],
      ),
    );

    final cl = new Container(
      width: width - 120,
      child: uu,
    );

    final ds = new Padding(
      padding: EdgeInsets.all(4.0),
      child: new Container(
        width: 60.0,
        height: 14.0,
        color: ColorConst.gray,
      ),
    );

    final i = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        pp,
        cl,
        ds,
      ],
    );

    final pc = new Container(
      width: width,
      height: 320,
      color: ColorConst.gray,
    );

    final w = new Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
      ),
      child: new Container(
        width: 60.0,
        height: 24.0,
        color: ColorConst.gray,
      ),
    );

    final wg = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [w, w],
    );

    final p = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        i,
        pt,
        pc,
        pt,
        wg,
      ],
    );

    return new Container(
      child: new ShaderMask(
        shaderCallback: c,
        blendMode: BlendMode.srcIn,
        child: new Padding(
          padding: EdgeInsets.only(top: 12.0, bottom: 48.0),
          child: p,
        ),
      ),
    );
  }
}
