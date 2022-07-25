import 'package:flutter_test/flutter_test.dart';
import 'package:easy_channel/easy_channel.dart';
import 'package:easy_channel/easy_channel_platform_interface.dart';
import 'package:easy_channel/easy_channel_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  final EasyChannelPlatform initialPlatform = EasyChannelPlatform.instance;

  test('$MethodChannelEasyChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEasyChannel>());
  });

  test('getPlatformVersion', () async {
    EasyChannel easyChannelPlugin = EasyChannel();
  });
}
