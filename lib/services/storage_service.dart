// ╔══════════════════════════════════════════════════════════════╗
// ║  lib/services/storage_service.dart                           ║
// ║                                                              ║
// ║  PERAN : Menyimpan foto ke internal storage HP.              ║
// ║          Menggantikan Firebase Storage.                      ║
// ║                                                              ║
// ║  PATH LOKAL :                                                ║
// ║    /data/user/0/.../cases/{caseId}/photo.jpg                 ║
// ╚══════════════════════════════════════════════════════════════╝

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  // ── SIMPAN FOTO LOKAL ──────────────────────────────────────
  // [imageFile] : File foto yang dipilih dari kamera/galeri
  // [caseId]    : ID kasus, dipakai sebagai nama folder
  // Returns     : Absolute path ke file foto yang tersimpan
  Future<String?> savePhotoLocally(File imageFile, String caseId) async {
    try {
      // Dapatkan direktori internal aplikasi
      final dir = await getApplicationDocumentsDirectory();
      
      // Buat folder cases/{caseId}
      final caseDir = Directory('${dir.path}/cases/$caseId');
      if (!await caseDir.exists()) {
        await caseDir.create(recursive: true);
      }

      // Tentukan path tujuan file
      // Kita pakai nama photo.jpg agar konsisten, 
      // meski mungkin format asli png/jpeg.
      final outPath = '${caseDir.path}/photo.jpg';

      // Salin file ke internal storage
      final savedImage = await imageFile.copy(outPath);
      
      return savedImage.path;
    } catch (e) {
      // Jika gagal simpan, kembalikan null
      return null;
    }
  }

  // ── HAPUS FOTO LOKAL ───────────────────────────────────────
  // Hapus foto saat kasus dihapus
  Future<void> deletePhotoLocally(String caseId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final caseDir = Directory('${dir.path}/cases/$caseId');
      
      if (await caseDir.exists()) {
        await caseDir.delete(recursive: true); // Hapus folder beserta isinya
      }
    } catch (_) {
      // Abaikan error jika folder/file tidak ada
    }
  }
}
