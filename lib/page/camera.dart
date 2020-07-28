import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spectrome/item/loading.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';

class CameraPage extends StatefulWidget {
  static final tag = 'camera';

  CameraPage({@required Key key}) : super(key: key);

  @override
  CameraState createState() => new CameraState();

  /// Run callback when widget built
  void ready(FrameCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback(callback);
  }
}

class CameraState extends State<CameraPage> {
  // Where any item selected or not
  final active = ValueNotifier<bool>(false);

  // Actions are locked or not
  final done = ValueNotifier<bool>(false);

  // Loading indicator
  bool _loading = true;

  // Take picture or not (record video)
  bool _isVideo = true;

  // Video recording status
  bool _recording = false;

  // Recording time
  int _time = 0;

  // Temporary directory
  Directory _temp;

  // List of cameras
  List<CameraDescription> _cs;

  // Camera controller for active camera
  CameraController _cc;

  // Camera related message
  String _message;

  // Camera related error messages
  ErrorMessage _error;

  @override
  void initState() {
    super.initState();

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

    // Get available cameras and create camera controller
    availableCameras().then(c).then(cc).catchError(e);

    // Directory callback
    final dc = (Directory d) {
      // Remove temporary directory if exists
      if (d.existsSync()) {
        // Delete and create if there are files in the directory
        if (d.listSync().length > 0) {
          // Remove temporary directory
          d.deleteSync(recursive: true);

          // Create temporary directory
          d.createSync();
        }
      }

      setState(() => _temp = d);
    };

    // Get temporary directory
    getTemporaryDirectory().then(dc);
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Show loading
    if (_loading) return const Loading();

    // Get error widget
    if (_message != null) {
      return SizedBox.expand(
        child: new Center(
          child: new Text(
            _message,
            style: new TextStyle(
              fontFamily: FontConst.primary,
              fontSize: 14.0,
              letterSpacing: 0.33,
            ),
          ),
        ),
      );
    }

    // Get camera widget
    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: new SingleChildScrollView(
          child: new Container(
            width: width,
            height: height,
            child: AppConst.loader(
              page: CameraPage.tag,
              argument: _loading,
              error: _error,
              callback: _getCamera,
            ),
          ),
        ),
      ),
    );
  }

  /// Get camera widget
  Widget _getCamera() {
    final width = MediaQuery.of(context).size.width;

    // Expected height
    final ratio = width / 720.0;

    // Camera clipped container
    final c = new Container(
      width: width,
      height: width,
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

    // Get video player or image
    final s = _getControls();

    // Camera and camera controller widgets stack
    final items = <Widget>[
      c,
      s,
    ];

    return new Container(
      color: ColorConst.white,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: items,
      ),
    );
  }

  /// Get camera controllers
  Widget _getControls() {
    final pt = new Padding(
      padding: EdgeInsets.only(top: 12.0),
    );

    final ptl = new Padding(
      padding: EdgeInsets.only(top: 32.0),
    );

    final ec = new Container(
      height: 18.0,
    );

    // Video time progress counter
    final tc = new Container(
      height: 18.0,
      child: new Text(
        _time.toString().padLeft(2, '0'),
        style: new TextStyle(
          fontFamily: FontConst.primary,
          fontSize: 14.0,
          color: _recording ? ColorConst.darkGray : ColorConst.darkGray.withOpacity(0.33),
        ),
      ),
    );

    // Record button
    final b = new GestureDetector(
      onTap: () async {
        // Temporary directory must be created
        if (_temp == null) {
          return;
        }

        // Disable recording videa or taking picture
        if (done.value) {
          return;
        }

        // Disable if selection has been made
        if (active.value) {
          return;
        }

        Future f;
        if (_isVideo) {
          // Record video or stop recording
          f = _recording ? _stopRecord() : _recordVideo();
        } else {
          // Take picture
          f = _takePicture();
        }

        // Wait for complete
        await f;
      },
      child: new Container(
        width: 48.0,
        height: 48.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.transparent,
          border: Border.all(
            color: ColorConst.darkGray,
            width: 2.0,
          ),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        child: new Center(
          child: new Padding(
            padding: EdgeInsets.only(bottom: 1.5),
            child: new Icon(
              IconData(
                _recording ? 0xf0c8 : 0xf111,
                fontFamily: FontConst.fa,
              ),
              color: _recording ? ColorConst.darkRed : ColorConst.darkGray,
              size: 32.0,
            ),
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
          vertical: 8.0,
          horizontal: 12.0,
        ),
        child: new Text(
          'Photo'.toUpperCase(),
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            color: _isVideo ? ColorConst.darkGray.withOpacity(0.33) : ColorConst.darkGray,
            fontSize: 14.0,
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
          vertical: 8.0,
          horizontal: 12.0,
        ),
        child: new Text(
          'Video'.toUpperCase(),
          textAlign: TextAlign.center,
          style: new TextStyle(
            fontFamily: FontConst.primary,
            color: _isVideo ? ColorConst.darkGray : ColorConst.darkGray.withOpacity(0.33),
            fontSize: 14.0,
          ),
        ),
      ),
    );

    // Photo and video selection buttons
    final s = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        p,
        v,
      ],
    );

    // Camera widget group
    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ptl,
          _isVideo ? tc : ec,
          pt,
          b,
          pt,
          s,
          pt,
        ],
      ),
    );
  }

  /// Start to record video
  Future<void> _recordVideo() async {
    if (_cc.value.isRecordingVideo) {
      return;
    }

    // Reset timer
    _time = 0;

    final path = '${_temp.path}/video.mp4';

    final file = new File(path);

    // Make status active
    setState(() => _recording = true);

    // Delete current photo
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Timer callback
    final c = (_) {
      Timer.periodic(new Duration(seconds: 1), (timer) {
        // Video cannot be longer than 60 seconds
        if (_time == 59) {
          _stopRecord();

          timer.cancel();
          return;
        }

        // Stop timer when recording stop
        if (!_cc.value.isRecordingVideo) {
          timer.cancel();
          return;
        }

        // Increase time counter
        setState(() => _time += timer.tick);
      });
    };

    // Start video recording
    return _cc.startVideoRecording(path).then(c);
  }

  /// Stop active recording
  Future<void> _stopRecord() async {
    if (!_cc.value.isRecordingVideo) {
      return;
    }

    // Recording callback
    final c = (_) {
      _recording = false;

      // Lock recording
      done.value = true;

      // Reset timer
      _time = 0;
    };

    // Stop recording
    return _cc.stopVideoRecording().then(c);
  }

  /// Take picture and save
  Future<void> _takePicture() async {
    if (_cc.value.isTakingPicture) {
      return;
    }

    final path = '${_temp.path}/photo.jpg';

    final file = new File(path);

    // Make status active
    setState(() => active.value = true);

    // Delete current photo
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Take picture callback
    final c = (_) {
      done.value = true;
    };

    // Take picture and save
    return _cc.takePicture(path).then(c);
  }

  /// Get files for sharing
  Future<List<File>> getFiles() async {
    if (_cc.value.isRecordingVideo) {
      await _stopRecord();
    }

    final path = _isVideo ? '${_temp.path}/video.mp4' : '${_temp.path}/photo.jpg';

    return <File>[new File(path)];
  }
}
