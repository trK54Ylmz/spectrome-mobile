import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';

class Gallery extends StatefulWidget {
  final currentState = new _GalleryState();

  @override
  _GalleryState createState() => currentState;
}

class _GalleryState extends State<Gallery> {
  // Gallery scroll controller
  final _sc = ScrollController();

  // Photos and videos assets
  final _items = <AssetEntity>[];

  // Thumb data of photos and videos according to ID
  final _thumbs = List<MapEntry<String, Uint8List>>();

  // Selected item indexes
  final _selected = <int>[];

  // Where any item selected or not
  final active = ValueNotifier<bool>(false);

  // Temporary directory
  Directory _temp;

  // Loading indicator
  bool _loading = true;

  // Gallery page
  int _page = 0;

  // Gallery related message
  String _message;

  @override
  void initState() {
    super.initState();

    // Clear selected items
    _selected.clear();

    // Asset path callback
    final ac = (List<AssetPathEntity> paths) async {
      for (int i = 0; i < paths.length; i++) {
        final items = await paths[i].getAssetListPaged(_page, 10);

        var uniques = <AssetEntity>[];
        for (var i = 0; i < items.length; i++) {
          bool exists = false;
          for (int j = 0; j < _thumbs.length; j++) {
            // ID must be unique
            if (_thumbs[j].key == items[i].id) {
              exists = true;
              break;
            }
          }

          // ID must be unique
          if (exists) {
            continue;
          }

          // Load thumbnail data
          final entry = new MapEntry(items[i].id, await items[i].thumbData);
          _thumbs.add(entry);

          // Unique items according to ID
          uniques.add(items[i]);
        }

        // Add all items
        setState(() => _items.addAll(uniques));
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
      final width = _items[index].width;
      final height = _items[index].height;

      final size = width > height ? height : width;

      final img = new Image.memory(
        _thumbs[index].value,
        width: size.toDouble(),
        height: size.toDouble(),
        fit: width > height ? BoxFit.fitHeight : BoxFit.fitWidth,
      );

      final ec = new Container();

      // More than one item selected use counter
      final nc = new Container(
        width: 24.0,
        height: 24.0,
        child: new Center(
          child: new Text(
            (_selected.indexOf(index) + 1).toString(),
            textAlign: TextAlign.center,
            style: new TextStyle(
              fontFamily: FontConst.primary,
              color: ColorConst.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorConst.buttonColor,
        ),
      );

      // Only one item selected use tick
      final tc = new Container(
        width: 24.0,
        height: 24.0,
        child: new Center(
          child: new Icon(
            new IconData(0xf00c, fontFamily: FontConst.fa),
            color: ColorConst.white,
            size: 16.0,
          ),
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorConst.buttonColor,
        ),
      );

      // Selected item container
      final sc = new SizedBox.expand(
        child: new Container(
          width: 200.0,
          height: 200.0,
          color: ColorConst.dark.withOpacity(0.5),
          child: new Center(
            child: _selected.length > 1 ? nc : tc,
          ),
        ),
      );

      if (_items[index].type == AssetType.video) {
        // Put video icon if the item is video
        final vi = new Padding(
          padding: EdgeInsets.all(8.0),
          child: new Container(
            width: 22.0,
            height: 16.0,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: ColorConst.dark.withOpacity(0.14),
                  blurRadius: 2.0,
                ),
              ],
            ),
            child: const Icon(
              const IconData(0xf03d, fontFamily: FontConst.fa),
              size: 16.0,
              color: ColorConst.white,
            ),
          ),
        );

        return new Padding(
          padding: EdgeInsets.only(
            bottom: index % 2 == 0 ? 1.0 : 0.0,
            left: index > 1 ? 1.0 : 0.0,
          ),
          child: new GestureDetector(
            onTap: () => _tap(index),
            child: Stack(
              alignment: Alignment.topRight,
              children: <Widget>[
                img,
                vi,
                _selected.contains(index) ? sc : ec,
              ],
            ),
          ),
        );
      } else {
        return new Padding(
          padding: EdgeInsets.only(
            bottom: index % 2 == 0 ? 1.0 : 0.0,
            left: index > 1 ? 1.0 : 0.0,
          ),
          child: new GestureDetector(
            onTap: () => _tap(index),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                img,
                _selected.contains(index) ? sc : ec,
              ],
            ),
          ),
        );
      }
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

  /// Select image or video
  void _tap(int index) {
    // Add or remove according to existence of index
    if (_selected.contains(index)) {
      _selected.remove(index);
    } else {
      _selected.add(index);
    }

    setState(() => active.value = _selected.length > 0);
  }

  /// Get files for sharing
  Future<List<String>> getFiles() async {
    final files = <String>[];

    for (int i = 0; i < _selected.length; i++) {
      for (int j = 0; j < _items.length; j++) {
        // Get index of selected item
        final index = _selected[i];

        // Get asset data according to selected id
        if (_thumbs[index].key != _items[j].id) {
          continue;
        }

        final name = _items[j].type == AssetType.video ? 'video.$i.mp4' : 'photo.$i.jpg';
        final f = new File('${_temp.path}/$name');

        final of = await _items[j].file;

        final rs = of.openRead();
        final ws = f.openWrite(mode: FileMode.writeOnlyAppend);
        try {
          rs.map((s) => ws.write(s));
        } finally {
          // Close write strem
          ws.close();
        }

        // Write to file
        files.add(f.path);
      }
    }

    return files;
  }
}