List<Object?> fromListMethodChannelJson(dynamic data) {
  return data;
}

Map<String, dynamic> fromMapMethodChannelJson(dynamic data) {
  final Map<Object?, Object?> value = data;
  final json = <String, dynamic>{};
  for (final kv in value.entries) {
    final k = kv.key?.toString() ?? '';
    // ignore: prefer_typing_uninitialized_variables
    var v;
    v = kv.value;
    if (v is Map) {
      v = fromMapMethodChannelJson(v);
    } else if (v is List) {
      v = fromListMethodChannelJson(v);
    }
    json[k] = v;
  }
  return json;
}
