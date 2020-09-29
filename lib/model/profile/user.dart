import 'dart:convert';

class UserProfile {
  final String username;

  final String name;

  final String photoUrl;

  final int posts;

  final int circles;

  final bool request;

  final bool circle;

  /// Create my profile object
  const UserProfile({
    this.username,
    this.name,
    this.photoUrl,
    this.posts,
    this.circles,
    this.request,
    this.circle,
  });

  /// Encode profile instance
  String toJson() {
    final items = {
      'u': username,
      'n': name,
      'i': photoUrl,
      'p': posts,
      'f': circles,
      'a': request,
      'd': circle,
    };

    return jsonEncode(items);
  }

  /// Decode string to profile instance
  static UserProfile fromJson(String json) {
    final items = jsonDecode(json) as Map<String, dynamic>;

    return UserProfile(
      username: items.containsKey('u') ? items['u'] : null,
      name: items.containsKey('n') ? items['n'] : null,
      photoUrl: items.containsKey('i') ? items['i'] : null,
      posts: items.containsKey('p') ? items['p'] : null,
      circles: items.containsKey('f') ? items['f'] : null,
      request: items.containsKey('a') ? items['a'] : null,
      circle: items.containsKey('d') ? items['d'] : null,
    );
  }
}
