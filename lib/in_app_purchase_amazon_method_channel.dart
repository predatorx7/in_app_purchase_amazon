// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'in_app_purchase_amazon_platform_interface.dart';

class _MethodNames {
  static const PLATFORM_VERSION = "AmazonIAPClient#getPlatformVersion()";
  static const CLIENT_INFORMATION = "AmazonIAPClient#getClientInformation()";
  static const CLIENT_INFORMATION_CALLBACK =
      "AmazonIAPClient#onClientInformation(AmazonUserData)";
}

/// An implementation of [InAppPurchaseAmazonPlatform] that uses method channels.
class MethodChannelInAppPurchaseAmazon extends InAppPurchaseAmazonPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
      'plugins.magnificsoftware.com/in_app_purchase_amazon');

  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _attachMethodChannelListeners();

    _isInitialized = true;
  }

  @override
  Future<String?> getPlatformVersion() {
    return methodChannel.invokeMethod<String>(
      _MethodNames.PLATFORM_VERSION,
    );
  }

  @override
  Future<Object?> getClientInformation() async {
    return methodChannel.invokeMethod<Object>(
      _MethodNames.CLIENT_INFORMATION,
    );
  }

  void _attachMethodChannelListeners() {
    _clientInformationStreamController ??= StreamController.broadcast();
    return methodChannel.setMethodCallHandler(_onMethodCall);
  }

  StreamController<Object?>? _clientInformationStreamController;

  @override
  Stream get clientInformationStream =>
      _clientInformationStreamController!.stream;

  Future<Object?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case _MethodNames.CLIENT_INFORMATION_CALLBACK:
        final Object? value = call.arguments;
        _clientInformationStreamController?.add(value);
        break;
      default:
        throw ArgumentError('Unknown method ${call.method}');
    }
    return Future.value(null);
  }

  @override
  void dispose() {
    super.dispose();
    _clientInformationStreamController?.close();
    _clientInformationStreamController = null;
    _isInitialized = false;
  }
}
