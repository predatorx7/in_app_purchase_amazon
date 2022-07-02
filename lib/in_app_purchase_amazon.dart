import 'in_app_purchase_amazon_platform_interface.dart';
import 'user_data.dart';

export 'user_data.dart';

class InAppPurchaseAmazon {
  Future<void> initialize() {
    return InAppPurchaseAmazonPlatform.instance.initialize();
  }

  static Future<bool?> updatePackageInstaller(String installerPackageName) {
    return InAppPurchaseAmazonPlatform.instance.updatePackageInstaller(
      installerPackageName,
    );
  }

  Stream<AmazonUserData?> get clientInformationStream {
    return InAppPurchaseAmazonPlatform.instance.clientInformationStream;
  }

  Stream<String?> get licenseVerificationResponseStream {
    return InAppPurchaseAmazonPlatform
        .instance.licenseVerificationResponseStream;
  }

  Future<String?> getPlatformVersion() {
    return InAppPurchaseAmazonPlatform.instance.getPlatformVersion();
  }

  Future<String?> getAmazonSdkMode() {
    return InAppPurchaseAmazonPlatform.instance.getAmazonSdkMode();
  }

  Future<bool> getClientInformation() {
    return InAppPurchaseAmazonPlatform.instance.getClientInformation();
  }
}
