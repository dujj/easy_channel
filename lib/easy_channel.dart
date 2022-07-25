import 'easy_channel_platform_interface.dart';

class EasyChannel {
  Future<Map<String, dynamic>?> get(String path, [Map<String, dynamic>? data]) {
    return EasyChannelPlatform.instance.get(path, data);
  }

  void post(String path, [Map<String, dynamic>? data]) {
    EasyChannelPlatform.instance.post(path, data);
  }

  void addObserver(String path,
      Future<Map<String, dynamic>?> Function(Map<String, dynamic>?) callback) {
    EasyChannelPlatform.instance.addObserver(path, callback);
  }

  void removeObserver(String path) {
    EasyChannelPlatform.instance.removeObserver(path);
  }
}
