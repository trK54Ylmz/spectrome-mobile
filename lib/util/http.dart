import 'dart:io';
import 'package:spectrome/util/device.dart';

class Http {
  static final _client = new HttpClient();

  static String domain;

  /// Initialize domain name according to device type
  ///
  /// Local environment ignores ssl verification
  static Future<Null> init() {
    if (domain != null) {
      new Future.value(null);
    }

    final c = (bool isDevice) {
      domain = isDevice ? 'api.spectrome.app' : 'localhost';

      /// Bypass ssl verification at test
      if (!isDevice) {
        _client.badCertificateCallback = (c, h, p) => true;
      }

      return null;
    };

    return Device.isDevice().then(c);
  }
}
