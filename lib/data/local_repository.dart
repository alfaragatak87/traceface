// ╔══════════════════════════════════════════════════════════════╗
// ║  lib/data/local_repository.dart                              ║
// ║                                                              ║
// ║  PERAN : Lapisan data utama — menyimpan semua data kasus    ║
// ║          ke SQLite lokal (menggantikan Firestore).          ║
// ║                                                              ║
// ║  DATABASE : traceface.db (via DatabaseHelper)               ║
// ║  TABEL    : missing_cases                                    ║
// ║                                                              ║
// ║  PERBEDAAN DENGAN FIRESTORE :                               ║
// ║    • Data hanya ada di HP ini (tidak sinkron ke HP lain)    ║
// ║    • Tidak ada Stream realtime — pakai Future + refresh     ║
// ║    • Foto disimpan di internal storage, bukan cloud         ║
// ║                                                              ║
// ║  DIPAKAI OLEH :                                              ║
// ║    home_page.dart   → getStats(), getRecentCases()         ║
// ║    scan_page.dart   → searchByName()                        ║
// ║    report_page.dart → addCase()                             ║
// ║    cases_page.dart  → getAllCases(), updateStatus()         ║
// ╚══════════════════════════════════════════════════════════════╝

import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/missing_person.dart';

import '../models/missing_person.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'database_helper.dart';

class LocalRepository {
  // Singleton
  static final LocalRepository instance = LocalRepository._();
  LocalRepository._();

  final _storage = StorageService.instance;
  final _notif   = NotificationService.instance;

  // ══════════════════════════════════════════════════════════
  //  READ — Query data dari SQLite
  // ══════════════════════════════════════════════════════════

  // Ambil semua kasus, diurutkan terbaru
  Future<List<MissingPerson>> getAllCases() async {
    final db   = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'missing_cases',
      orderBy: 'reported_at DESC',
    );
    return rows.map(MissingPerson.fromMap).toList();
  }

  // Ambil N kasus terbaru — untuk halaman Beranda
  Future<List<MissingPerson>> getRecentCases({int limit = 3}) async {
    final db   = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'missing_cases',
      orderBy: 'reported_at DESC',
      limit:   limit,
    );
    return rows.map(MissingPerson.fromMap).toList();
  }

  // Statistik ringkas untuk dashboard
  Future<Map<String, int>> getStats() async {
    final db   = await DatabaseHelper.instance.database;
    final rows = await db.query('missing_cases');

    int total = rows.length, aktif = 0, selesai = 0, proses = 0;
    for (final r in rows) {
      final s = r['status'] as String? ?? '';
      if (s == 'belum_ditemukan')    aktif++;
      if (s == 'ditemukan')          selesai++;
      if (s == 'dalam_penyelidikan') proses++;
    }
    return {
      'total':   total,
      'aktif':   aktif,
      'selesai': selesai,
      'proses':  proses,
    };
  }

  // Cari kasus berdasarkan nama (case-insensitive, partial match)
  Future<List<MissingPerson>> searchByName(String query) async {
    if (query.trim().isEmpty) return [];

    final db  = await DatabaseHelper.instance.database;
    final q   = '%${query.trim().toLowerCase()}%';
    final rows = await db.query(
      'missing_cases',
      where:    'name_lower LIKE ?',
      whereArgs: [q],
      orderBy:  'reported_at DESC',
    );
    return rows.map(MissingPerson.fromMap).toList();
  }

  // ══════════════════════════════════════════════════════════
  //  WRITE — Tambah, update, hapus kasus
  // ══════════════════════════════════════════════════════════

  // ── TAMBAH KASUS BARU ─────────────────────────────────────
  // Alur:
  //   1. Hitung nomor kasus (TF-XXXX)
  //   2. Salin foto ke internal storage (jika ada)
  //   3. INSERT ke SQLite
  //   4. Kirim notifikasi lokal
  Future<MissingPerson> addCase({
    required String  name,
    int?             age,
    required String  gender,
    required String  lastSeen,
    required String  contact,
    String?          description,
    File?            photoFile,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // 1. Hitung nomor kasus berurutan
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM missing_cases',
    );
    final count  = Sqflite.firstIntValue(countResult) ?? 0;
    final caseNum = count + 1;
    final caseId  = 'TF-${caseNum.toString().padLeft(4, '0')}';

    // 2. Salin foto ke internal storage (jika dipilih)
    String? photoPath;
    if (photoFile != null) {
      photoPath = await _storage.savePhotoLocally(photoFile, caseId);
    }

    // 3. Buat objek kasus
    final person = MissingPerson(
      caseId:      caseId,
      name:        name.trim(),
      age:         age,
      gender:      gender,
      lastSeen:    lastSeen.trim(),
      contact:     contact.trim(),
      reportedAt:  DateTime.now(),
      status:      CaseStatus.belumDitemukan,
      description: description?.trim(),
      photoUrl:    photoPath,
    );

    // 4. INSERT ke SQLite
    await db.insert(
      'missing_cases',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 5. Kirim notifikasi lokal
    await _notif.showReportCreatedNotification(
      caseId: caseId,
      name:   name.trim(),
    );

    return person;
  }

  // ── UPDATE STATUS KASUS ──────────────────────────────────
  Future<void> updateStatus(int id, CaseStatus status) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'missing_cases',
      {
        'status':     _statusToString(status),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where:     'id = ?',
      whereArgs: [id],
    );

    // Kirim notifikasi lokal jika status jadi "Ditemukan"
    if (status == CaseStatus.ditemukan) {
      final rows = await db.query(
        'missing_cases',
        where:     'id = ?',
        whereArgs: [id],
        limit:     1,
      );
      if (rows.isNotEmpty) {
        final person = MissingPerson.fromMap(rows.first);
        await _notif.showFoundNotification(
          personName: person.name,
          caseId:     person.caseId,
          location:   person.lastSeen,
        );
      }
    }
  }

  // ── HAPUS KASUS ───────────────────────────────────────────
  Future<void> deleteCase(int id, String caseId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'missing_cases',
      where:     'id = ?',
      whereArgs: [id],
    );
    // Hapus foto dari internal storage
    await _storage.deletePhotoLocally(caseId);
  }

  // ══════════════════════════════════════════════════════════
  //  AKUN PETUGAS (ADMIN)
  // ══════════════════════════════════════════════════════════

  /// Membuat akun admin bawaan jika tabel users masih kosong
  Future<void> checkAndCreateDefaultAdmin() async {
    final db = await DatabaseHelper.instance.database;
    final countResult = await db.rawQuery('SELECT COUNT(*) as cnt FROM users');
    final count = Sqflite.firstIntValue(countResult) ?? 0;
    
    if (count == 0) {
      // Buat password dengan hash SHA-256 sederhana
      final passBytes = utf8.encode('admin123');
      final passHash  = sha256.convert(passBytes).toString();

      await db.insert('users', {
        'name': 'Administrator',
        'email': 'admin@traceface.com',
        'password': passHash,
        'role': 'admin',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      print("✅ Akun default dibuat: admin@traceface.com / admin123");
    }
  }

  /// Login petugas
  Future<Map<String, dynamic>?> loginAdmin(String email, String password) async {
    final db = await DatabaseHelper.instance.database;
    final passBytes = utf8.encode(password);
    final passHash  = sha256.convert(passBytes).toString();

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, passHash],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null; // Email/Password salah
  }
}

String _statusToString(CaseStatus s) {
  switch (s) {
    case CaseStatus.ditemukan:         return 'ditemukan';
    case CaseStatus.dalamPenyelidikan: return 'dalam_penyelidikan';
    case CaseStatus.belumDitemukan:    return 'belum_ditemukan';
  }
}
