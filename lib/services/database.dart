import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._();
  AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'ble_mesh_chat.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages(
            id TEXT PRIMARY KEY,
            source_id TEXT NOT NULL,
            target_id TEXT NOT NULL,
            ciphertext TEXT NOT NULL,
            nonce TEXT NOT NULL,
            tag TEXT NOT NULL,
            sha256 TEXT NOT NULL,
            ttl INTEGER NOT NULL,
            hop INTEGER NOT NULL,
            timestamp INTEGER NOT NULL,
            type TEXT NOT NULL,
            state TEXT NOT NULL,
            ack_for TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE outbox(
            id TEXT PRIMARY KEY,
            attempts INTEGER NOT NULL DEFAULT 0,
            next_retry INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE peers(
            node_id TEXT PRIMARY KEY,
            transport_id TEXT NOT NULL,
            rssi INTEGER NOT NULL,
            cost INTEGER NOT NULL,
            last_seen INTEGER NOT NULL,
            state TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }
}
