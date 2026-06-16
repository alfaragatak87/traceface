// ╔══════════════════════════════════════════════════════════════╗
// ║  lib/main.dart                                               ║
// ║                                                              ║
// ║  PERAN : Pintu masuk utama. Inisialisasi service lokal.     ║
// ║                                                              ║
// ║  URUTAN INISIALISASI :                                       ║
// ║    1. Flutter binding                                        ║
// ║    2. DatabaseHelper (SQLite lokal)                          ║
// ║    3. NotificationService                                    ║
// ║    4. runApp → langsung ke MainScreen                        ║
// ╚══════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/app_theme.dart';
import 'data/database_helper.dart';
import 'services/notification_service.dart';
import 'pages/home_page.dart';
import 'pages/scan_page.dart';
import 'pages/report_page.dart';
import 'pages/cases_page.dart';
import 'pages/splash_page.dart';
import 'pages/admin_messages_page.dart';

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
