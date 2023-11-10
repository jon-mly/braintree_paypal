// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'braintree_paypal_platform_interface.dart';

/// A web implementation of the BraintreePaypalPlatform of the BraintreePaypal plugin.
class BraintreePaypalWeb extends BraintreePaypalPlatform {
  /// Constructs a BraintreePaypalWeb
  BraintreePaypalWeb();

  static void registerWith(Registrar registrar) {
    BraintreePaypalPlatform.instance = BraintreePaypalWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  @override
  Future tokenizeCreditCard(Map<String, dynamic> parameters) {
    // TODO: implement tokenizeCreditCard
    throw UnimplementedError();
  }

  @override
  Future requestPaypalNonce(Map<String, dynamic> parameters) {
    // TODO: implement requestPaypalNonce
    throw UnimplementedError();
  }
}
