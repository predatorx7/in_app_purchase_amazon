import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_amazon/in_app_purchase_amazon_method_channel.dart';

void main() {
  MethodChannelInAppPurchaseAmazon platform =
      MethodChannelInAppPurchaseAmazon();
  const MethodChannel channel =
      MethodChannel('plugins.magnificsoftware.com/in_app_purchase_amazon');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
