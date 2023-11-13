import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'braintree_paypal_method_channel.dart';

abstract class BraintreePaypalPlatform extends PlatformInterface {
  /// Constructs a BraintreePaypalPlatform.
  BraintreePaypalPlatform() : super(token: _token);

  static final Object _token = Object();

  static BraintreePaypalPlatform _instance = MethodChannelBraintreePaypal();

  /// The default instance of [BraintreePaypalPlatform] to use.
  ///
  /// Defaults to [MethodChannelBraintreePaypal].
  static BraintreePaypalPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BraintreePaypalPlatform] when
  /// they register themselves.
  static set instance(BraintreePaypalPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<dynamic> tokenizeCreditCard(Map<String, dynamic> parameters);

  Future<dynamic> requestPaypalNonce(Map<String, dynamic> parameters);

  Future<dynamic> getDeviceData(Map<String, dynamic> parameters);
}
