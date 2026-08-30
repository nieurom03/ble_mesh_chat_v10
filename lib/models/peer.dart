enum PeerState { discovered, connecting, connected, disconnected }

class Peer {
  final String nodeId;
  final String transportId;
  final int rssi;
  final int cost;
  final DateTime lastSeen;
  final PeerState state;

  const Peer({
    required this.nodeId,
    required this.transportId,
    required this.rssi,
    required this.cost,
    required this.lastSeen,
    required this.state,
  });

  Peer copyWith({
    int? rssi,
    int? cost,
    DateTime? lastSeen,
    PeerState? state,
  }) =>
      Peer(
        nodeId: nodeId,
        transportId: transportId,
        rssi: rssi ?? this.rssi,
        cost: cost ?? this.cost,
        lastSeen: lastSeen ?? this.lastSeen,
        state: state ?? this.state,
      );
}
