import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences prefs;

  /// load shared preferences
  static Future<SharedPreferences> load() {
    // Get shared preferences, if present in static block
    if (prefs != null) {
      return new Future.value(prefs);
    }

    return SharedPreferences.getInstance().then((p) => prefs = p);
  }
}