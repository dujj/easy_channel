import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'easy_channel_platform_interface.dart';

const String _kChannelMethodRequest = "request";
const String _kChannelMethodObserver = "observer";
const String _kChannelMethodResponse = "response";

class _ChannelResponse {
  String path;
  String idenfy;
  Completer completer;

  _ChannelResponse(this.path, this.idenfy, this.completer);
}

class ChannelObserver {
  String path;
  Future<Map<String, dynamic>?> Function(Map<String, dynamic>?) callback;

  ChannelObserver(this.path, this.callback);
}

/// An implementation of [EasyChannelPlatform] that uses method channels.
class MethodChannelEasyChannel extends EasyChannelPlatform {
  int _requestIndex = 0;

  final _responses = <String, _ChannelResponse>{};
  final _observers = <String, ChannelObserver>{};

  /// The method channel used to interact with the native platform.
  final _writerChannel = const BasicMessageChannel(
    "com.flutter.easy.channel.writer",
    JSONMessageCodec(),
  );

  final _readerChannel = const BasicMessageChannel(
    "com.flutter.easy.channel.reader",
    JSONMessageCodec(),
  );

  MethodChannelEasyChannel() {
    _readerChannel.setMessageHandler((message) async {
      try {
        _didRead(message);
      } catch (e) {
        debugPrint('[flutter channel] didRead error: $e');
      }
      return null;
    });
  }

  void _didRead(Object? message) {
    if (message is Map<String, dynamic>) {
      debugPrint('[flutter channel] didRead:  $message');
      String path = message['path'] as String? ?? 'unknow';
      String method = message['method'] as String? ?? 'unknow';
      String idenfy = message['id'] as String? ?? 'unknow';
      String? data = message['data'] as String?;
      Map<String, dynamic>? result;
      if (data != null && data.isNotEmpty) {
        result = json.decode(data) as Map<String, dynamic>?;
      }
      switch (method) {
        case _kChannelMethodRequest:
          var observer = _observers[path];
          if (observer != null) {
            var response = observer.callback(result);
            response.then((value) => _send(path, _kChannelMethodResponse,
                idenfy: idenfy, data: value));
          }
          break;
        case _kChannelMethodObserver:
          var observer = _observers[path];
          if (observer != null) {
            observer.callback(result);
          }
          break;
        case _kChannelMethodResponse:
          var key = path + _kChannelMethodRequest + idenfy;
          var response = _responses.remove(key);
          if (response != null) {
            response.completer.complete(result);
          }
          break;
        default:
          break;
      }
    }
    return;
  }

  void _send(String path, String method,
      {String? idenfy, Map<String, dynamic>? data}) {
    var request = <String, dynamic>{};
    request['path'] = path;
    request['method'] = method;
    if (data != null) {
      request['data'] = json.encode(data);
    }
    if (idenfy != null) {
      request['id'] = idenfy;
    }
    debugPrint('[flutter channel] send: $path  data: $request');
    _writerChannel.send(request);
  }

  @override
  Future<Map<String, dynamic>?> get(String path, [Map<String, dynamic>? data]) {
    Completer<Map<String, dynamic>?> completer = Completer();
    var idenfy = '${++_requestIndex}';
    var key = path + _kChannelMethodRequest + idenfy;
    var response = _ChannelResponse(path, idenfy, completer);
    _responses[key] = response;
    _send(path, _kChannelMethodRequest, idenfy: idenfy, data: data);
    return completer.future;
  }

  @override
  void post(String path, [Map<String, dynamic>? data]) {
    _send(path, _kChannelMethodObserver, data: data);
  }

  /// channel observer
  ///
  ///[path] path
  ///[callback] callback
  /// return [ChannelObserver]
  @override
  void addObserver(String path,
      Future<Map<String, dynamic>?> Function(Map<String, dynamic>?) callback) {
    _observers[path] = ChannelObserver(path, callback);
  }

  @override
  void removeObserver(String path) {
    _observers.remove(path);
  }
}
