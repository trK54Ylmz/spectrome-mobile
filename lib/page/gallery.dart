import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/theme/font.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';

class GalleryPage extends StatefulWidget {
  static final tag = 'gallery';

  GalleryPage({@required Key key}) : super(key: key);

  @override
  GalleryState createState() => new GalleryState();
}

class GalleryState extends State<GalleryPage> {
    // Where any item selected or not
  final active = ValueNotifier<bool>(false);

  // Actions are locked or not
  final done = ValueNotifier<bool>(false);

  // Gallery scroll controller
  final _sc = ScrollController();

  // Photos and videos assets
  final _items = <AssetEntity>[];

  // Thumb data of photos and videos according to ID
  final _thumbs = List<MapEntry<String, Uint8List>>();

  // Selected item indexes
  final _selected = <int>[];

  // Loading indicator
  bool _loading = true;

  // Gallery page
  int _page = 0;

  // Gallery related message
  String _message;

  // Camera related error messages
  ErrorMessage _error;

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

          if (items[i].type == AssetType.video) {
            // Video duration cannot be higher than 60 seconds
            if (items[i].duration > 60) {
              continue;
            }
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
  }

  @override
  void dispose() {
    // Clear items
    _items.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Show loading
    if (_loading) return AppConst.loading();

    // Get error widget
    if (_message != null) return AppConst.error(_message);

    // Get gallery widget
    return new Scaffold(
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: new SingleChildScrollView(
          child: new Container(
            width: width,
            height: height,
            child: AppConst.loader(context, _loading, _error, _getGallery),
          ),
        ),
      ),
    );
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
          color: ColorConst.button,
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
          color: ColorConst.button,
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
            bottom: index < _thumbs.length - 3 ? 1.0 : 0.0,
            left: index % 3 > 0 ? 1.0 : 0.0,
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
            bottom: index < _thumbs.length - 3 ? 1.0 : 0.0,
            left: index % 3 > 0 ? 1.0 : 0.0,
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
        crossAxisCount: 3,
        controller: _sc,
        scrollDirection: Axis.vertical,
        children: List.generate(_items.length, b),
      ),
    );
  }

  /// Select image or video
  void _tap(int index) {
    // All selections has been made
    if (done.value) {
      return;
    }

    // Add or remove according to existence of index
    if (_selected.contains(index)) {
      _selected.remove(index);
    } else {
      _selected.add(index);
    }

    setState(() => active.value = _selected.length > 0);
  }

  /// Get files for sharing
  Future<List<File>> getFiles() async {
    final files = <File>[];

    for (int i = 0; i < _selected.length; i++) {
      for (int j = 0; j < _items.length; j++) {
        // Get index of selected item
        final index = _selected[i];

        // Get asset data according to selected id
        if (_thumbs[index].key != _items[j].id) {
          continue;
        }

        // Get origin of the file
        final of = await _items[j].file;

        // Write to file
        files.add(of);
      }
    }

    return files;
  }
}
