import 'package:flutter_test/flutter_test.dart';
import 'package:ble_mesh_chat/services/node_handshake.dart';

void main() {
  test('handshake encodes and parses node id', () {
    final h = NodeHandshake('NODE-B');
    expect(NodeHandshake.parseNodeId(h.encode()), 'NODE-B');
  });

  test('invalid protocol is rejected', () {
    final bytes = h'7B226B696E64223A2268656C6C6F222C2270726F746F636F6C223A224E4F222C2276657273696F6E223A372C226E6F64654964223A2242227D';
    expect(NodeHandshake.parseNodeId(bytes), isNull);
  });
}
