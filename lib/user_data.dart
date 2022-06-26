import 'package:json_annotation/json_annotation.dart';

part 'user_data.g.dart';

@JsonSerializable()
class AmazonUserData {
  final String? marketplace;
  final String? userId;
  final String? status;

  const AmazonUserData(this.marketplace, this.userId, this.status);

  factory AmazonUserData.fromJson(dynamic data) {
    final Map<Object?, Object?> value = data;
    final json = <String, dynamic>{};
    for (var i = 0; i < value.length; i++) {
      final k = value.entries.elementAt(i).key;
      json[k?.toString() ?? ''] = value.entries.elementAt(i).value;
    }
    return _$AmazonUserDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AmazonUserDataToJson(this);

  @override
  String toString() {
    return 'AmazonUserData{marketplace: $marketplace, userId: $userId, status: $status}';
  }
}
