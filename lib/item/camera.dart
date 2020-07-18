import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';

class Camera extends StatefulWidget {
  final currentState = new _CameraState();

  @override
  _CameraState createState() => currentState;
}

class _CameraState extends State<Camera> {
  // Camera aspect ratio
  final _ratio = 1;

  // Loading indicator
  bool _loading = true;

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
      final r = ResolutionPreset.veryHigh;

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

    // Camera height before clipping
    final height = width * (1 / _cc.value.aspectRatio);

    // Expected height
    final eh = width / _ratio;

    return new ClipRRect(
      child: Align(
        alignment: Alignment.center,
        heightFactor: eh / height,
        widthFactor: 1,
        child: new Container(
          width: width,
          height: height,
          child: CameraPreview(_cc),
        ),
      ),
    );
  }
}
