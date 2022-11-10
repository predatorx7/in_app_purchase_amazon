// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'in_app_purchase_amazon_platform_interface.dart';
import 'user_data.dart';

class _MethodNames {
  static const UPDATE_PACKAGE_INSTALLER = "Additional#updatePackageInstaller()";
  static const INITIALIZE = "AmazonIAPClient#initialize()";
  static const SDK_MODE = "AmazonIAPClient#getSDKMode()";
  static const PLATFORM_VERSION = "AmazonIAPClient#getPlatformVersion()";
  static const CLIENT_INFORMATION = "AmazonIAPClient#getClientInformation()";
  static const CLIENT_INFORMATION_CALLBACK =
      "AmazonIAPClient#onClientInformation(AmazonUserData)";
  static const LICENSE_VERIFICATION_RESPONSE_CALLBACK =
      "AmazonIAPClient#onLicenseVerificationResponse()";
  static const SKUS = "AmazonIAPClient#SKU(sku_names)";
  static const SKUS_CALLBACK = "AmazonIAPClient#onSKU(AmazonUserData)";
  static const PURCHASE_UPDATES =
      "AmazonIAPClient#getPurchaseUpdateData(boolean)";
  static const PURCHASE_UPDATES_CALLBACK =
      "AmazonIAPClient#onPurchaseUpdateData(PurchaseDetails)";
  static const PURCHASE = "AmazonIAPClient#doPurchase()";
  static const PURCHASE_CALLBACK = "AmazonIAPClient#onPurchaseData(receipt)";
  static const ERROR_CALLBACK = "AmazonIAPClient#onError(ErrorDescription)";
}

/// An implementation of [InAppPurchaseAmazonPlatform] that uses method channels.
class MethodChannelInAppPurchaseAmazon extends InAppPurchaseAmazonPlatform {
  MethodChannelInAppPurchaseAmazon() {
    methodChannel.setMethodCallHandler(_onMethodCall);
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
      'plugins.magnificsoftware.com/in_app_purchase_amazon');

  @override
  Future<bool?> updatePackageInstaller(String installerPackageName) {
    return methodChannel.invokeMethod<bool>(
      _MethodNames.UPDATE_PACKAGE_INSTALLER,
      installerPackageName,
    );
  }

  @override
  Future<void> initialize() async {
    await methodChannel.invokeMethod(_MethodNames.INITIALIZE);
  }

  @override
  Future<String?> getPlatformVersion() {
    return methodChannel.invokeMethod<String>(
      _MethodNames.PLATFORM_VERSION,
    );
  }

  @override
  Future<String?> getAmazonSdkMode() {
    return methodChannel.invokeMethod<String>(
      _MethodNames.SDK_MODE,
    );
  }

  @override
  Future<bool> getClientInformation() async {
    final data = await methodChannel.invokeMethod<Object>(
      _MethodNames.CLIENT_INFORMATION,
    );
    return data == true;
  }

  @override
  Future<bool> requestSkus(Set<String> skus) async {
    assert(skus.isNotEmpty, 'SKUS should not be empty');
    final data = await methodChannel
        .invokeMethod<Object>(_MethodNames.SKUS, <dynamic, dynamic>{
      'skus': <dynamic>[...skus],
    });
    return data == true;
  }

  @override
  Future<bool> startPurchase(String sku) async {
    final data = await methodChannel
        .invokeMethod<Object>(_MethodNames.PURCHASE, <dynamic, dynamic>{
      "sku": sku,
    });
    return data == true;
  }

  @override
  Future<bool> requestPurchaseUpdatesInformation([bool activate = true]) async {
    final data = await methodChannel
        .invokeMethod<Object>(_MethodNames.PURCHASE_UPDATES, <dynamic, dynamic>{
      "activate": activate,
    });
    return data == true;
  }

  final StreamController<AmazonUserData?> _clientInformationStreamController =
      StreamController<AmazonUserData?>();
  final _licenseVerificationResponseStreamController =
      StreamController<String?>.broadcast();
  final StreamController<Object?> _errorStreamController =
      StreamController<Object?>.broadcast();
  final StreamController<Object?> _skusStreamController =
      StreamController<Object?>.broadcast();
  final StreamController<Object?> _purchaseStreamController =
      StreamController<Object?>.broadcast();
  final StreamController<Object?> _purchaseUpdatesStreamController =
      StreamController<Object?>.broadcast();

  @override
  Stream<AmazonUserData?> get clientInformationStream =>
      _clientInformationStreamController.stream;

  @override
  Stream<String?> get licenseVerificationResponseStream =>
      _licenseVerificationResponseStreamController.stream;

  @override
  Stream<Object?> get errorStream => _errorStreamController.stream;

  @override
  Stream<Object?> get skusStream => _skusStreamController.stream;

  @override
  Stream<Object?> get purchaseStream => _purchaseStreamController.stream;

  @override
  Stream<Object?> get purchaseUpdatesStream =>
      _purchaseUpdatesStreamController.stream;

  Future<Object?> _onMethodCall(MethodCall call) async {
    if (kDebugMode) {
      debugPrint('onMethodCall(${call.method}, ${call.arguments})');
    }

    switch (call.method) {
      case _MethodNames.CLIENT_INFORMATION_CALLBACK:
        final Object? value = call.arguments;
        _clientInformationStreamController
            .add(value != null ? AmazonUserData.fromJson(value) : null);
        break;
      case _MethodNames.LICENSE_VERIFICATION_RESPONSE_CALLBACK:
        final Object? value = call.arguments;
        _licenseVerificationResponseStreamController
            .add(value is String ? value : null);
        break;
      case _MethodNames.ERROR_CALLBACK:
        final Object? value = call.arguments;
        _errorStreamController.add(value);
        break;
      case _MethodNames.SKUS_CALLBACK:
        final Object? value = call.arguments;
        _skusStreamController.add(value);
        break;
      case _MethodNames.PURCHASE_CALLBACK:
        final Object? value = call.arguments;
        _purchaseStreamController.add(value);
        break;

      case _MethodNames.PURCHASE_UPDATES_CALLBACK:
        final Object? value = call.arguments;
        _purchaseUpdatesStreamController.add(value);
        break;

      default:
        final e = ArgumentError(
          'Unknown method ${call.method} ${call.arguments}',
        );
        _errorStreamController.addError(e, StackTrace.current);
    }
    return Future.value(null);
  }
}
