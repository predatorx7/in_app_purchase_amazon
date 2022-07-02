import 'package:flutter/cupertino.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'in_app_purchase_amazon_method_channel.dart';
import 'user_data.dart';

abstract class InAppPurchaseAmazonPlatform extends PlatformInterface {
  /// Constructs a InAppPurchaseAmazonPlatform.
  InAppPurchaseAmazonPlatform() : super(token: _token);

  static final Object _token = Object();

  static InAppPurchaseAmazonPlatform _instance =
      MethodChannelInAppPurchaseAmazon();

  /// The default instance of [InAppPurchaseAmazonPlatform] to use.
  ///
  /// Defaults to [MethodChannelInAppPurchaseAmazon].
  static InAppPurchaseAmazonPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InAppPurchaseAmazonPlatform] when
  /// they register themselves.
  static set instance(InAppPurchaseAmazonPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize();

  Future<bool?> updatePackageInstaller(String installerPackageName);

  Stream<AmazonUserData?> get clientInformationStream;

  Stream<String?> get licenseVerificationResponseStream;

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getAmazonSdkMode() {
    throw UnimplementedError('amazonSdkMode() has not been implemented.');
  }

  Future<bool> getClientInformation() {
    throw UnimplementedError(
        'getClientInformation() has not been implemented.');
  }

  @mustCallSuper
  void dispose() {}
}
