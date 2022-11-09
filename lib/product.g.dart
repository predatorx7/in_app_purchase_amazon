// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AmazonSkusData _$AmazonSkusDataFromJson(Map<String, dynamic> json) =>
    AmazonSkusData(
      json['status'] as String?,
      (json['data'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, SkuData.fromJson(e)),
      ),
    );

Map<String, dynamic> _$AmazonSkusDataToJson(AmazonSkusData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

SkuData _$SkuDataFromJson(Map<String, dynamic> json) => SkuData(
      json['productType'] as String?,
      json['coinsRewardAmount'] as num?,
      json['price'] as String?,
      json['title'] as String?,
      json['sku'] as String?,
      json['description'] as String?,
      json['subscriptionPeriod'] as String?,
      json['smallIconUrl'] as String?,
    );

Map<String, dynamic> _$SkuDataToJson(SkuData instance) => <String, dynamic>{
      'productType': instance.productType,
      'coinsRewardAmount': instance.coinsRewardAmount,
      'price': instance.price,
      'title': instance.title,
      'sku': instance.sku,
      'description': instance.description,
      'subscriptionPeriod': instance.subscriptionPeriod,
      'smallIconUrl': instance.smallIconUrl,
    };

PurchaseHistoryData _$PurchaseHistoryDataFromJson(Map<String, dynamic> json) =>
    PurchaseHistoryData(
      json['status'] as String?,
      (json['data'] as List<dynamic>?)
          ?.map((e) => PurchaseHistory.fromJson(e))
          .toList(),
    );

Map<String, dynamic> _$PurchaseHistoryDataToJson(
        PurchaseHistoryData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

PurchaseHistory _$PurchaseHistoryFromJson(Map<String, dynamic> json) =>
    PurchaseHistory(
      json['sku'] as String?,
      json['termSku'] as String?,
      json['receiptId'] as String?,
      json['itemType'] as String?,
      json['purchaseDate'] as String?,
    );

Map<String, dynamic> _$PurchaseHistoryToJson(PurchaseHistory instance) =>
    <String, dynamic>{
      'sku': instance.sku,
      'termSku': instance.termSku,
      'receiptId': instance.receiptId,
      'itemType': instance.itemType,
      'purchaseDate': instance.purchaseDate,
    };

PurchaseResponse _$PurchaseResponseFromJson(Map<String, dynamic> json) =>
    PurchaseResponse(
      json['status'] as String?,
      json['data'] == null ? null : PurchaseReceipt.fromJson(json['data']),
    );

Map<String, dynamic> _$PurchaseResponseToJson(PurchaseResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

PurchaseReceipt _$PurchaseReceiptFromJson(Map<String, dynamic> json) =>
    PurchaseReceipt(
      json['sku'] as String?,
      json['termSku'] as String?,
      json['receiptId'] as String?,
      json['itemType'] as String?,
      json['purchaseDate'] as String?,
    );

Map<String, dynamic> _$PurchaseReceiptToJson(PurchaseReceipt instance) =>
    <String, dynamic>{
      'sku': instance.sku,
      'termSku': instance.termSku,
      'receiptId': instance.receiptId,
      'itemType': instance.itemType,
      'purchaseDate': instance.purchaseDate,
    };
