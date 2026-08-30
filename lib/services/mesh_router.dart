import '../models/mesh_message.dart';
import '../models/peer.dart';
import 'duplicate_cache.dart';

class MeshRouter {
  final DuplicateCache duplicates;
  final Map<String, Peer> _peers = {};

  MeshRouter(this.duplicates);

  List<Peer> get peers => _peers.values.toList();

  void upsert(Peer peer) => _peers[peer.nodeId] = peer;

  Peer? chooseNextHop(String targetId) {
    final direct = _peers[targetId];
    if (direct != null && direct.state == PeerState.connected) return direct;

    final candidates = _peers.values
        .where((p) => p.state == PeerState.connected)
        .toList()
      ..sort((a, b) {
        final c = a.cost.compareTo(b.cost);
        return c == 0 ? b.rssi.compareTo(a.rssi) : c;
      });

    return candidates.isEmpty ? null : candidates.first;
  }

  MeshMessage? accept(MeshMessage m, String localNodeId) {
    if (!duplicates.firstSeen(m.id)) return null;
    if (m.targetId == localNodeId) return null;
    if (m.ttl <= 0) return null;
    return m.forward();
  }
}
