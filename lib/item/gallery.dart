import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:spectrome/util/const.dart';

class Gallery extends StatefulWidget {
  final currentState = new _GalleryState();

  @override
  _GalleryState createState() => currentState;
}

class _GalleryState extends State<Gallery> {
  // Gallery scroll controller
  final _sc = ScrollController();

  // Photos or videos
  final _items = <AssetEntity>[];

// Loading indicator
  bool _loading = true;

  // Gallery page
  int _page = 0;

  // Gallery related message
  String _message;

  @override
  void initState() {
    super.initState();

    // Asset path callback
    final ac = (List<AssetPathEntity> paths) async {
      for (int i = 0; i < paths.length; i++) {
        final items = await paths[i].getAssetListPaged(_page, 10);

        // Add all items
        setState(() => _items.addAll(items));
      }
    };

    // Gallery request callback
    final c = (bool status) async {
      if (!status) {
        _message = 'Gallery access required. Please allow gallery from Settings.';
        return;
      }

      await PhotoManager.getAssetPathList().then(ac);
    };

    final cc = () {
      if (!mounted) {
        return;
      }

      setState(() => _loading = false);
    };

    final e = (_) {
      setState(() => _message = 'Something wrong with the gallery.');
    };

    PhotoManager.requestPermission().then(c).catchError(e).whenComplete(cc);
  }

  @override
  void dispose() {
    // Clear items
    _items.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading
    if (_loading) return AppConst.loading();

    // Get error widget
    if (_message != null) return AppConst.error(_message);

    // Get gallery widget
    return _getGallery();
  }

  /// Get gallery widget
  Widget _getGallery() {
    // Item builder
    final b = (int index) {
      return FutureBuilder(
        future: _items[index].thumbData,
        builder: (context, AsyncSnapshot<Uint8List> s) {
          if (s.connectionState == ConnectionState.done) {
            if (s.hasData) {
              return new Image.memory(
                s.data,
                width: 60.0,
                height: 60.0,
              );
            } else {
              return new Image.asset(
                'assets/images/loading.gif',
                width: 60.0,
                height: 60.0,
              );
            }
          } else {
            return new Image.asset(
              'assets/images/loading.gif',
              width: 60.0,
              height: 60.0,
            );
          }
        },
      );
    };

    return new SizedBox.expand(
      child: GridView.count(
        crossAxisCount: 2,
        controller: _sc,
        scrollDirection: Axis.horizontal,
        children: List.generate(_items.length, b),
      ),
    );
  }
}
