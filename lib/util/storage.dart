import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences _prefs;

  /// Load shared preferences
  static Future<SharedPreferences> load() {
    // Get shared preferences, if present in static block
    if (_prefs != null) {
      return new Future.value(_prefs);
    }

    return SharedPreferences.getInstance().then((p) => _prefs = p);
  }
}