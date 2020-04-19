import Flutter
import UIKit

import PersonalizedAdConsent
public class SwiftGdprDialogPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "gdpr_dialog", binaryMessenger: registrar.messenger())
    let instance = SwiftGdprDialogPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch (call.method) {
      case "gdpr.activate":
        let arg = call.arguments as? NSDictionary
        let pubId = arg!["publisherId"] as? String;
        let url = arg!["privacyUrl"] as? String;
        
        self.checkConsent(result: result, publisherId: pubId!, privacyUrl: url!)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    private func checkConsent(result: @escaping FlutterResult, publisherId: String, privacyUrl: String) {

        SwiftGdprDialogPlugin.initGDPR(key: publisherId, url:privacyUrl)
        
        result(PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.personalized);
    }

    public static func initGDPR(key: String, url:String)
    {
           PACConsentInformation.sharedInstance.requestConsentInfoUpdate(
                    forPublisherIdentifiers: [key])
                {(_ error: Error?) -> Void in
                    if let error = error {
                    } else {
                        if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.unknown {
                            
                            guard let privacyUrl = URL(string: url),
                                let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                                    return
                            }
                            form.shouldOfferPersonalizedAds = true
                            form.shouldOfferNonPersonalizedAds = true
                            form.shouldOfferAdFree = false
                            
                            form.load {(_ error: Error?) -> Void in
                                if let error = error {
                                    // Handle error.
                                } else {
                                    if let vc = UIApplication.shared.keyWindow?.rootViewController {
                                        form.present(from: vc) { (error, userPrefersAdFree) in
                                                                              
                                                                           }
                                    }
                                   
                                }
                            }
                        }
                    }
                }
    }

}
