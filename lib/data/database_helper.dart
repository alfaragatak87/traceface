// ╔══════════════════════════════════════════════════════════════╗
// ║  lib/data/database_helper.dart                               ║
// ║                                                              ║
// ║  PERAN : Singleton SQLite manager.                          ║
// ║          Membuat, membuka, dan mengelola database lokal.    ║
// ║                                                              ║
// ║  DATABASE : traceface.db                                     ║
// ║  TABEL :                                                     ║
// ║    missing_cases → data kasus orang hilang                  ║
// ║    users         → akun petugas                             ║
// ║                                                              ║
// ║  DIPAKAI OLEH :                                              ║
// ║    lib/data/local_repository.dart                           ║
// ║    lib/services/auth_service.dart                           ║
// ╚══════════════════════════════════════════════════════════════╝

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton — satu instance di seluruh app
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  static Database? _database;

  // Versi database — naikkan jika ada perubahan skema
  static const int _version = 1;
  static const String _dbName = 'traceface.db';

  // ── GETTER DATABASE ────────────────────────────────────────
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // ── INISIALISASI DATABASE ──────────────────────────────────
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate:  _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ── BUAT TABEL SAAT PERTAMA KALI ──────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    // Tabel kasus orang hilang
    await db.execute('''
      CREATE TABLE missing_cases (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        case_id      TEXT    NOT NULL UNIQUE,
        name         TEXT    NOT NULL,
        name_lower   TEXT    NOT NULL,
        age          INTEGER,
        gender       TEXT    NOT NULL,
        last_seen    TEXT    NOT NULL,
        contact      TEXT    NOT NULL DEFAULT '',
        reported_at  INTEGER NOT NULL,
        status       TEXT    NOT NULL DEFAULT 'belum_ditemukan',
        description  TEXT,
        photo_url    TEXT,
        reported_by  TEXT,
        reporter_name TEXT,
        updated_at   INTEGER
      )
    ''');

    // Index untuk pencarian nama yang lebih cepat
    await db.execute('''
      CREATE INDEX idx_name_lower ON missing_cases (name_lower)
    ''');

    // Index untuk sorting berdasarkan tanggal
    await db.execute('''
      CREATE INDEX idx_reported_at ON missing_cases (reported_at DESC)
    ''');

    // Tabel pengguna (akun petugas)
    await db.execute('''
      CREATE TABLE users (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT    NOT NULL,
        email      TEXT    NOT NULL UNIQUE,
        password   TEXT    NOT NULL,
        phone      TEXT    NOT NULL DEFAULT '',
        role       TEXT    NOT NULL DEFAULT 'petugas',
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // ── UPGRADE SKEMA (jika ada perubahan di versi baru) ──────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Untuk versi mendatang: tambahkan ALTER TABLE di sini
    // Contoh: if (oldVersion < 2) { await db.execute("ALTER TABLE ..."); }
  }

  // ── CLOSE DATABASE ─────────────────────────────────────────
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
