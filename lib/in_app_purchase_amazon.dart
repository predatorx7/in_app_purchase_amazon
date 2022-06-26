import 'in_app_purchase_amazon_platform_interface.dart';
import 'user_data.dart';

export 'user_data.dart';

class InAppPurchaseAmazon {
  Future<void> initialize() {
    return InAppPurchaseAmazonPlatform.instance.initialize();
  }

  Stream<AmazonUserData?> get clientInformationStream {
    return InAppPurchaseAmazonPlatform.instance.clientInformationStream;
  }

  Future<String?> getPlatformVersion() {
    return InAppPurchaseAmazonPlatform.instance.getPlatformVersion();
  }

  Future<AmazonUserData?> getClientInformation() {
    return InAppPurchaseAmazonPlatform.instance.getClientInformation();
  }
}
