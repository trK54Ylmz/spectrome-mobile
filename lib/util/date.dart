import 'dart:developer' as dev;

class DateTimes {
  /// Get time difference as text format
  static String diff(DateTime start, DateTime end) {
    if (start == null || end == null) {
      dev.log('Please check start or end time.');

      throw Exception('The start or end time is empty.');
    }

    final diff = start.difference(end);

    if (diff.inDays >= 7) {
      return (diff.inDays / 7).floor().toString() + ' weeks ago';
    } else if (diff.inDays >= 1) {
      return diff.inDays.toString() + ' days ago';
    } else if (diff.inHours >= 1) {
      return diff.inHours.toString() + ' hours ago';
    } else if (diff.inMinutes >= 1) {
      return diff.inMinutes.toString() + ' mins ago';
    }

    return diff.inSeconds.toString() + ' secs ago';
  }
}
