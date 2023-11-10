// import 'package:flutter_test/flutter_test.dart';
// import 'package:braintree_paypal/braintree_paypal.dart';
// import 'package:braintree_paypal/braintree_paypal_platform_interface.dart';
// import 'package:braintree_paypal/platform/braintree_paypal_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// class MockBraintreePaypalPlatform
//     with MockPlatformInterfaceMixin
//     implements BraintreePaypalPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final BraintreePaypalPlatform initialPlatform = BraintreePaypalPlatform.instance;
//
//   test('$MethodChannelBraintreePaypal is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelBraintreePaypal>());
//   });
//
//   test('getPlatformVersion', () async {
//     BraintreePaypal braintreePaypalPlugin = BraintreePaypal();
//     MockBraintreePaypalPlatform fakePlatform = MockBraintreePaypalPlatform();
//     BraintreePaypalPlatform.instance = fakePlatform;
//
//     expect(await braintreePaypalPlugin.getPlatformVersion(), '42');
//   });
// }
