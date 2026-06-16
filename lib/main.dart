// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/main.dart                                                         ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  File utama (Entry Point) yang menjadi tempat pertama kali aplikasi mulai    ║
// ║  berjalan. Bertugas merangkai dan menginisialisasi seluruh layanan internal  ║
// ║  seperti konfigurasi tampilan OS, manajemen memori SQLite, dan layanan       ║
// ║  notifikasi latar belakang (background service).                             ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Merupakan induk (*root*) dari seluruh halaman (`pages/`).                 ║
// ║  - Diakhiri dengan melontarkan pengguna ke `halaman_pembuka.dart` untuk          ║
// ║    dilakukan verifikasi sesi login sebelum membelah *router* aplikasi.       ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `WidgetsFlutterBinding.ensureInitialized()` : Wajib agar *native code*    ║
// ║    bisa berkomunikasi dengan *Dart/Flutter* sebelum `runApp`.                ║
// ║  - `AdminMainScreen` : Struktur navigasi antarmuka khusus (Bottom Navbar)    ║
// ║    untuk mengelompokkan halaman-halaman yang boleh dilihat Admin.            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/tema_aplikasi.dart';
import 'data/pembantu_database.dart';
import 'services/layanan_notifikasi.dart';
import 'pages/beranda_petugas.dart';
import 'pages/halaman_pindai.dart';
import 'pages/halaman_lapor.dart';
import 'pages/halaman_kasus.dart';
import 'pages/halaman_pembuka.dart';
import 'pages/halaman_pesan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Database Lokal (SQLite)
  await DatabaseHelper.instance.database;

  // 2. Setup notifikasi lokal (channel Android, permission iOS)
  await NotificationService.instance.initialize();

  // 3. Status bar terang (tema light)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:                    Colors.transparent,
      statusBarIconBrightness:           Brightness.dark,
      systemNavigationBarColor:          AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TraceFaceApp());
}

// ── ROOT WIDGET ────────────────────────────────────────────────
class TraceFaceApp extends StatelessWidget {
  const TraceFaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraceFace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      
      // Berpindah ke SplashPage untuk cek sesi
      home: const SplashPage(),
    );
  }
}

// ── MAIN SCREEN ADMIN — Shell 4 Tab ──────────────────────────────────
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // GlobalKey untuk akses refresh() di CasesPage dari luar
  final _casesKey = GlobalKey<CasesPageState>();

  void _goTo(int i) => setState(() => _currentIndex = i);

  late final List<Widget> _pages = [
    // Tab 0: Beranda
    HomePage(
      onGoToScan:   () => _goTo(1),
      onGoToReport: () => _goTo(2),
    ),

    // Tab 1: Pindai
    const ScanPage(),

    // Tab 2: Laporan
    ReportPage(
      onReportSaved: () {
        _casesKey.currentState?.refresh();
        _goTo(3);
      },
    ),

    // Tab 3: Data Kasus
    CasesPage(key: _casesKey),

    // Tab 4: Pesan Masuk
    const AdminMessagesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 3) _casesKey.currentState?.refresh();
          _goTo(i);
        },
      ),
    );
  }
}

// ── BOTTOM NAV ─────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.home_rounded,             label: 'Beranda'),
      (icon: Icons.document_scanner_rounded, label: 'Pindai'),
      (icon: Icons.edit_note_rounded,        label: 'Laporan'),
      (icon: Icons.folder_open_rounded,      label: 'Data Kasus'),
      (icon: Icons.mark_email_unread_rounded,label: 'Pesan'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24, offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon:     items[i].icon,
                    label:    items[i].label,
                    isActive: currentIndex == i,
                    onTap:    () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     isActive;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon, required this.label,
    required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                gradient: isActive ? AppGradients.primary : null,
                color: isActive ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isActive
                    ? [BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 8, offset: const Offset(0, 3),
                      )]
                    : null,
              ),
              child: Icon(icon, size: 21,
                color: isActive ? Colors.white : AppColors.textSecondary),
            ),
            const SizedBox(height: 3),
            Text(label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: isActive ? 0.1 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
