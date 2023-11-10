import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:braintree_paypal/platform/braintree_paypal_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelBraintreePaypal platform = MethodChannelBraintreePaypal();
  const MethodChannel channel = MethodChannel('braintree_paypal');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
