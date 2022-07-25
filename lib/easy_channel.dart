import 'easy_channel_platform_interface.dart';

class EasyChannel {
  static Future<Map<String, dynamic>?> get(String path,
      [Map<String, dynamic>? data]) {
    return EasyChannelPlatform.instance.get(path, data);
  }

  static void post(String path, [Map<String, dynamic>? data]) {
    EasyChannelPlatform.instance.post(path, data);
  }

  static void addObserver(String path,
      Future<Map<String, dynamic>?> Function(Map<String, dynamic>?) callback) {
    EasyChannelPlatform.instance.addObserver(path, callback);
  }

  static void removeObserver(String path) {
    EasyChannelPlatform.instance.removeObserver(path);
  }
}
