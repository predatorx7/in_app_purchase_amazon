import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_amazon/in_app_purchase_amazon.dart';
import 'package:in_app_purchase_amazon/in_app_purchase_amazon_platform_interface.dart';
import 'package:in_app_purchase_amazon/in_app_purchase_amazon_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInAppPurchaseAmazonPlatform
    with MockPlatformInterfaceMixin
    implements InAppPurchaseAmazonPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  void dispose() {
    _clientInformationStreamController?.close();
    _clientInformationStreamController = null;
    Future.value(null);
  }

  StreamController<Object?>? _clientInformationStreamController;

  @override
  Stream get clientInformationStream =>
      _clientInformationStreamController!.stream;

  @override
  Future<Object?> getClientInformation() {
    final o = Object();
    _clientInformationStreamController?.add(o);
    return Future.value(o);
  }

  @override
  Future<void> initialize() {
    _clientInformationStreamController = StreamController.broadcast();
    return Future.value(null);
  }
}

void main() {
  final InAppPurchaseAmazonPlatform initialPlatform =
      InAppPurchaseAmazonPlatform.instance;

  test('$MethodChannelInAppPurchaseAmazon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInAppPurchaseAmazon>());
  });

  test('getPlatformVersion', () async {
    InAppPurchaseAmazon inAppPurchaseAmazonPlugin = InAppPurchaseAmazon();
    MockInAppPurchaseAmazonPlatform fakePlatform =
        MockInAppPurchaseAmazonPlatform();
    InAppPurchaseAmazonPlatform.instance = fakePlatform;

    expect(await inAppPurchaseAmazonPlugin.getPlatformVersion(), '42');
  });
}
