// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/services/notification_service.dart                                ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Modul pemicu notifikasi *Push/Tray* sistem Android lokal. Jika Firebase     ║
// ║  Cloud Messaging (FCM) menggunakan sinyal internet, modul ini memanggil      ║
// ║  NotificationManager API murni dari sisi sistem operasi Android itu sendiri. ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Diinisialisasi di awal pembukaan aplikasi (`main.dart`).                  ║
// ║  - Dipanggil saat penambahan kasus baru atau peringatan spesifik lainnya.    ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `showLocalNotification()` : Merender blok kotak notifikasi *heads-up*     ║
// ║    berisi judul dan isi pesan ke HP pengguna.                                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart' show Color;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _localNotif = FlutterLocalNotificationsPlugin();

  // ── INISIALISASI (dipanggil di main.dart) ─────────────────
  Future<void> initialize() async {
    // 1. Setup notifikasi lokal
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings     = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS:     iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 2. Buat channel notifikasi (Android 8+)
    await _localNotif
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'traceface_channel',
        'TraceFace Notifikasi',
        description: 'Notifikasi pembaruan kasus orang hilang',
        importance:  Importance.high,
      ),
    );
    
    // Minta izin notifikasi untuk Android 13+
    await _localNotif
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ── KIRIM NOTIFIKASI LOKAL ────────────────────
  Future<void> showFoundNotification({
    required String personName,
    required String caseId,
    required String location,
  }) async {
    await _localNotif.show(
      caseId.hashCode,
      '🟢 Data Ditemukan!',
      '$personName terdeteksi di sekitar $location',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'traceface_channel',
          'TraceFace Notifikasi',
          channelDescription: 'Notifikasi pembaruan kasus orang hilang',
          importance:   Importance.high,
          priority:     Priority.high,
          icon:         '@mipmap/ic_launcher',
          color:        Color(0xFF16A34A), // Hijau
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      payload: caseId,
    );
  }

  Future<void> showReportCreatedNotification({
    required String caseId,
    required String name,
  }) async {
    await _localNotif.show(
      caseId.hashCode + 1,
      '📋 Laporan Tersimpan',
      'Laporan $name ($caseId) berhasil masuk ke database lokal.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'traceface_channel',
          'TraceFace Notifikasi',
          importance: Importance.defaultImportance,
          icon:       '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Di sini bisa navigasi ke halaman detail kasus
  }
}