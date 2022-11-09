import 'package:json_annotation/json_annotation.dart';

import 'utils.dart';

part 'product.g.dart';

@JsonSerializable()
class AmazonSkusData {
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'data')
  final Map<String, SkuData>? data;

  const AmazonSkusData(
    this.status,
    this.data,
  );

  factory AmazonSkusData.fromJson(dynamic json) =>
      _$AmazonSkusDataFromJson(fromMapMethodChannelJson(json));

  Map<String, dynamic> toJson() => _$AmazonSkusDataToJson(this);
}

@JsonSerializable()
class SkuData {
  @JsonKey(name: 'productType')
  final String? productType;
  @JsonKey(name: 'coinsRewardAmount')
  final num? coinsRewardAmount;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'sku')
  final String? sku;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'subscriptionPeriod')
  final String? subscriptionPeriod;
  @JsonKey(name: 'smallIconUrl')
  final String? smallIconUrl;

  const SkuData(
    this.productType,
    this.coinsRewardAmount,
    this.price,
    this.title,
    this.sku,
    this.description,
    this.subscriptionPeriod,
    this.smallIconUrl,
  );

  factory SkuData.fromJson(dynamic json) =>
      _$SkuDataFromJson(fromMapMethodChannelJson(json));

  Map<String, dynamic> toJson() => _$SkuDataToJson(this);
}

@JsonSerializable()
class PurchaseHistoryData {
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'data')
  final List<PurchaseHistory>? data;

  const PurchaseHistoryData(
    this.status,
    this.data,
  );

  factory PurchaseHistoryData.fromJson(dynamic json) =>
      _$PurchaseHistoryDataFromJson(fromMapMethodChannelJson(json));

  Map<String, dynamic> toJson() => _$PurchaseHistoryDataToJson(this);
}

@JsonSerializable()
class PurchaseHistory {
  @JsonKey(name: 'sku')
  final String? sku;
  @JsonKey(name: 'termSku')
  final String? termSku;
  @JsonKey(name: 'receiptId')
  final String? receiptId;
  @JsonKey(name: 'itemType')
  final String? itemType;
  @JsonKey(name: 'purchaseDate')
  final String? purchaseDate;

  const PurchaseHistory(
    this.sku,
    this.termSku,
    this.receiptId,
    this.itemType,
    this.purchaseDate,
  );

  factory PurchaseHistory.fromJson(dynamic json) =>
      _$PurchaseHistoryFromJson(fromMapMethodChannelJson(json));

  Map<String, dynamic> toJson() => _$PurchaseHistoryToJson(this);
}

@JsonSerializable()
class PurchaseResponse {
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'data')
  final PurchaseReceipt? data;

  const PurchaseResponse(
    this.status,
    this.data,
  );

  factory PurchaseResponse.fromJson(dynamic json) =>
      _$PurchaseResponseFromJson(fromMapMethodChannelJson(json));

  Map<String, dynamic> toJson() => _$PurchaseResponseToJson(this);
}

@JsonSerializable()
class PurchaseReceipt {
  @JsonKey(name: 'sku')
  final String? sku;
  @JsonKey(name: 'termSku')
  final String? termSku;
  @JsonKey(name: 'receiptId')
  final String? receiptId;
  @JsonKey(name: 'itemType')
  final String? itemType;
  @JsonKey(name: 'purchaseDate')
  final String? purchaseDate;

  const PurchaseReceipt(
    this.sku,
    this.termSku,
    this.receiptId,
    this.itemType,
    this.purchaseDate,
  );

  factory PurchaseReceipt.fromJson(dynamic json) =>
      _$PurchaseReceiptFromJson(fromMapMethodChannelJson(json));

  Map<String, dynamic> toJson() => _$PurchaseReceiptToJson(this);
}
