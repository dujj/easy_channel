import 'package:flutter_test/flutter_test.dart';
import 'package:easy_channel/easy_channel.dart';
import 'package:easy_channel/easy_channel_platform_interface.dart';
import 'package:easy_channel/easy_channel_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEasyChannelPlatform 
    with MockPlatformInterfaceMixin
    implements EasyChannelPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final EasyChannelPlatform initialPlatform = EasyChannelPlatform.instance;

  test('$MethodChannelEasyChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEasyChannel>());
  });

  test('getPlatformVersion', () async {
    EasyChannel easyChannelPlugin = EasyChannel();
    MockEasyChannelPlatform fakePlatform = MockEasyChannelPlatform();
    EasyChannelPlatform.instance = fakePlatform;
  
    expect(await easyChannelPlugin.getPlatformVersion(), '42');
  });
}
