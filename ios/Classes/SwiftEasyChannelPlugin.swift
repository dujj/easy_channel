import Flutter
import UIKit

public class SwiftEasyChannelPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      
      let instance = SwiftEasyChannelPlugin(messenger: registrar.messenger())
      registrar.publish(instance)
      
  }

  class GetObserver: NSObject {
      var path: String
      var callback: (([String: Any]?, @escaping ([String: Any]) -> Void) -> Void)
    
      init(path: String, callback: @escaping ([String: Any]?, @escaping ([String: Any]) -> Void) -> Void) {
          self.path = path
          self.callback = callback
          super.init()
      }
  }
    
    class PostObserver: NSObject {
        var path: String
        var callback: (([String: Any]?) -> Void)
        
        init(path: String, callback: @escaping ([String: Any]?) -> Void) {
            self.path = path
            self.callback = callback
            super.init()
        }
    }
    
    class Response: NSObject {
        var path: String
        var idenfy: String
        var callback: (([String: Any]?) -> Void)
        
        init(path: String, idenfy: String, callback: @escaping ([String: Any]?) -> Void) {
            self.path = path
            self.idenfy = idenfy
            self.callback = callback
            super.init()
        }
    }
    
    enum Method: String {
        case request = "request"
        case response = "response"
        case observer = "observer"
    }
    
    private var writerChannel: FlutterBasicMessageChannel

    private var readerChannel: FlutterBasicMessageChannel
    
    private var responsesMap: [String: Response] = [:]
    private var getObserversMap: [String: GetObserver] = [:]
    private var postObserversMap: [String: PostObserver] = [:]
    
    private var writerQueue: DispatchQueue = DispatchQueue(label: "com.flutter.easy.channel.writer.queue")
    private var readerQueue: DispatchQueue = DispatchQueue(label: "com.flutter.easy.channel.reader.queue")
    
    private var operationQueue: DispatchQueue = DispatchQueue(label: "com.flutter.easy.channel.operation", attributes: [.concurrent])
    
    init(messenger: FlutterBinaryMessenger) {
        writerChannel = FlutterBasicMessageChannel(name: "com.flutter.easy.channel.reader", binaryMessenger: messenger, codec: FlutterJSONMessageCodec.sharedInstance())
        readerChannel = FlutterBasicMessageChannel(name: "com.flutter.easy.channel.writer", binaryMessenger: messenger, codec: FlutterJSONMessageCodec.sharedInstance())
        super.init()
        
        readerChannel.setMessageHandler { [weak self] message, reply in
            
            if let mMessage = message {
                self?.readerQueue.async {
                    self?.didReadData(message: mMessage)
                }
            }
            reply(nil)
        }
    }
    
    deinit {
        getObserversMap.removeAll()
        postObserversMap.removeAll()
        responsesMap.removeAll()
    }
    
    private func didReadData(message: Any) {
        if let respone = message as? [String: Any] {
            if let method = respone["method"] as? String, let methodType = Method(rawValue: method) {
                let path = respone["path"] as? String ?? "unknow"
                let idenfy  = respone["id"]  as? String ?? "unknow"
                var result: [String: Any]?
                if let jsonString = respone["data"] as? String,
                   let jsonData = jsonString.data(using: .utf8),
                   let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) {
                    result = jsonObject as? [String: Any]
                }
                
                switch methodType {
                case .request:
                    let observer = getObserversMap[path]
                    operationQueue.async { [weak self] in
                        observer?.callback(result) { re in
                            self?._send(path, method: .response, idenfy: idenfy, parameters: re)
                        }
                    }
                case .observer:
                    let observer = postObserversMap[path]
                    operationQueue.async {
                        observer?.callback(result)
                    }
                case .response:
                    let key = path + Method.request.rawValue + idenfy
                    var response: Response?
                    DispatchQueue.main.sync { [weak self] in
                        response = self?.responsesMap.removeValue(forKey: key)
                    }
                    if let re = response {
                        operationQueue.async {
                            re.callback(result)
                        }
                    }
                }
            }
        }
    }
    
    private func _send(_ path: String, method: Method, idenfy: String? = nil, parameters: [String: Any]? = nil) {
        writerQueue.async {
            var request = [String: Any]()
            request["path"] = path
            request["method"] = method.rawValue
            if let param = parameters,
                let jsonData = try? JSONSerialization.data(withJSONObject: param),
                let jsonString = String(data: jsonData, encoding: .utf8) {
                request["data"] = jsonString
            }
            if let mIdenfy = idenfy {
                request["id"] = mIdenfy
            }
            self.writerChannel.sendMessage(request)
        }
    }
    
    public func get(_ path: String, parameters: [String: Any]? = nil, callback: @escaping ([String: Any]?) -> Void) {
        let idenfy = UUID().uuidString
        let key =  path + Method.request.rawValue + idenfy
        let response = Response(path: path, idenfy: idenfy, callback: callback)
        responsesMap[key] = response
        _send(path, method: .request, idenfy: idenfy, parameters: parameters)
    }
    
    public func post(_ path: String, parameters: [String: Any]? = nil) {
        _send(path, method: .observer, parameters: parameters)
    }
    
    public func addGetObserver(_ path: String, callback: @escaping ([String: Any]?, @escaping ([String: Any]) -> Void) -> Void) {
        let observer =  GetObserver(path: path, callback: callback)
        getObserversMap[path] = observer
    }
    
    public func removeGetObserver(_ path: String) {
        getObserversMap.removeValue(forKey: path)
    }
    
    public func addPostObserver(_ path: String, callback: @escaping ([String: Any]?) -> Void) {
        let observer =  PostObserver(path: path, callback: callback)
        postObserversMap[path] = observer
    }
    
    public func removePostObserver(_ path: String) {
        postObserversMap.removeValue(forKey: path)
    }
}
