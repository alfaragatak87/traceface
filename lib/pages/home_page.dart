// ╔══════════════════════════════════════════════════════════════╗
// ║  lib/pages/home_page.dart                                    ║
// ║                                                              ║
// ║  PERAN : Dashboard utama. Data dari SQLite (LocalRepository).║
// ╚══════════════════════════════════════════════════════════════╝

import 'dart:io';
import 'package:flutter/material.dart';
import '../data/local_repository.dart';
import '../models/missing_person.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../services/local_auth_service.dart';
import 'splash_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onGoToScan;
  final VoidCallback onGoToReport;

  const HomePage({
    super.key,
    required this.onGoToScan,
    required this.onGoToReport,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {

  final _repo = LocalRepository.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        // ── HEADER BIRU GRADIENT PREMIUM ─────────────────────
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primaryDark,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppGradients.hero),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    right: -30, top: -30,
                    child: Container(
                      width: 180, height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30, top: 40,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.manage_search_rounded,
                                  color: Colors.white, size: 22,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TraceFace',
                                    style: TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.w800,
                                      color: Colors.white, letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text('Sistem Biometrik',
                                    style: TextStyle(
                                      fontSize: 11, color: Colors.white60,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Tombol Logout Petugas
                              TextButton.icon(
                                onPressed: () async {
                                  await LocalAuthService.instance.logout();
                                  if (!mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SplashPage()),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white),
                                label: const Text('Keluar', style: TextStyle(color: Colors.white, fontSize: 12)),
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.danger.withValues(alpha: 0.8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Halo, Petugas 👋',
                            style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Siap membantu pencarian hari ini.',
                            style: TextStyle(
                              fontSize: 13, color: Colors.white70, height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: const Text('TraceFace',
              style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800,
                fontSize: 16, letterSpacing: -0.3,
              ),
            ),
            titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
          ),
        ),

        // ── KONTEN UTAMA ─────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── STATISTIK REALTIME ─────────────────────────
              FutureBuilder<Map<String, int>>(
                future: _repo.getStats(),
                builder: (ctx, snap) {
                  final stats = snap.data ??
                      {'total': 0, 'aktif': 0, 'selesai': 0, 'proses': 0};
                  return Row(
                    children: [
                      Expanded(child: StatCard(
                        value: stats['total'].toString(),
                        label: 'Total\nKasus',
                        valueColor: AppColors.primary,
                        icon: Icons.people_outline_rounded,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(
                        value: stats['aktif'].toString(),
                        label: 'Belum\nDitemukan',
                        valueColor: AppColors.warning,
                        icon: Icons.search_rounded,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(
                        value: stats['selesai'].toString(),
                        label: 'Sudah\nDitemukan',
                        valueColor: AppColors.success,
                        icon: Icons.check_circle_outline_rounded,
                      )),
                    ],
                  );
                },
              ),

              // ── TINDAKAN CEPAT ────────────────────────────
              const SectionTitle('Tindakan Cepat'),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.document_scanner_rounded,
                      label: 'Pindai\nWajah',
                      color: AppColors.primary,
                      onTap: widget.onGoToScan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Buat\nLaporan',
                      color: AppColors.success,
                      onTap: widget.onGoToReport,
                    ),
                  ),
                ],
              ),

              // ── KASUS TERBARU ─────────────────────────────
              const SectionTitle('Kasus Terbaru'),

              FutureBuilder<List<MissingPerson>>(
                future: _repo.getRecentCases(limit: 3),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const _LoadingCard();
                  }
                  final cases = snap.data ?? [];
                  if (cases.isEmpty) {
                    return EmptyState(
                      message: 'Belum ada kasus',
                      subtitle: 'Buat laporan pertama sekarang',
                      icon: Icons.folder_open_outlined,
                      actionLabel: 'Buat Laporan',
                      onAction: widget.onGoToReport,
                    );
                  }
                  return AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 8,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < cases.length; i++)
                          _RecentTile(
                            person: cases[i],
                            index: i,
                            showDivider: i < cases.length - 1,
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Quick Action Card (lebih visual) ────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Colors.white, height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tile kasus terbaru ──────────────────────────────────────────
class _RecentTile extends StatelessWidget {
  final MissingPerson person;
  final int           index;
  final bool          showDivider;
  const _RecentTile({
    required this.person, required this.index, required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              person.hasPhoto
                  ? ClipOval(
                      child: Image.file(
                        File(person.photoUrl!),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    )
                  : PersonAvatar(
                      initials: person.initials, index: index, size: 44,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name,
                      style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text('${person.lastSeen} · ${person.formattedDate}',
                      style: const TextStyle(
                        fontSize: 11.5, color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: person.status),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 68, endIndent: 12),
      ],
    );
  }
}

// ── Loading skeleton card ────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceGrey, shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13, width: 160,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      height: 11, width: 110,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 24, width: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

// ── Badge Online beranimasi ──────────────────────────────────────
class _OnlineBadge extends StatefulWidget {
  @override
  State<_OnlineBadge> createState() => _OnlineBadgeState();
}
class _OnlineBadgeState extends State<_OnlineBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double>   _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _a = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _a,
            builder: (_, __) => Opacity(
              opacity: _a.value,
              child: Container(
                width: 7, height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80), shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text('Lokal',
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
