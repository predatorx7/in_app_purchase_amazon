// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'in_app_purchase_amazon_platform_interface.dart';
import 'user_data.dart';

class _MethodNames {
  static const INITIALIZE = "AmazonIAPClient#initialize()";
  static const PLATFORM_VERSION = "AmazonIAPClient#getPlatformVersion()";
  static const CLIENT_INFORMATION = "AmazonIAPClient#getClientInformation()";
  static const CLIENT_INFORMATION_CALLBACK =
      "AmazonIAPClient#onClientInformation(AmazonUserData)";
  static const SDK_MODE = "AmazonIAPClient#getSDKMode()";
  static const LICENSE_VERIFICATION_RESPONSE_CALLBACK =
      "AmazonIAPClient#onLicenseVerificationResponse()";
}

/// An implementation of [InAppPurchaseAmazonPlatform] that uses method channels.
class MethodChannelInAppPurchaseAmazon extends InAppPurchaseAmazonPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
      'plugins.magnificsoftware.com/in_app_purchase_amazon');

  Completer<void>? _completer;

  @override
  Future<void> initialize() async {
    if (_completer != null) return _completer!.future;

    _attachMethodChannelListeners();

    final completer = _completer ?? Completer();
    _completer = completer;

    if (!completer.isCompleted) {
      try {
        await methodChannel.invokeMethod(_MethodNames.INITIALIZE);
        completer.complete();
      } on PlatformException catch (e) {
        completer.completeError(e);
        _completer = null;
      }
    }

    return completer.future;
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

  void _attachMethodChannelListeners() {
    _clientInformationStreamController ??= StreamController.broadcast();
    _licenseVerificationResponseStreamController ??=
        StreamController.broadcast();
    return methodChannel.setMethodCallHandler(_onMethodCall);
  }

  StreamController<AmazonUserData?>? _clientInformationStreamController;
  StreamController<String?>? _licenseVerificationResponseStreamController;

  @override
  Stream<AmazonUserData?> get clientInformationStream =>
      _clientInformationStreamController!.stream;

  @override
  Stream<String?> get licenseVerificationResponseStream =>
      _licenseVerificationResponseStreamController!.stream;

  Future<Object?> _onMethodCall(MethodCall call) async {
    if (kDebugMode) {
      debugPrint('onMethodCall(${call.method}, ${call.arguments})');
    }

    switch (call.method) {
      case _MethodNames.CLIENT_INFORMATION_CALLBACK:
        final Object? value = call.arguments;
        _clientInformationStreamController
            ?.add(value != null ? AmazonUserData.fromJson(value) : null);
        break;
      case _MethodNames.LICENSE_VERIFICATION_RESPONSE_CALLBACK:
        final Object? value = call.arguments;
        _licenseVerificationResponseStreamController
            ?.add(value is String ? value : null);
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
    _licenseVerificationResponseStreamController?.close();
    _clientInformationStreamController = null;
    _licenseVerificationResponseStreamController = null;
    _completer = null;
  }
}
