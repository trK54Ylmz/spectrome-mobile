import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';

class Camera extends StatefulWidget {
  final currentState = new _CameraState();

  @override
  _CameraState createState() => currentState;
}

class _CameraState extends State<Camera> {
  // Where any item selected or not
  final active = ValueNotifier<bool>(false);

  // Loading indicator
  bool _loading = true;

  // Take picture or not (record video)
  bool _isVideo = true;

  // Recording time
  int _time = 0;

  // List of cameras
  List<CameraDescription> _cs;

  // Camera controller for active camera
  CameraController _cc;

  // Camera related message
  String _message;

  @override
  void initState() {
    super.initState();

    // Dispose camera controller if camera controller is initalized
    if (_cc != null) {
      _cc.dispose();
    }

    // Camera initialize callback
    final _ic = (_) {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    // Camera description load callback
    final c = (List<CameraDescription> d) {
      _cs = d;
    };

    // Camera controller callback
    final cc = (_) {
      final d = _cs.where((e) => e.lensDirection == CameraLensDirection.back).first;

      // 1280 x 720 pixel HD camera
      final r = ResolutionPreset.high;

      _cc = new CameraController(d, r);
      _cc.initialize().then(_ic);
    };

    // Error callback
    final e = (_) {
      setState(() => _message = 'Something wrong with the camera.');
    };

    availableCameras().then(c).then(cc).catchError(e);
  }

  @override
  void dispose() {
    // Dispose camera controller
    if (_cc != null) {
      _cc.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext build) {
    // Show loading
    if (_loading) return AppConst.loading();

    // Get error widget
    if (_message != null) return AppConst.error(_message);

    // Get gallery widget
    return _getCamera();
  }

  /// Get camera widget
  Widget _getCamera() {
    final width = MediaQuery.of(context).size.width;

    // Expected height
    final ratio = width / 720.0;

    final ec = new Container();

    final pt = new Padding(
      padding: EdgeInsets.only(top: 12.0),
    );

    final ptl = new Padding(
      padding: EdgeInsets.only(top: 16.0),
    );

    final tc = new Container(
      child: new Text(
        _time.toString().padLeft(2, '0'),
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          color: active.value ? ColorConst.white : ColorConst.white.withOpacity(0.33),
          shadows: <Shadow>[
            Shadow(
              offset: Offset(0.0, 0.0),
              blurRadius: 3.0,
              color: ColorConst.dark.withOpacity(active.value ? 0.67 : 0.33),
            ),
          ],
        ),
      ),
    );

    final c = new Container(
      width: width,
      height: ratio * 1280.0,
      child: new ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: new Container(
              width: width,
              height: ratio * 1280.0,
              child: CameraPreview(_cc),
            ),
          ),
        ),
      ),
    );

    // Record button
    final b = new GestureDetector(
      child: new Container(
        width: 64.0,
        height: 64.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.transparent,
          border: Border.all(
            color: ColorConst.white,
            width: 2.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              offset: Offset(0.0, 0.0),
              blurRadius: 6.0,
              color: ColorConst.dark.withOpacity(0.33),
            ),
            BoxShadow(
              color: ColorConst.transparent,
              spreadRadius: -12.0,
              blurRadius: 12.0,
            )
          ],
        ),
        child: new Center(
          child: new Icon(
            IconData(
              active.value ? 0xf0c8 : 0xf111,
              fontFamily: FontConst.fa,
            ),
            color: active.value ? ColorConst.darkRed : ColorConst.white,
            size: 32.0,
          ),
        ),
      ),
    );

    // Photo selector button
    final p = new GestureDetector(
      onTap: () {
        setState(() => _isVideo = false);
      },
      child: new Padding(
        padding: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
        child: new Text(
          'Photo'.toUpperCase(),
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            color: _isVideo ? ColorConst.white : ColorConst.yellow,
            fontSize: 14.0,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0.0, 0.0),
                blurRadius: 3.0,
                color: ColorConst.dark.withOpacity(0.67),
              ),
            ],
          ),
        ),
      ),
    );

    // Video selector button
    final v = new GestureDetector(
      onTap: () {
        setState(() => _isVideo = true);
      },
      child: new Padding(
        padding: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
        child: new Text(
          'Video'.toUpperCase(),
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            color: _isVideo ? ColorConst.yellow : ColorConst.white,
            fontSize: 14.0,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0.0, 0.0),
                blurRadius: 3.0,
                color: ColorConst.dark.withOpacity(0.67),
              ),
            ],
          ),
        ),
      ),
    );

    final s = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        p,
        v,
      ],
    );

    final r = new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          pt,
          _isVideo ? tc : ec,
          pt,
          b,
          pt,
          s,
          ptl,
        ],
      ),
    );

    final items = <Widget>[
      c,
      r,
    ];

    return new Stack(
      alignment: Alignment.center,
      overflow: Overflow.clip,
      fit: StackFit.loose,
      children: items,
    );
  }
}
