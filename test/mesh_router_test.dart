import 'package:flutter_test/flutter_test.dart';
import 'package:ble_mesh_chat/models/mesh_message.dart';
import 'package:ble_mesh_chat/models/peer.dart';
import 'package:ble_mesh_chat/services/duplicate_cache.dart';
import 'package:ble_mesh_chat/services/mesh_router.dart';

void main() {
  test('TTL and hop change during forwarding', () {
    final router = MeshRouter(DuplicateCache());
    final m = MeshMessage(
      id: 'm',
      sourceId: 'A',
      targetId: 'D',
      ciphertext: 'x',
      nonce: 'n',
      tag: 't',
      sha256: 's',
      ttl: 5,
      hop: 0,
      timestamp: 0,
      type: MessageType.chat,
    );

    final f = router.accept(m, 'B');
    expect(f!.ttl, 4);
    expect(f.hop, 1);
  });

  test('duplicate is dropped', () {
    final router = MeshRouter(DuplicateCache());
    final m = MeshMessage(
      id: 'same',
      sourceId: 'A',
      targetId: 'D',
      ciphertext: 'x',
      nonce: 'n',
      tag: 't',
      sha256: 's',
      ttl: 5,
      hop: 0,
      timestamp: 0,
      type: MessageType.chat,
    );

    expect(router.accept(m, 'B'), isNotNull);
    expect(router.accept(m, 'B'), isNull);
  });

  test('direct target has priority', () {
    final router = MeshRouter(DuplicateCache());
    router.upsert(Peer(
      nodeId: 'C',
      transportId: 'C',
      rssi: -70,
      cost: 80,
      lastSeen: DateTime.now(),
      state: PeerState.connected,
    ));
    router.upsert(Peer(
      nodeId: 'D',
      transportId: 'D',
      rssi: -55,
      cost: 20,
      lastSeen: DateTime.now(),
      state: PeerState.connected,
    ));

    expect(router.chooseNextHop('D')!.nodeId, 'D');
  });
}
