import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'braintree_paypal_platform_interface.dart';

/// An implementation of [BraintreePaypalPlatform] that uses method channels.
class MethodChannelBraintreePaypal extends BraintreePaypalPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('braintree_paypal');

  @override
  Future<dynamic> tokenizeCreditCard(Map<String, dynamic> parameters) {
    return methodChannel.invokeMethod("tokenizeCreditCard", parameters);
  }

  @override
  Future requestPaypalNonce(Map<String, dynamic> parameters) {
    return methodChannel.invokeMethod("requestPaypalNonce", parameters);
  }

  @override
  Future getDeviceData(Map<String, dynamic> parameters) {
    return methodChannel.invokeMethod("getDeviceData", parameters);
  }
}
