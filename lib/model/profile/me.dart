import 'dart:convert';

class MyProfile {
  final String username;

  final String name;

  final String photoUrl;

  final int posts;

  final int circles;

  /// Create my profile object
  const MyProfile({
    this.username,
    this.name,
    this.photoUrl,
    this.posts,
    this.circles,
  });

  /// Encode profile instance
  String toJson() {
    final items = {
      'u': username,
      'n': name,
      'i': photoUrl,
      'p': posts,
      'f': circles,
    };

    return jsonEncode(items);
  }

  /// Decode string to profile instance
  static MyProfile fromJson(String json) {
    final items = jsonDecode(json) as Map<String, dynamic>;

    return MyProfile(
      username: items.containsKey('u') ? items['u'] : null,
      name: items.containsKey('n') ? items['n'] : null,
      photoUrl: items.containsKey('i') ? items['i'] : null,
      posts: items.containsKey('p') ? items['p'] : null,
      circles: items.containsKey('f') ? items['f'] : null,
    );
  }
}
