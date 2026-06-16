import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'user_home_page.dart';
import 'scan_page.dart';
import 'report_page.dart';
import 'cases_page.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _currentIndex = 0;
  final _casesKey = GlobalKey<CasesPageState>();

  void _goTo(int i) => setState(() => _currentIndex = i);

  late final List<Widget> _pages = [
    // Tab 0: Beranda Publik
    UserHomePage(
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
    // Tab 3: Data Kasus (Read-Only)
    CasesPage(key: _casesKey, isAdmin: false),
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

// ── BOTTOM NAV KHUSUS PUBLIK ──────────────────────────────────
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
      (icon: Icons.edit_note_rounded,        label: 'Lapor'),
      (icon: Icons.people_alt_rounded,       label: 'Kasus'),
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
                  child: GestureDetector(
                    onTap: () => onTap(i),
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
                              gradient: currentIndex == i ? AppGradients.primary : null,
                              color: currentIndex == i ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(items[i].icon, size: 21,
                              color: currentIndex == i ? Colors.white : AppColors.textSecondary),
                          ),
                          const SizedBox(height: 3),
                          Text(items[i].label,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: currentIndex == i ? FontWeight.w800 : FontWeight.w500,
                              color: currentIndex == i ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
