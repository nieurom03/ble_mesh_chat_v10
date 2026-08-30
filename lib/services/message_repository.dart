import 'package:sqflite/sqflite.dart';

import '../models/mesh_message.dart';
import 'database.dart';

class MessageRepository {
  Future<void> saveMessage(MeshMessage m) async {
    final db = await AppDatabase.instance.db;
    await db.insert(
      'messages',
      {
        'id': m.id,
        'source_id': m.sourceId,
        'target_id': m.targetId,
        'ciphertext': m.ciphertext,
        'nonce': m.nonce,
        'tag': m.tag,
        'sha256': m.sha256,
        'ttl': m.ttl,
        'hop': m.hop,
        'timestamp': m.timestamp,
        'type': m.type.name,
        'state': m.state.name,
        'ack_for': m.ackFor,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setState(String id, MessageState state) async {
    final db = await AppDatabase.instance.db;
    await db.update(
      'messages',
      {'state': state.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MeshMessage>> pending() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query(
      'messages',
      where: 'state IN (?, ?)',
      whereArgs: ['queued', 'sent'],
      orderBy: 'timestamp ASC',
    );

    return rows.map((r) => MeshMessage.fromJson({
      'id': r['id'],
      'sourceId': r['source_id'],
      'targetId': r['target_id'],
      'ciphertext': r['ciphertext'],
      'nonce': r['nonce'],
      'tag': r['tag'],
      'sha256': r['sha256'],
      'ttl': r['ttl'],
      'hop': r['hop'],
      'timestamp': r['timestamp'],
      'type': r['type'],
      'state': r['state'],
      'ackFor': r['ack_for'],
    })).toList();
  }
}
