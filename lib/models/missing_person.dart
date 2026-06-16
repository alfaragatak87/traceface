// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/models/missing_person.dart                                        ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  File ini adalah "Model Blueprint" yang merepresentasikan entitas (data)     ║
// ║  satu kasus orang hilang. Kelas ini menjadi jembatan transformasi data       ║
// ║  dari UI (aplikasi) menuju ke Database SQLite, dan sebaliknya.               ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Terhubung ke `local_repository.dart` untuk operasi CRUD database.         ║
// ║  - Terhubung ke `cases_page.dart` untuk merender tampilan daftar kasus.      ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `toMap()` : Mengubah objek Dart menjadi format Map/JSON untuk disuntikkan ║
// ║                langsung ke baris tabel SQLite.                               ║
// ║  - `fromMap()` : Mengubah baris hasil query SQLite menjadi objek Dart yang   ║
// ║                  bisa dibaca dan ditampilkan oleh Flutter.                   ║
// ║                                                                              ║
// ║  CATATAN TEKNOLOGI (NYAWA ANDROID):                                          ║
// ║  Variabel `photoUrl` di sini TIDAK berisi URL web, melainkan merepresentasikan║
// ║  path (jalur direktori absolut) menuju penyimpanan internal perangkat Android.║
// ╚══════════════════════════════════════════════════════════════════════════════╝

enum CaseStatus {
  belumDitemukan,
  ditemukan,
  dalamPenyelidikan,
}

class MissingPerson {
  // ID row SQLite (null sebelum disimpan)
  final int?        id;
  // ID tampilan: "TF-0001"
  final String      caseId;
  final String      name;
  final int?        age;
  final String      gender;
  final String      lastSeen;
  final String      contact;
  final DateTime    reportedAt;
  final CaseStatus  status;
  final String?     description;
  // Path file foto lokal (null jika tidak ada foto)
  final String?     photoUrl;
  // Nama pelapor (dari sesi login lokal)
  final String?     reportedBy;
  final String?     reporterName;

  const MissingPerson({
    this.id,
    required this.caseId,
    required this.name,
    this.age,
    required this.gender,
    required this.lastSeen,
    required this.contact,
    required this.reportedAt,
    this.status = CaseStatus.belumDitemukan,
    this.description,
    this.photoUrl,
    this.reportedBy,
    this.reporterName,
  });

  // ── HELPER GETTER ─────────────────────────────────────────

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get formattedDate {
    const months = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agu','Sep','Okt','Nov','Des',
    ];
    return '${reportedAt.day} ${months[reportedAt.month - 1]} ${reportedAt.year}';
  }

  String get statusLabel {
    switch (status) {
      case CaseStatus.ditemukan:          return 'Ditemukan';
      case CaseStatus.dalamPenyelidikan:  return 'Penyelidikan';
      case CaseStatus.belumDitemukan:     return 'Belum Ditemukan';
    }
  }

  // hasPhoto: cek apakah ada path foto lokal
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  // ── KONVERSI UNTUK SQLite ─────────────────────────────────
  // toMap()   → Map untuk SQLite INSERT/UPDATE
  // fromMap() → MissingPerson dari SQLite row

  Map<String, dynamic> toMap() {
    return {
      'case_id':       caseId,
      'name':          name,
      'name_lower':    name.toLowerCase(),    // untuk pencarian LIKE
      'age':           age,
      'gender':        gender,
      'last_seen':     lastSeen,
      'contact':       contact,
      'reported_at':   reportedAt.millisecondsSinceEpoch,
      'status':        _statusToString(status),
      'description':   description,
      'photo_url':     photoUrl,              // path file lokal
      'reported_by':   reportedBy,
      'reporter_name': reporterName,
    };
  }

  factory MissingPerson.fromMap(Map<String, dynamic> data) {
    return MissingPerson(
      id:           data['id']            as int?,
      caseId:       data['case_id']       as String? ?? '',
      name:         data['name']          as String? ?? '',
      age:          data['age']           as int?,
      gender:       data['gender']        as String? ?? '',
      lastSeen:     data['last_seen']     as String? ?? '',
      contact:      data['contact']       as String? ?? '',
      reportedAt:   DateTime.fromMillisecondsSinceEpoch(
                      data['reported_at'] as int? ?? 0),
      status:       _statusFromString(data['status'] as String? ?? ''),
      description:  data['description']  as String?,
      photoUrl:     data['photo_url']    as String?,
      reportedBy:   data['reported_by']  as String?,
      reporterName: data['reporter_name'] as String?,
    );
  }

  MissingPerson copyWith({
    int? id, String? caseId, String? name, int? age,
    String? gender, String? lastSeen, String? contact,
    DateTime? reportedAt, CaseStatus? status, String? description,
    String? photoUrl, String? reportedBy, String? reporterName,
  }) {
    return MissingPerson(
      id:           id           ?? this.id,
      caseId:       caseId       ?? this.caseId,
      name:         name         ?? this.name,
      age:          age          ?? this.age,
      gender:       gender       ?? this.gender,
      lastSeen:     lastSeen     ?? this.lastSeen,
      contact:      contact      ?? this.contact,
      reportedAt:   reportedAt   ?? this.reportedAt,
      status:       status       ?? this.status,
      description:  description  ?? this.description,
      photoUrl:     photoUrl     ?? this.photoUrl,
      reportedBy:   reportedBy   ?? this.reportedBy,
      reporterName: reporterName ?? this.reporterName,
    );
  }
}

String _statusToString(CaseStatus s) {
  switch (s) {
    case CaseStatus.ditemukan:         return 'ditemukan';
    case CaseStatus.dalamPenyelidikan: return 'dalam_penyelidikan';
    case CaseStatus.belumDitemukan:    return 'belum_ditemukan';
  }
}

CaseStatus _statusFromString(String s) {
  switch (s) {
    case 'ditemukan':          return CaseStatus.ditemukan;
    case 'dalam_penyelidikan': return CaseStatus.dalamPenyelidikan;
    default:                   return CaseStatus.belumDitemukan;
  }
}
