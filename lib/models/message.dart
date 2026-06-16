// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/models/message.dart                                               ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  File ini mendefinisikan struktur objek "Pesan / Laporan Penemuan". Pesan    ║
// ║  ini dikirimkan oleh pengguna publik saat mereka menemukan kecocokan wajah   ║
// ║  di layar pemindaian (Scan), dan diterima oleh Admin di dasbornya.           ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Di-insert ke DB lewat `local_repository.dart` -> `sendMessage()`.         ║
// ║  - Di-fetch oleh `admin_messages_page.dart` untuk dirender menjadi list UI.  ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `isRead` : Bendera (flag) logika untuk membedakan pesan baru/lama.        ║
// ║  - `DateTime` : Waktu spesifik kejadian yang akan dikoversi ke integer       ║
// ║                 saat masuk SQLite (`millisecondsSinceEpoch`).                ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

/// Class Message membungkus seluruh data yang dikirimkan melalui form pelaporan.
class Message {
  // ID baris di SQLite (Bisa null jika data baru dibuat dan belum di-insert)
  final int? id;
  // Merujuk pada kasus mana (MissingPerson.caseId) pesan ini tertuju
  final String caseId;
  // Nama sang pelapor/penemu
  final String userName;
  // Nomor HP atau kontak sang pelapor
  final String contactInfo;
  // Isi pesan, detail lokasi penemuan, dsb.
  final String textMessage;
  // Waktu pesan dikirim
  final DateTime createdAt;
  // Status apakah pesan ini sudah dibaca oleh admin/petugas
  final bool isRead;

  /// Konstruktor dasar untuk pembentukan objek Message
  Message({
    this.id,
    required this.caseId,
    required this.userName,
    required this.contactInfo,
    required this.textMessage,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'case_id': caseId,
      'user_name': userName,
      'contact_info': contactInfo,
      'text_message': textMessage,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      caseId: map['case_id'],
      userName: map['user_name'],
      contactInfo: map['contact_info'],
      textMessage: map['text_message'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isRead: map['is_read'] == 1,
    );
  }
}
