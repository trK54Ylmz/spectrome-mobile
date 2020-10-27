import 'dart:developer' as dev;

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:spectrome/util/const.dart';

enum VideoType { FILE, NETWORK }

class Video extends StatefulWidget {
  final String path;

  final VideoType type;

  final double width;

  final double height;

  final Map<String, String> headers;

  const Video({
    Key key,
    this.path,
    this.type,
    this.headers,
    this.width = 0,
    this.height = 0,
  })  : assert(path != null),
        super(key: key);

  @override
  _VideoState createState() => new _VideoState();
}

class _VideoState extends State<Video> {
  // Chewie player controller
  BetterPlayerController _cc;

  // Default volume level
  double _vol = 0;

  // Loading indicator
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    BetterPlayerDataSourceType type;
    switch (widget.type) {
      case VideoType.NETWORK:
        type = BetterPlayerDataSourceType.NETWORK;
        break;
      case VideoType.FILE:
        type = BetterPlayerDataSourceType.FILE;
        break;
    }

    final r = widget.width > 0 && widget.height > 0 ? widget.width / widget.height : null;

    // Create data source
    final ds = new BetterPlayerDataSource(type, widget.path, headers: widget.headers);

    final cc = new BetterPlayerControlsConfiguration(
      showControls: false,
    );

    // Create better player configuration
    final cfg = new BetterPlayerConfiguration(
      aspectRatio: r,
      autoPlay: true,
      looping: true,
      controlsConfiguration: cc,
      showControlsOnInitialize: false,
      fullScreenByDefault: false,
    );

    // Create video controller
    _cc = new BetterPlayerController(cfg, betterPlayerDataSource: ds);

    _vol = _cc.videoPlayerController.value.volume;

    // Set event listener
    _cc.addEventsListener(_listener);

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: AppConst.loader(
        argument: _loading,
        callback: _getPage,
      ),
    );
  }

  /// Get video widget
  Widget _getPage() {
    return new GestureDetector(
      onTap: () {
        if (_cc.videoPlayerController.value.volume > 0) {
          _cc.videoPlayerController.setVolume(0);
        } else {
          _cc.videoPlayerController.setVolume(_vol);
        }
      },
      child: new BetterPlayer(controller: _cc),
    );
  }

  /// Better player event listener
  void _listener(event) {
    final type = event.betterPlayerEventType as BetterPlayerEventType;

    if (type == BetterPlayerEventType.SET_VOLUME) {
      dev.log('Volume has set to ${_cc.videoPlayerController.value.volume}');
    }
  }
}
