// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/services/local_auth_service.dart                                  ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Layanan (Service) yang mengurus sesi login dan status autentikasi Admin.    ║
// ║  Memastikan aplikasi "ingat" bahwa pengguna masih dalam keadaan login        ║
// ║  tanpa harus query ke database SQLite secara terus-menerus.                  ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Menggunakan package `shared_preferences`.                                 ║
// ║  - Dicek secara otomatis di `splash_page.dart` saat aplikasi baru dibuka.    ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `login()` : Menyimpan key 'is_logged_in' ke dalam *cache* lokal memori.   ║
// ║  - `logout()` : Menghapus *cache* sesi saat Admin menekan tombol keluar.     ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  LocalAuthService._();
  static final LocalAuthService instance = LocalAuthService._();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserName   = 'user_name';

  Future<void> login(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserName, name);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserName);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }
}
