import Flutter
import UIKit
import Braintree

public class BraintreePaypalPlugin: NSObject, FlutterPlugin {
    private var isHandlingResult:Bool = false

    //
    // Platform Channel handler
    //

      public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "braintree_paypal", binaryMessenger: registrar.messenger())
        let instance = BraintreePaypalPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
      }

      public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          guard !isHandlingResult else {
              returnAlreadyOpenError(result: result)
              return
          }

          isHandlingResult = true

          guard let authorization = getAuthorization(call: call),
                let requestInfo = getRequestFrom(call) else {
              returnAuthorizationMissingError(result: result)
              isHandlingResult = false
              return
          }

          if let client = BTAPIClient(authorization: authorization) {
              switch call.method {
              case "getDeviceData":
                  getDeviceData(using: client, result: result)
              case "tokenizeCreditCard":
                tokenizeCreditCard(using: client, request: requestInfo, result: result)
              case "requestPaypalNonce":
                  requestPaypalNonce(using: client, request: requestInfo, result: result)
              default:
                result(FlutterMethodNotImplemented)
              }
          } else {
                result(FlutterMethodNotImplemented)
          }
      }

    //
    // Actions
    //

    private func getDeviceData(using client: BTAPIClient, result: @escaping FlutterResult) {
        let dataCollector = BTDataCollector(apiClient: client)
        dataCollector.collectDeviceData { deviceDataString, error in
            if let deviceDataString = deviceDataString {
                result(deviceDataString)
            } else {
                result(FlutterError(code: "braintree_no_device_data", message: error?.localizedDescription, details: nil))
            }
        }
    }

    private func tokenizeCreditCard(using client: BTAPIClient, request: [String: Any],  result: @escaping FlutterResult) {
        let cardClient = BTCardClient(apiClient: client)

        let card = BTCard()
        card.number = request["cardNumber"] as? String
        card.expirationMonth = request["expirationMonth"] as? String
        card.expirationYear = request["expirationYear"] as? String
        card.cvv = request["cvv"] as? String
        card.cardholderName = request["cardholderName"] as? String

        cardClient.tokenize(card) { (nonce, error) in
            self.handleResult(nonce: nonce, error: error, flutterResult: result)
            self.isHandlingResult = false
        }
      }

    private func requestPaypalNonce(using client: BTAPIClient, request: [String: Any],  result: @escaping FlutterResult) {
        let paypalClient = BTPayPalClient(apiClient: client)

        if let amount = request["amount"] as? String {
            let paypalRequest = BTPayPalCheckoutRequest(amount: amount)
            paypalRequest.currencyCode = request["currencyCode"] as? String
            paypalRequest.displayName = request["displayName"] as? String
            paypalRequest.billingAgreementDescription = request["billingAgreementDescription"] as? String
            if let intent = request["payPalPaymentIntent"] as? String {
                switch intent {
                case "order":
                    paypalRequest.intent = BTPayPalRequestIntent.order
                case "sale":
                    paypalRequest.intent = BTPayPalRequestIntent.sale
                default:
                    paypalRequest.intent = BTPayPalRequestIntent.authorize
                }
            }
            if let userAction = request["payPalPaymentUserAction"] as? String {
                switch userAction {
                case "commit":
                    paypalRequest.userAction = BTPayPalRequestUserAction.payNow
                default:
                    paypalRequest.userAction = BTPayPalRequestUserAction.none
                }
            }
            paypalClient.tokenize(paypalRequest) { (nonce, error) in
                self.handleResult(nonce: nonce, error: error, flutterResult: result)
                self.isHandlingResult = false
            }
        } else {
            let paypalRequest = BTPayPalVaultRequest()
            paypalRequest.displayName = request["displayName"] as? String
            paypalRequest.billingAgreementDescription = request["billingAgreementDescription"] as? String

            paypalClient.tokenize(paypalRequest) { (nonce, error) in
                self.handleResult(nonce: nonce, error: error, flutterResult: result)
                self.isHandlingResult = false
            }
        }

    }

    //
    // Authorization
    //

    /**
     Will get the authorization for the current method call. This will basically check for a  *clientToken*, *tokenizationKey* or *authorization* property on the call.
     This does not take care about sending the error to the Flutter result.
     */
    private func getAuthorization(call: FlutterMethodCall) -> String? {
        let clientToken = string(for: "clientToken", in: call)
        let tokenizationKey = string(for: "tokenizationKey", in: call)
        let authorizationKey = string(for: "authorization", in: call)

        guard let authorization = clientToken
            ?? tokenizationKey
            ?? authorizationKey else {
            return nil
        }

        return authorization
    }

    //
    // Return result
    //

    private func handleResult(nonce: BTPaymentMethodNonce?, error: Error?, flutterResult: FlutterResult) {
        if error != nil {
            returnBraintreeError(result: flutterResult, error: error!)
        } else if nonce == nil {
            flutterResult(nil)
        } else {
            flutterResult(buildPaymentNonceDict(nonce: nonce));
        }
    }

    private func returnAuthorizationMissingError (result: FlutterResult) {
        result(FlutterError(code: "braintree_missing_authorization", message: "Authorization not specified (no clientToken or tokenizationKey)", details: nil))
    }

    private func returnBraintreeError(result: FlutterResult, error: Error) {
        result(FlutterError(code: "braintree_error", message: error.localizedDescription, details: nil))
    }

    private func returnAlreadyOpenError(result: FlutterResult) {
        result(FlutterError(code: "braintree_process_already_running", message: "Cannot launch another Braintree activity while one is already running.", details: nil));
    }

    //
    // Format
    //

    private func getRequestFrom(_ call: FlutterMethodCall) -> [String: Any]? {
        return dict(for: "request", in: call)
    }

    private func buildPaymentNonceDict(nonce: BTPaymentMethodNonce?) -> [String: Any?] {
        var dict = [String: Any?]()
        dict["nonce"] = nonce?.nonce
        dict["typeLabel"] = nonce?.type
        dict["description"] = nonce?.nonce
        dict["isDefault"] = nonce?.isDefault
        if let paypalNonce = nonce as? BTPayPalAccountNonce {
            dict["paypalPayerId"] = paypalNonce.payerID
            dict["description"] = paypalNonce.email
        }
        return dict
    }

    //
    // Types helper
    //

    private func string(for key: String, in call: FlutterMethodCall) -> String? {
        return (call.arguments as? [String: Any])?[key] as? String
    }


    private func bool(for key: String, in call: FlutterMethodCall) -> Bool? {
        return (call.arguments as? [String: Any])?[key] as? Bool
    }


    private func dict(for key: String, in call: FlutterMethodCall) -> [String: Any]? {
        return (call.arguments as? [String: Any])?[key] as? [String: Any]
    }
}
