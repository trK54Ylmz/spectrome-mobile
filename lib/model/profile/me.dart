import 'dart:convert';

class MyProfile {
  final String username;

  final String name;

  final String photoUrl;

  final int followers;

  final int followings;

  /// Create my profile object
  const MyProfile({
    this.username,
    this.name,
    this.photoUrl,
    this.followers,
    this.followings,
  });

  /// Encode profile instance
  String toJson() {
    final items = {
      'u': username,
      'n': name,
      'p': photoUrl,
      'f': followings,
      't': followers,
    };

    return jsonEncode(items);
  }

  /// Decode string to profile instance
  static MyProfile fromJson(String json) {
    final items = jsonDecode(json) as Map<String, dynamic>;

    return MyProfile(
      username: items.containsKey('u') ? items['u'] : null,
      name: items.containsKey('n') ? items['n'] : null,
      photoUrl: items.containsKey('p') ? items['p'] : null,
      followings: items.containsKey('f') ? items['f'] : null,
      followers: items.containsKey('t') ? items['t'] : null,
    );
  }
}
