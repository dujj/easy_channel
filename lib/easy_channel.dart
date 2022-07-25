
import 'easy_channel_platform_interface.dart';

class EasyChannel {
  Future<String?> getPlatformVersion() {
    return EasyChannelPlatform.instance.getPlatformVersion();
  }
}
