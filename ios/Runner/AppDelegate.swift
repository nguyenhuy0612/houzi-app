import UIKit
import Flutter
import GoogleMaps

import google_mobile_ads

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {


    private var methodChannel: FlutterMethodChannel?
    private let linkStreamHandler = LinkStreamHandler()
    private var eventChannel:FlutterEventChannel?

    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        //DEEP LINKING RELATED CODE
        let controller = window.rootViewController as! FlutterViewController

        methodChannel = FlutterMethodChannel(name: "houzi_link_channel/channel", binaryMessenger: controller.binaryMessenger)

        eventChannel = FlutterEventChannel(name: "houzi_link_channel/events", binaryMessenger: controller as! FlutterBinaryMessenger)


        methodChannel?.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) in
              guard call.method == "initialLink" else {
                result(FlutterMethodNotImplemented)
                return
              }
            })
        //DEEP LINKING RELATED CODE END


        GeneratedPluginRegistrant.register(with: self)
        // TODO: Add your API key
        GMSServices.provideAPIKey("AIzaSyBqQMpR73ry257vNlpmgigNJ73qcKCpuOk")

        //Mobile Ads - uncomment if ads required.
        let listTileFactory = ListTileNativeAdViewFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(

            self, factoryId: "listTile", nativeAdFactory: listTileFactory)

        let homeTileFactory = HomeNativeAdViewFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self, factoryId: "homeNativeAd", nativeAdFactory: homeTileFactory)

        eventChannel?.setStreamHandler(linkStreamHandler)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        eventChannel?.setStreamHandler(linkStreamHandler)
        print("url \(url)");
        return linkStreamHandler.handleLink(url.absoluteString)
    }

    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL  {
            eventChannel?.setStreamHandler(linkStreamHandler)
            return linkStreamHandler.handleLink(url.absoluteString)
        }
        return false;
    }
}


class LinkStreamHandler:NSObject, FlutterStreamHandler {

    var eventSink: FlutterEventSink?

    // links will be added to this queue until the sink is ready to process them
    var queuedLinks = [String]()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        queuedLinks.forEach({ events($0) })
        queuedLinks.removeAll()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    func handleLink(_ link: String) -> Bool {
        guard let eventSink = eventSink else {
            queuedLinks.append(link)
            return false
        }
        eventSink(link)
        return true
    }
}

