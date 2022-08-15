package com.example.easy_channel

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.nio.channels.AsynchronousChannel
import java.util.*
import io.flutter.Log
import org.json.JSONObject

/** EasyChannelPlugin */
class EasyChannelPlugin: FlutterPlugin {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  private lateinit var writerChannel : BasicMessageChannel<Any>

  private lateinit var readerChannel : BasicMessageChannel<Any>

  private val responsesMap = mutableMapOf<String, Response>()
  private val getObserversMap = mutableMapOf<String, GetObserver>()
  private val postObserversMap = mutableMapOf<String, PostObserver>()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    writerChannel = BasicMessageChannel(flutterPluginBinding.binaryMessenger,
      "com.flutter.easy.channel.reader",
      JSONMessageCodec.INSTANCE,
      flutterPluginBinding.binaryMessenger.makeBackgroundTaskQueue())
    readerChannel = BasicMessageChannel(flutterPluginBinding.binaryMessenger,
      "com.flutter.easy.channel.writer",
      JSONMessageCodec.INSTANCE,
      flutterPluginBinding.binaryMessenger.makeBackgroundTaskQueue())
    readerChannel.setMessageHandler { message, reply ->
      onMessage(message, reply)
    }
    Log.e("onAttachedToEngine", "-------------")
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    readerChannel.setMessageHandler(null)
  }

  private fun onMessage(message: Any?, reply: BasicMessageChannel.Reply<Any>) {
    reply.reply(null)
    if (message is JSONObject) {
      val method = message.getString("method")
      val path = message.getString("path")
      val idenfy  = message.optString("id")
      val data = message.optString("data")


        println("path: $path, method: $method data: $data")
        when (method) {
          Method.REQUEST.rawValue -> {
            val observer = getObserversMap[path]
            if (observer != null) {
              observer.callback(data, { re ->
                _send(path, Method.RESPONSE, idenfy, re)
              })
            }
          }
          Method.OBSERVER.rawValue -> {
            val observer = postObserversMap[path]
            if (observer != null) {
              observer.callback(data)
            }
          }
          Method.RESPONSE.rawValue -> {
            val key =  "$path${Method.REQUEST.rawValue}$idenfy"
            var response = synchronized(this) {
              responsesMap.remove(key)
            }
            if (response != null) {
              response.callback(data)
            }
          }
          else -> {}
        }

    }
  }

  private fun _send(path: String, method: Method, idenfy: String? = null, parameters: String? = null) {
      var request = mutableMapOf<String, String>()
      request["path"] = path
      request["method"] = method.rawValue
      if (parameters != null) {
        request["data"] = parameters
      }
      if (idenfy != null) {
        request["id"] = idenfy
      }
      writerChannel.send(request)
  }

  public fun get(path: String, parameters: String? = null, callback:  (String?) -> Unit) {
    val idenfy = UUID.randomUUID().toString()
    val key =  "$path${Method.REQUEST.rawValue}$idenfy"
    val response = Response(path, idenfy, callback)
    synchronized(this) {
      responsesMap[key] = response
    }
    _send(path, Method.REQUEST, idenfy, parameters)
  }

  public fun post(path: String, parameters: String? = null) {
    _send(path, Method.OBSERVER, null, parameters)
  }

  public fun addGetObserver(path: String, callback: (String?, (String) -> Unit) -> Unit) {
    val observer =  GetObserver(path, callback)
    getObserversMap[path] = observer
  }

  public fun removeGetObserver(path: String) {
    getObserversMap.remove(path)
  }

  public fun addPostObserver(path: String, callback: (String?) -> Unit) {
    val observer =  PostObserver(path, callback)
    postObserversMap[path] = observer
  }

  public fun removePostObserver(path: String) {
    postObserversMap.remove(path)
  }
}

enum class Method(val rawValue: String) {
  REQUEST("request"),
  RESPONSE("response"),
  OBSERVER("observer")
}

class Response(val path: String, val idenfy: String, val callback: (String?) -> Unit)

class GetObserver(val path: String, val callback: (String?, (String) -> Unit) -> Unit)

class PostObserver(val path: String, val callback: (String?) -> Unit)
