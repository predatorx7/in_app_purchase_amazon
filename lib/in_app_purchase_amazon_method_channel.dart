// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'in_app_purchase_amazon_platform_interface.dart';
import 'user_data.dart';

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
  Future<AmazonUserData?> getClientInformation() async {
    final data = await methodChannel.invokeMethod<Object>(
      _MethodNames.CLIENT_INFORMATION,
    );
    return data == null ? null : AmazonUserData.fromJson(data);
  }

  void _attachMethodChannelListeners() {
    _clientInformationStreamController ??= StreamController.broadcast();
    return methodChannel.setMethodCallHandler(_onMethodCall);
  }

  StreamController<AmazonUserData?>? _clientInformationStreamController;

  @override
  Stream<AmazonUserData?> get clientInformationStream =>
      _clientInformationStreamController!.stream;

  Future<Object?> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case _MethodNames.CLIENT_INFORMATION_CALLBACK:
        final Object? value = call.arguments;
        _clientInformationStreamController
            ?.add(value != null ? AmazonUserData.fromJson(value) : null);
        break;
      default:
        final e = ArgumentError('Unknown method ${call.method}');
        final controller = _clientInformationStreamController;
        if (controller != null) {
          controller.addError(e, StackTrace.current);
        } else {
          throw e;
        }
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
