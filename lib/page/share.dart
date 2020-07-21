import 'package:flutter/material.dart';
import 'package:spectrome/theme/color.dart';

class SharePage extends StatefulWidget {
  static final tag = 'share';

  SharePage() : super();

  @override
  _ShareState createState() => new _ShareState();
}

class _ShareState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    final List<String> files = ModalRoute.of(context).settings.arguments;

    print(files);

    return Scaffold(
      backgroundColor: ColorConst.white,
      body: new SafeArea(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
          ],
        ),
      ),
    );
  }
}
