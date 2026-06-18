// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/theme/tema_aplikasi.dart                                              ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Kamus sentral (*Single Source of Truth*) untuk seluruh konfigurasi visual   ║
// ║  dan estetika UI aplikasi TraceFace. Meliputi palet warna, gradien modern,   ║
// ║  serta pengaturan tema material bawaan Flutter.                              ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Diimpor oleh `main.dart` untuk menginisialisasi `MaterialApp(theme)`.     ║
// ║  - Diimpor oleh hampir seluruh file di dalam folder `pages/` dan `widgets/`. ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `AppColors` : Menyimpan warna statis (misal: `primary`, `background`).    ║
// ║  - `AppGradients` : Menyimpan efek gradien (*glassmorphism*, warna dinamis). ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart'; // Ambil alat-alat desain dari Flutter.

// ──────────────────────────────────────────────────────────────
//  PALET WARNA UTAMA — Tema Biru Indigo Modern
// ──────────────────────────────────────────────────────────────
class AppColors { // Tempat nyimpen semua daftar warna yang dipakai di aplikasi.
  AppColors._(); // Dikunci biar nggak bisa dibikin jadi objek baru, karena ini cuma daftar aja.

  // === WARNA UTAMA (Indigo Biru Modern) ===
  static const Color primary      = Color(0xFF2563EB); // Warna biru utama aplikasi kita.
  static const Color primaryDark  = Color(0xFF1D4ED8); // Warna biru utama tapi versi lebih gelap.
  static const Color primaryLight = Color(0xFF3B82F6); // Warna biru utama tapi versi lebih terang.
  static const Color primaryXLight = Color(0xFFEFF6FF); // Warna biru yang saaaangat terang (nyaris putih).

  // === BACKGROUND & SURFACE ===
  static const Color background  = Color(0xFFF8FAFC); // Warna dasar layar/background aplikasi.
  static const Color surface     = Color(0xFFFFFFFF); // Warna dasar untuk kotak-kotak atau kartu (Putih).
  static const Color surfaceGrey = Color(0xFFF1F5F9); // Warna abu-abu muda buat bedain elemen dari layar yang putih.

  // === TEKS ===
  static const Color textPrimary   = Color(0xFF0F172A); // Warna utama buat tulisan (Hitam tapi gak terlalu pekat).
  static const Color textSecondary = Color(0xFF64748B); // Warna buat tulisan tambahan/keterangan (Abu-abu agak gelap).
  static const Color textHint      = Color(0xFFCBD5E1); // Warna tulisan bayangan pas kita mau ngetik (Abu-abu terang).

  // === STATUS KASUS ===
  static const Color success      = Color(0xFF059669); // Warna hijau kalau sukses/berhasil.
  static const Color successLight = Color(0xFFD1FAE5); // Warna hijau pudar buat latar belakang status sukses.
  static const Color warning      = Color(0xFFD97706); // Warna oranye buat ngasih peringatan.
  static const Color warningLight = Color(0xFFFEF3C7); // Warna oranye pudar buat latar belakang peringatan.
  static const Color info         = Color(0xFF0284C7); // Warna biru laut buat ngasih info/pesan biasa.
  static const Color infoLight    = Color(0xFFE0F2FE); // Warna biru laut pudar buat latar info.
  static const Color danger       = Color(0xFFDC2626); // Warna merah kalau ada error/bahaya.
  static const Color dangerLight  = Color(0xFFFEE2E2); // Warna merah pudar buat latar error.

  // === BORDER & DIVIDER ===
  static const Color border  = Color(0xFFE2E8F0); // Warna garis pinggir/kotak.
  static const Color divider = Color(0xFFF1F5F9); // Warna garis pembatas antar konten.
} // Selesai daftar warna.

// ──────────────────────────────────────────────────────────────
//  GRADIENT
// ──────────────────────────────────────────────────────────────
class AppGradients { // Tempat nyimpen daftar warna gradasi (campuran warna).
  AppGradients._(); // Dikunci biar nggak jadi objek baru.

  static const LinearGradient primary = LinearGradient( // Bikin warna gradasi utama.
    begin: Alignment.topLeft, // Warnanya mulai dari pojok kiri atas.
    end: Alignment.bottomRight, // Berakhir di pojok kanan bawah.
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)], // Campuran warna dari biru utama ke biru terang.
  ); // Selesai gradasi utama.

  static const LinearGradient hero = LinearGradient( // Gradasi khusus buat bagian atas/banner yang keren.
    begin: Alignment.topLeft, // Mulai dari pojok kiri atas.
    end: Alignment.bottomRight, // Selesai di pojok kanan bawah.
    stops: [0.0, 0.6, 1.0], // Posisi di mana warna bakal ganti.
    colors: [Color(0xFF1E3A8A), Color(0xFF1D4ED8), Color(0xFF2563EB)], // Campuran 3 warna biru gelap ke biru terang.
  ); // Selesai gradasi banner.

  static const LinearGradient surface = LinearGradient( // Gradasi buat efek permukaan kartu.
    begin: Alignment.topCenter, // Dari tengah atas.
    end: Alignment.bottomCenter, // Ke tengah bawah.
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)], // Putih memudar jadi abu-abu super muda.
  ); // Selesai gradasi permukaan.

  static const List<LinearGradient> avatars = [ // Daftar kumpulan gradasi keren buat foto profil (avatar).
    LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9F67FA)], // Pilihan 1: Gradasi ungu.
        begin: Alignment.topLeft, end: Alignment.bottomRight), // Arahnya nyamping.
    LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF06B6D4)], // Pilihan 2: Gradasi biru tosca.
        begin: Alignment.topLeft, end: Alignment.bottomRight), // Arahnya nyamping.
    LinearGradient(colors: [Color(0xFF059669), Color(0xFF34D399)], // Pilihan 3: Gradasi hijau.
        begin: Alignment.topLeft, end: Alignment.bottomRight), // Arahnya nyamping.
    LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)], // Pilihan 4: Gradasi kuning keemasan.
        begin: Alignment.topLeft, end: Alignment.bottomRight), // Arahnya nyamping.
    LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFF87171)], // Pilihan 5: Gradasi merah.
        begin: Alignment.topLeft, end: Alignment.bottomRight), // Arahnya nyamping.
  ]; // Selesai daftar gradasi avatar.
} // Selesai daftar warna gradasi.

// ──────────────────────────────────────────────────────────────
//  TYPOGRAPHY
// ──────────────────────────────────────────────────────────────
class AppTextStyles { // Tempat nyimpen gaya tulisan (font size, ketebalan, dll).
  AppTextStyles._(); // Dikunci biar nggak jadi objek baru.

  static const TextStyle heading1 = TextStyle( // Gaya tulisan buat Judul Paling Besar.
    fontSize: 26, fontWeight: FontWeight.w800, // Ukurannya 26, dan tebal bangeeet.
    color: AppColors.textPrimary, letterSpacing: -0.8, // Pakai warna teks utama, jarak antar hurufnya agak dipepetin (-0.8).
    height: 1.2, // Jarak atas bawah antar baris tulisan dibikin pas (1.2).
  ); // Selesai gaya judul besar.
  static const TextStyle heading2 = TextStyle( // Gaya tulisan buat Judul Sedang.
    fontSize: 20, fontWeight: FontWeight.w700, // Ukuran 20, tebal biasa.
    color: AppColors.textPrimary, letterSpacing: -0.4, // Warna utama, huruf sedikit dipepetin.
  ); // Selesai gaya judul sedang.
  static const TextStyle heading3 = TextStyle( // Gaya tulisan buat Judul Kecil.
    fontSize: 16, fontWeight: FontWeight.w600, // Ukuran 16, agak tebal.
    color: AppColors.textPrimary, letterSpacing: -0.2, // Warna utama, huruf dirapatkan dikit.
  ); // Selesai gaya judul kecil.
  static const TextStyle body = TextStyle( // Gaya tulisan buat teks biasa / paragraf cerita.
    fontSize: 14, fontWeight: FontWeight.w400, // Ukuran standar 14, ketebalan normal aja.
    color: AppColors.textPrimary, height: 1.6, // Warna utama, jarak baris dilebarin biar enak dibaca.
  ); // Selesai gaya teks biasa.
  static const TextStyle bodySmall = TextStyle( // Gaya tulisan buat keterangan kecil di bawah kotak.
    fontSize: 12, fontWeight: FontWeight.w400, // Ukuran 12, ketebalan normal.
    color: AppColors.textSecondary, height: 1.5, // Warnanya abu-abu (biar nggak terlalu narik perhatian).
  ); // Selesai gaya keterangan kecil.
  static const TextStyle label = TextStyle( // Gaya tulisan buat badge, status, atau tag.
    fontSize: 11, fontWeight: FontWeight.w600, // Ukuran 11, agak tebal.
    color: AppColors.textSecondary, letterSpacing: 0.5, // Warnanya abu-abu, hurufnya agak direnggangin (+0.5).
  ); // Selesai gaya tulisan label.
  static const TextStyle mono = TextStyle( // Gaya tulisan kaku mirip mesin ketik (biasanya buat kode).
    fontSize: 12, fontFamily: 'monospace', // Ukuran 12, pakai jenis font bawaan 'monospace'.
    color: AppColors.primary, fontWeight: FontWeight.w600, // Pakai warna biru, agak tebal.
  ); // Selesai gaya tulisan kaku.
} // Selesai daftar gaya tulisan.

// ──────────────────────────────────────────────────────────────
//  THEME DATA
// ──────────────────────────────────────────────────────────────
class AppTheme { // Tempat ngebungkus semua warna & gaya huruf biar jadi 1 Tema Aplikasi.
  AppTheme._(); // Dikunci biar nggak jadi objek baru.

  static ThemeData get light => ThemeData( // Bikin setelan tema terang (Light Mode).
    useMaterial3: true, // Pakai desain modern terbarunya Flutter (Material 3).
    fontFamily: 'Roboto', // Semua tulisan di aplikasi secara otomatis pakai font Roboto.

    colorScheme: const ColorScheme.light( // Daftarin peran warna-warna dasar ke sistem Flutter.
      primary:   AppColors.primary, // Kalau butuh warna 'utama', ambil biru kita.
      secondary: AppColors.primaryLight, // Kalau butuh warna 'kedua', ambil biru terang kita.
      surface:   AppColors.surface, // Kalau butuh warna 'permukaan' kartu, ambil warna putih kita.
      error:     AppColors.danger, // Kalau sistem butuh ngasih tau error, pakai warna merah kita.
      onPrimary: Colors.white, // Tulisan di atas warna biru harus berwarna putih.
      onSurface: AppColors.textPrimary, // Tulisan di atas warna putih harus pakai hitam teks utama kita.
    ), // Selesai daftar peran warna.

    scaffoldBackgroundColor: AppColors.background, // Set warna tembok layar paling belakang dengan abu-abu super muda.

    // AppBar
    appBarTheme: const AppBarTheme( // Setelan otomatis buat judul header di atas layar (AppBar).
      backgroundColor: AppColors.surface, // Header pakai warna latar putih.
      elevation: 0, // Buang efek bayangan gelap di bawah header biar kelihatan nyatu.
      scrolledUnderElevation: 2, // Tapi kalau kita scroll ke bawah, baru kasih bayangan tipis.
      shadowColor: AppColors.border, // Warna bayangannya pakai abu-abu garis pinggir.
      foregroundColor: AppColors.textPrimary, // Warna tombol icon & tulisan di header otomatis hitam gelap.
      centerTitle: false, // Posisi tulisan judul ditaruh di kiri, bukan di tengah.
      titleTextStyle: TextStyle( // Aturan gaya huruf buat judul di header.
        fontSize: 18, fontWeight: FontWeight.w700, // Huruf ukuran 18, tebal.
        color: AppColors.textPrimary, letterSpacing: -0.3, // Hitam gelap, agak dirapatkan.
      ), // Selesai aturan tulisan judul header.
    ), // Selesai setelan header atas.

    // Input field
    inputDecorationTheme: InputDecorationTheme( // Setelan otomatis buat kotak ketik (TextField / Form).
      filled: true, // Kotak ngetiknya minta diwarnain.
      fillColor: AppColors.surfaceGrey, // Warnain bagian dalem kotak ngetik pakai abu-abu muda.
      border: OutlineInputBorder( // Garis luar kotak secara umum.
        borderRadius: BorderRadius.circular(14), // Bikin ujung kotaknya membulat (angka 14).
        borderSide: const BorderSide(color: AppColors.border), // Warna garisnya abu-abu.
      ), // Selesai garis luar umum.
      enabledBorder: OutlineInputBorder( // Garis luar waktu kotaknya siap diketik tapi belum disentuh.
        borderRadius: BorderRadius.circular(14), // Ujung membulat.
        borderSide: const BorderSide(color: AppColors.border), // Warna garis abu-abu biasa.
      ), // Selesai garis kotak nganggur.
      focusedBorder: OutlineInputBorder( // Garis luar waktu kotaknya lagi kita klik / lagi ngetik.
        borderRadius: BorderRadius.circular(14), // Ujung membulat.
        borderSide: const BorderSide(color: AppColors.primary, width: 2), // Garisnya berubah biru dan lebih tebal.
      ), // Selesai garis kotak diketik.
      errorBorder: OutlineInputBorder( // Garis luar waktu kotaknya isinya salah / error (misal password salah).
        borderRadius: BorderRadius.circular(14), // Ujung membulat.
        borderSide: const BorderSide(color: AppColors.danger), // Garisnya jadi merah.
      ), // Selesai garis kotak error.
      focusedErrorBorder: OutlineInputBorder( // Garis luar waktu kotaknya error tapi lagi kita klik buat perbaiki.
        borderRadius: BorderRadius.circular(14), // Ujung membulat.
        borderSide: const BorderSide(color: AppColors.danger, width: 2), // Merah dan lebih tebal.
      ), // Selesai garis kotak error diketik.
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14), // Tulisan judul kotak berwarna abu-abu.
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14), // Tulisan contoh (placeholder) pakai warna abu-abu pudar.
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Atur ruang kosong dalam kotak biar nggak sempit.
      prefixIconColor: AppColors.textSecondary, // Kalau ada ikon di sebelah kiri tulisan, otomatis warna abu-abu sekunder.
    ), // Selesai setelan kotak ngetik.

    // Chip
    chipTheme: ChipThemeData( // Setelan otomatis buat tag kategori / kapsul-kapsul tulisan (Chip).
      backgroundColor: AppColors.surfaceGrey, // Latar belakang biasa warna abu-abu muda.
      selectedColor: AppColors.primaryXLight, // Kalau tagnya diklik/dipilih, warnanya jadi biru super muda.
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), // Ukuran tulisan di dalem tag (kecil aja).
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Kasih rongga dalam tag biar lega.
      shape: RoundedRectangleBorder( // Bentuk pinggir tagnya.
        borderRadius: BorderRadius.circular(20), // Bikin bener-bener melengkung kaya pil obat (radius 20).
        side: const BorderSide(color: AppColors.border), // Garis pinggirannya dikasih abu-abu.
      ), // Selesai bentuk pinggiran tag.
    ), // Selesai setelan tag kategori.

    // SnackBar
    snackBarTheme: SnackBarThemeData( // Setelan otomatis buat pop up pesan di bawah layar (SnackBar).
      behavior: SnackBarBehavior.floating, // Pesannya dibuat melayang, bukan nempel ke ujung bawah HP.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), // Kotak pesannya dibikin melengkung ujungnya.
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4), // Tulisannya diubah warna putih biar kelihatan jelas di kotak gelap.
      elevation: 8, // Dikasih bayangan biar kesannya muncul ke atas (melayang).
    ), // Selesai setelan pop up pesan bawah.

    // Divider
    dividerTheme: const DividerThemeData( // Setelan otomatis buat garis pemisah konten.
      color: AppColors.divider, // Pakai warna abu-abu pudar.
      thickness: 1, // Ketebalan garisnya tipis aja (1).
      space: 1, // Jarak garisnya dibikin sempit.
    ), // Selesai setelan pemisah konten.

    // Dialog
    dialogTheme: DialogThemeData( // Setelan otomatis buat pop up peringatan di tengah layar (Dialog).
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Bikin kotak pop up jadi melengkung banget (radius 24).
      elevation: 20, // Bayangannya dibikin super tebel karena dia ada paling depan layar.
      titleTextStyle: const TextStyle( // Setelan gaya huruf buat judul pop up.
        fontSize: 18, fontWeight: FontWeight.w700, // Ukuran lumayan besar dan tebal.
        color: AppColors.textPrimary, // Pakai warna tulisan gelap utama.
      ), // Selesai gaya tulisan pop up dialog.
    ), // Selesai setelan pop up tengah layar.
  ); // Selesai ngebungkus Tema Terang secara keseluruhan.
} // Selesai keseluruhan aturan Tema Aplikasi.