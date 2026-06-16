// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/data/database_helper.dart                                         ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Merupakan nyawa utama penyimpanan internal aplikasi. Bertindak sebagai      ║
// ║  "Singleton SQLite Manager" yang bertanggung jawab membuat (CREATE),         ║
// ║  membuka, dan mengatur versi skema dari database lokal `traceface.db`.       ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Hanya dipanggil oleh `local_repository.dart` sebagai layer abstraksi      ║
// ║    sebelum mengeksekusi query.                                               ║
// ║  - Diinisialisasi pertama kali di `main.dart` agar database siap dipakai.    ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `_version` : Naikkan angka ini jika ada perubahan struktur tabel baru.    ║
// ║  - `_onCreate`: Skrip DDL untuk instalasi fresh (Tabel: missing_cases,       ║
// ║                 users, dan messages).                                        ║
// ║  - `_onUpgrade`: Skrip DDL untuk pengguna lama saat update aplikasi.         ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton — satu instance di seluruh app
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  static Database? _database;

  // Versi database — naikkan jika ada perubahan skema
  static const int _version = 2;
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

  // ── TABEL ──────────────────────────
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

    // Tabel pesan / laporan masuk
    await db.execute('''
      CREATE TABLE messages (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        case_id      TEXT    NOT NULL,
        user_name    TEXT    NOT NULL,
        contact_info TEXT    NOT NULL,
        text_message TEXT    NOT NULL,
        created_at   INTEGER NOT NULL,
        is_read      INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ── UPGRADE SKEMA (jika ada perubahan di versi baru) ──────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE messages (
          id           INTEGER PRIMARY KEY AUTOINCREMENT,
          case_id      TEXT    NOT NULL,
          user_name    TEXT    NOT NULL,
          contact_info TEXT    NOT NULL,
          text_message TEXT    NOT NULL,
          created_at   INTEGER NOT NULL,
          is_read      INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
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
