import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:spectrome/util/const.dart';
import 'package:video_player/video_player.dart';

enum VideoType { FILE, NETWORK }

class Video extends StatefulWidget {
  final String path;

  final VideoType type;

  final double width;

  final double height;

  const Video({
    Key key,
    this.path,
    this.type,
    this.width = 0,
    this.height = 0,
  })  : assert(path != null),
        super(key: key);

  @override
  _VideoState createState() => new _VideoState();
}

class _VideoState extends State<Video> {
  // Video player controller
  VideoPlayerController _vc;

  // Chewie player controller
  ChewieController _cc;

  // Default volume level
  double _vol = 0;

  // Loading indicator
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Create video controller
    if (widget.type == VideoType.NETWORK) {
      _vc = new VideoPlayerController.network(widget.path);
    } else {
      _vc = new VideoPlayerController.file(new File(widget.path));
    }

    if (widget.width == 0 && widget.height == 0) {
      final c = (_) {
        // Create chewie controller
        _cc = new ChewieController(
          videoPlayerController: _vc,
          aspectRatio: _vc.value.aspectRatio,
          autoPlay: true,
          looping: true,
          showControls: false,
          showControlsOnInitialize: false,
          allowFullScreen: false,
          allowMuting: true,
        );

        _vol = _cc.videoPlayerController.value.volume;

        setState(() => _loading = false);
      };

      _vc.initialize().then(c);
    } else {
      _loading = false;

      // Create chewie controller
      _cc = new ChewieController(
        videoPlayerController: _vc,
        aspectRatio: widget.width / widget.height,
        autoPlay: true,
        looping: true,
        showControls: false,
        showControlsOnInitialize: false,
        allowFullScreen: false,
        allowMuting: true,
      );

      _vol = _cc.videoPlayerController.value.volume;
    }
  }

  @override
  void dispose() {
    if (_vc != null) {
      _vc.dispose();
    }

    if (_cc != null) {
      _cc.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      final width = MediaQuery.of(context).size.width;

      return new Container(
        width: width,
        height: width,
        child: AppConst.loading(),
      );
    }

    return new GestureDetector(
      onTap: () {
        if (_cc.videoPlayerController.value.volume > 0) {
          _cc.videoPlayerController.setVolume(0);
        } else {
          _cc.videoPlayerController.setVolume(_vol);
        }
      },
      child: new Chewie(controller: _cc),
    );
  }
}
