import UIKit
import Flutter
import easy_channel

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  private var pluginChannel: SwiftEasyChannelPlugin?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
    GeneratedPluginRegistrant.register(with: self)
    pluginChannel = self.valuePublished(byPlugin: "EasyChannelPlugin") as? SwiftEasyChannelPlugin
      DispatchQueue.main.asyncAfter(deadline: .now()+6) {
          self.pluginChannel?.post("call.flutter")
      }
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
