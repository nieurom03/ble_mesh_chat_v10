enum MessageType { chat, ack }

enum MessageState { queued, sent, delivered, failed }

class MeshMessage {
  final String id;
  final String sourceId;
  final String targetId;
  final String ciphertext;
  final String nonce;
  final String tag;
  final String sha256;
  final int ttl;
  final int hop;
  final int timestamp;
  final MessageType type;
  final MessageState state;
  final String? ackFor;

  const MeshMessage({
    required this.id,
    required this.sourceId,
    required this.targetId,
    required this.ciphertext,
    required this.nonce,
    required this.tag,
    required this.sha256,
    required this.ttl,
    required this.hop,
    required this.timestamp,
    required this.type,
    this.state = MessageState.queued,
    this.ackFor,
  });

  MeshMessage forward() => MeshMessage(
        id: id,
        sourceId: sourceId,
        targetId: targetId,
        ciphertext: ciphertext,
        nonce: nonce,
        tag: tag,
        sha256: sha256,
        ttl: ttl - 1,
        hop: hop + 1,
        timestamp: timestamp,
        type: type,
        state: state,
        ackFor: ackFor,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'targetId': targetId,
        'ciphertext': ciphertext,
        'nonce': nonce,
        'tag': tag,
        'sha256': sha256,
        'ttl': ttl,
        'hop': hop,
        'timestamp': timestamp,
        'type': type.name,
        'state': state.name,
        'ackFor': ackFor,
      };

  factory MeshMessage.fromJson(Map<String, dynamic> j) => MeshMessage(
        id: j['id'],
        sourceId: j['sourceId'],
        targetId: j['targetId'],
        ciphertext: j['ciphertext'],
        nonce: j['nonce'],
        tag: j['tag'],
        sha256: j['sha256'],
        ttl: (j['ttl'] as num).toInt(),
        hop: (j['hop'] as num).toInt(),
        timestamp: (j['timestamp'] as num).toInt(),
        type: j['type'] == 'ack' ? MessageType.ack : MessageType.chat,
        state: MessageState.values.firstWhere(
          (x) => x.name == j['state'],
          orElse: () => MessageState.queued,
        ),
        ackFor: j['ackFor'],
      );
}
