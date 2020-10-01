import 'dart:convert';

class Intention {
  final String code;

  final DateTime createTime;

  /// Create circle intention object
  const Intention({
    this.code,
    this.createTime,
  });

  /// Encode profile instance
  String toJson() {
    final items = {
      'c': code,
      'd': createTime.toIso8601String(),
    };

    return jsonEncode(items);
  }

  /// Decode string to profile instance
  static Intention fromJson(String json) {
    final items = jsonDecode(json) as Map<String, dynamic>;

    return Intention(
      code: items.containsKey('c') ? items['c'] : null,
      createTime: items.containsKey('d') ? DateTime.parse(items['d']) : null,
    );
  }
}
