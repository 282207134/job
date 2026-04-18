import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Android は manifest の meta-data で key を渡すが、iOS は未設定でも他機能に影響させない
    if let raw = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
      let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
      if !key.isEmpty, !key.contains("$("), key != "$(GOOGLE_MAPS_IOS_KEY)" {
        GMSServices.provideAPIKey(key)
      }
    }
  }
}
