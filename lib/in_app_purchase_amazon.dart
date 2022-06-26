import 'in_app_purchase_amazon_platform_interface.dart';

class InAppPurchaseAmazon {
  Future<String?> getPlatformVersion() {
    return InAppPurchaseAmazonPlatform.instance.getPlatformVersion();
  }
}
