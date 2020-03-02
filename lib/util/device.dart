import 'dart:async';
import 'dart:io';
import 'package:device_info/device_info.dart';

class Device {
  static final DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();

  /// Check the type of device
  static Future<bool> isDevice() async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice;
    }

    return false;
  }

  /// Get device name
  static Future<String> getName() async {
    if (Platform.isAndroid) {
      final i = await deviceInfo.androidInfo;

      return "${i.device} ${i.model}";
    } else if (Platform.isIOS) {
      final i = await deviceInfo.iosInfo;

      return "${i.utsname.machine} ${i.name}";
    }

    return null;
  }
}
