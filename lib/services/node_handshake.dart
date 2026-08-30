import 'dart:convert';

class NodeHandshake {
  static const protocol = 'BLE-MESH-1';
  static const version = 7;

  final String nodeId;

  const NodeHandshake(this.nodeId);

  Map<String, dynamic> toJson() => {
    'kind': 'hello',
    'protocol': protocol,
    'version': version,
    'nodeId': nodeId,
  };

  List<int> encode() => utf8.encode(jsonEncode(toJson()));

  static String? parseNodeId(List<int> bytes) {
    try {
      final j = jsonDecode(utf8.decode(bytes));
      if (j['kind'] != 'hello') return null;
      if (j['protocol'] != protocol) return null;
      if ((j['version'] as num?)?.toInt() != version) return null;
      final id = j['nodeId'];
      return id is String && id.isNotEmpty ? id : null;
    } catch (_) {
      return null;
    }
  }
}
