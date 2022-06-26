// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AmazonUserData _$AmazonUserDataFromJson(Map<String, dynamic> json) =>
    AmazonUserData(
      json['marketplace'] as String?,
      json['userId'] as String?,
      json['status'] as String?,
    );

Map<String, dynamic> _$AmazonUserDataToJson(AmazonUserData instance) =>
    <String, dynamic>{
      'marketplace': instance.marketplace,
      'userId': instance.userId,
      'status': instance.status,
    };
