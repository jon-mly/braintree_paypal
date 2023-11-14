import 'package:braintree_paypal/src/types/credit_card_request.dart';
import 'package:braintree_paypal/src/types/nonce.dart';
import 'package:braintree_paypal/src/types/paypal_request.dart';

import 'package:braintree_paypal/platform/braintree_paypal_platform_interface.dart';

class BraintreePaypal {
  /// Tokenizes a credit card.
  ///
  /// [authorization] must be either a valid client token or a valid tokenization key.
  /// [request] should contain all the credit card information necessary for tokenization.
  ///
  /// Returns a [Future] that resolves to a [BraintreePaymentMethodNonce] if the tokenization was successful.
  static Future<BraintreePaymentMethodNonce?> tokenizeCreditCard(
    String authorization,
    BraintreeCreditCardRequest request,
  ) async {
    final dynamic result =
        await BraintreePaypalPlatform.instance.tokenizeCreditCard({
      'authorization': authorization,
      'request': request.toJson(),
    });
    if (result == null) return null;
    return BraintreePaymentMethodNonce.fromJson(result);
  }

  /// Requests a PayPal payment method nonce.
  ///
  /// [authorization] must be either a valid client token or a valid tokenization key.
  /// [request] should contain all the information necessary for the PayPal request.
  ///
  /// Returns a [Future] that resolves to a [BraintreePaymentMethodNonce] if the user confirmed the request,
  /// or `null` if the user canceled the Vault or Checkout flow.
  static Future<BraintreePaymentMethodNonce?> requestPaypalNonce(
    String authorization,
    BraintreePayPalRequest request,
  ) async {
    final dynamic result =
        await BraintreePaypalPlatform.instance.requestPaypalNonce({
      'authorization': authorization,
      'request': request.toJson(),
    });
    if (result == null) return null;
    return BraintreePaymentMethodNonce.fromJson(result);
  }

  /// Get the Device Data payload to send to Braintree
  ///
  /// This step is required when using non-recurring transactions from Vault
  /// record.
  ///
  /// Returns a device data string to be sent as-is to your server when
  /// performing a payment operation
  static Future<String?> getDeviceData(String authorization) async {
    final dynamic result =
        await BraintreePaypalPlatform.instance.getDeviceData({
      'authorization': authorization,
      'request': {},
    });
    if (result == null) return null;
    return result;
  }
}
