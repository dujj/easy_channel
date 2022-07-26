import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_channel/easy_channel_method_channel.dart';

void main() {
  MethodChannelEasyChannel platform = MethodChannelEasyChannel();
  const MethodChannel channel = MethodChannel('easy_channel');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
