import 'dart:convert';

class SimpleProfile {
  final String username;

  final String name;

  final String photoUrl;

  /// Create simple profile object
  const SimpleProfile({
    this.username,
    this.name,
    this.photoUrl,
  });

  /// Encode profile instance
  String toJson() {
    final items = {
      'u': username,
      'n': name,
      'i': photoUrl,
    };

    return jsonEncode(items);
  }

  /// Decode string to profile instance
  static SimpleProfile fromJson(String json) {
    final items = jsonDecode(json) as Map<String, dynamic>;

    return SimpleProfile(
      username: items.containsKey('u') ? items['u'] : null,
      name: items.containsKey('n') ? items['n'] : null,
      photoUrl: items.containsKey('i') ? items['i'] : null,
    );
  }
}
