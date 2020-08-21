import 'package:flutter/material.dart';
import 'package:spectrome/theme/color.dart';
import 'package:spectrome/util/const.dart';
import 'package:spectrome/util/error.dart';

class EditPage extends StatefulWidget {
  static final tag = 'edit';

  EditPage() : super();

  @override
  _EditState createState() => new _EditState();
}

class _EditState extends State<EditPage> {
  // Scaffold key
  final _sk = new GlobalKey<ScaffoldState>();
  
  // Account session key
  String _session;

  // Error message
  ErrorMessage _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _sk,
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: AppConst.loader(
          page: EditPage.tag,
          argument: _session == null,
          error: _error,
          callback: _getPage,
        ),
      ),
    );
  }

  /// Get page widget
  Widget _getPage() {
    return new Container();
  }
}
