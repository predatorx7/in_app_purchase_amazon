import 'package:flutter/foundation.dart';
import 'package:in_app_purchase_amazon/product.dart';

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

  Stream<AmazonSkusData?> get skusStream {
    return InAppPurchaseAmazonPlatform.instance.skusStream.map(
      (event) {
        if (event == null) return null;
        try {
          return AmazonSkusData.fromJson(event);
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
            print(s);
          }
        }
        return null;
      },
    );
  }

  Stream<Object?> get errorStream {
    return InAppPurchaseAmazonPlatform.instance.errorStream;
  }

  Stream<PurchaseResponse?> get purchaseStream {
    return InAppPurchaseAmazonPlatform.instance.purchaseStream.map(
      (event) {
        if (event == null) return null;
        try {
          return PurchaseResponse.fromJson(event);
        } catch (e, s) {
          if (kDebugMode) {
            print(e);
            print(s);
          }
        }
        return null;
      },
    );
  }

  Stream<PurchaseHistoryData?> get purchaseUpdatesStream {
    return InAppPurchaseAmazonPlatform.instance.purchaseUpdatesStream
        .map((event) {
      if (event == null) return null;
      try {
        return PurchaseHistoryData.fromJson(event);
      } catch (e, s) {
        if (kDebugMode) {
          print(e);
          print(s);
        }
      }
      return null;
    });
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

  Future<bool> requestSkus(Set<String> skus) {
    return InAppPurchaseAmazonPlatform.instance.requestSkus(skus);
  }

  Future<bool> startPurchase(String sku) {
    return InAppPurchaseAmazonPlatform.instance.startPurchase(sku);
  }

  Future<bool> requestPurchaseUpdatesInformation([bool activate = true]) {
    return InAppPurchaseAmazonPlatform.instance
        .requestPurchaseUpdatesInformation(activate);
  }
}
