import 'package:json_annotation/json_annotation.dart';

import 'utils.dart';

part 'user_data.g.dart';

@JsonSerializable()
class AmazonUserData {
  final String? marketplace;
  final String? userId;
  final String? status;

  const AmazonUserData(this.marketplace, this.userId, this.status);

  factory AmazonUserData.fromJson(dynamic data) {
    return _$AmazonUserDataFromJson(fromMapMethodChannelJson(data));
  }

  Map<String, dynamic> toJson() => _$AmazonUserDataToJson(this);

  @override
  String toString() {
    return 'AmazonUserData{marketplace: $marketplace, userId: $userId, status: $status}';
  }
}
