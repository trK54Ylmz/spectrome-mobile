import 'package:spectrome/util/http.dart';

abstract class Service {
  /// Http client initializer
  Service() {
    Http.init();
  }
}
