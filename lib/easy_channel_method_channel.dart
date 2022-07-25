import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'easy_channel_platform_interface.dart';

/// An implementation of [EasyChannelPlatform] that uses method channels.
class MethodChannelEasyChannel extends EasyChannelPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('easy_channel');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
