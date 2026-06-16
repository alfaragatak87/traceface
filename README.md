# TraceFace v3.0 — Panduan Lengkap Setup Firebase

---

## 📁 Struktur File & Fungsi

```
traceface/
├── pubspec.yaml
│
└── lib/
    ├── main.dart                     ← Entry + Firebase init + Auth routing
    │
    ├── theme/
    │   └── app_theme.dart            ← Warna, gradient, ThemeData
    │
    ├── models/
    │   └── missing_person.dart       ← Blueprint data + toFirestore/fromFirestore
    │
    ├── services/
    │   ├── auth_service.dart         ← Login / Daftar / Logout Firebase Auth
    │   ├── storage_service.dart      ← Upload foto ke Firebase Storage
    │   └── notification_service.dart ← FCM + notifikasi lokal
    │
    ├── data/
    │   └── firestore_repository.dart ← Semua operasi Firestore (CRUD + Stream)
    │
    ├── pages/
    │   ├── login_page.dart           ← Halaman login
    │   ├── register_page.dart        ← Halaman daftar akun
    │   ├── home_page.dart            ← Tab 0: Dashboard realtime
    │   ├── scan_page.dart            ← Tab 1: Pindai + upload foto + notif
    │   ├── report_page.dart          ← Tab 2: Form + upload foto Firebase Storage
    │   └── cases_page.dart           ← Tab 3: Daftar kasus realtime + update status
    │
    └── widgets/
        └── app_widgets.dart          ← Semua widget reusable
```

---

## 🔗 Alur Koneksi Antar File

```
main.dart
  ├── services/auth_service.dart
  │     └── Firebase Auth + Firestore (koleksi 'users')
  ├── services/notification_service.dart
  │     ├── Firebase Messaging (FCM)
  │     └── flutter_local_notifications
  │
  └── pages/*.dart  →  data/firestore_repository.dart
                          ├── Firestore (koleksi 'missing_cases')
                          ├── services/storage_service.dart
                          │     └── Firebase Storage (folder 'cases/')
                          └── services/notification_service.dart
```

---

## 🚀 SETUP FIREBASE (WAJIB SEBELUM JALANKAN)

### Langkah 1 — Buat Proyek Firebase

1. Buka [console.firebase.google.com](https://console.firebase.google.com)
2. Klik **"Add project"** → isi nama: `TraceFace`
3. Nonaktifkan Google Analytics (opsional) → **Create project**

### Langkah 2 — Tambahkan App Android

1. Di halaman proyek, klik ikon **Android**
2. **Android package name**: `com.example.traceface`
3. Klik **Register app**
4. **Download `google-services.json`**
5. Letakkan file di: `android/app/google-services.json`

### Langkah 3 — Edit android/build.gradle (project level)

```groovy
// android/build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.1'  // ← tambahkan
    }
}
```

### Langkah 4 — Edit android/app/build.gradle (app level)

```groovy
// android/app/build.gradle

android {
    defaultConfig {
        minSdkVersion 21    // ← ubah ke 21
    }
}

// Baris PALING BAWAH:
apply plugin: 'com.google.gms.google-services'
```

### Langkah 5 — Aktifkan Firebase Services

Di Firebase Console, aktifkan:

| Service | Cara Aktifkan |
|---|---|
| **Authentication** | Build → Authentication → Get started → Email/Password → Enable |
| **Firestore** | Build → Firestore Database → Create database → Production mode → pilih region terdekat (asia-southeast1) |
| **Storage** | Build → Storage → Get started → Production mode |
| **Cloud Messaging** | Sudah aktif otomatis |

### Langkah 6 — Atur Firestore Rules

Di Firestore → Rules, ganti dengan:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User hanya bisa baca/tulis data sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Semua user yang login bisa baca/tulis kasus
    match /missing_cases/{caseId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Langkah 7 — Atur Storage Rules

Di Storage → Rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /cases/{caseId}/{file} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

---

## ▶️ Jalankan Aplikasi

```bash
flutter pub get
flutter run
```

### Build APK untuk install di Android:

```bash
flutter build apk --release
```

File APK: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Cara Test Fitur

| Fitur | Cara Test |
|---|---|
| Login | Daftar akun baru → login |
| Upload foto | Tab Laporan → tap area foto → kamera/galeri → simpan |
| Sinkron realtime | Buka app di 2 HP/emulator dengan akun berbeda → tambah laporan di satu HP → cek HP lain otomatis update |
| Notifikasi | Tab Data Kasus → tap "Ditemukan ✓" di kasus manapun → notifikasi muncul di tray HP |
| Pindai + notif | Tab Pindai → ketik nama yang ada → notifikasi "Data Ditemukan" muncul |

---

## ⚠️ Batasan yang Tersisa

| Batasan | Keterangan |
|---|---|
| Face recognition sungguhan | Butuh ML Kit / Google ML API (berbayar). Saat ini pencarian berdasarkan nama |
| Push notification antar HP | Butuh Cloud Functions untuk trigger FCM dari server. Saat ini hanya notif lokal |
| Offline mode | Firestore punya offline cache otomatis, tapi ada batasan |
