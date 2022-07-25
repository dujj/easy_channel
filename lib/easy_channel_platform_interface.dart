import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'easy_channel_method_channel.dart';

abstract class EasyChannelPlatform extends PlatformInterface {
  /// Constructs a EasyChannelPlatform.
  EasyChannelPlatform() : super(token: _token);

  static final Object _token = Object();

  static EasyChannelPlatform _instance = MethodChannelEasyChannel();

  /// The default instance of [EasyChannelPlatform] to use.
  ///
  /// Defaults to [MethodChannelEasyChannel].
  static EasyChannelPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EasyChannelPlatform] when
  /// they register themselves.
  static set instance(EasyChannelPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>?> get(String path, [Map<String, dynamic>? data]) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void post(String path, [Map<String, dynamic>? data]) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void addObserver(String path,
      Future<Map<String, dynamic>?> Function(Map<String, dynamic>?) callback) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void removeObserver(String path) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
