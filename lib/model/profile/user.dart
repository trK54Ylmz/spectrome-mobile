import 'dart:convert';

class UserProfile {
  final String username;

  final String name;

  final String photoUrl;

  final int posts;

  final int followers;

  final int followings;

  final bool followable;

  final bool followed;

  /// Create my profile object
  const UserProfile({
    this.username,
    this.name,
    this.photoUrl,
    this.posts,
    this.followers,
    this.followings,
    this.followable,
    this.followed,
  });

  /// Encode profile instance
  String toJson() {
    final items = {
      'u': username,
      'n': name,
      'i': photoUrl,
      'p': posts,
      'f': followings,
      't': followers,
      'a': followable,
      'd': followed,
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
      followings: items.containsKey('f') ? items['f'] : null,
      followers: items.containsKey('t') ? items['t'] : null,
      followable: items.containsKey('a') ? items['a'] : null,
      followed: items.containsKey('d') ? items['d'] : null,
    );
  }
}
