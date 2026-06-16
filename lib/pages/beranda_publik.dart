// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/pages/beranda_publik.dart                                         ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Halaman Dasbor/Beranda khusus untuk **Pengguna Publik**. Menampilkan UI     ║
// ║  yang ramah dan sederhana agar masyarakat awam dapat dengan mudah melakukan  ║
// ║  laporan penemuan (scan) maupun menambahkan data orang hilang baru.          ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Di-render oleh `UserMainScreen` di `main.dart` pada index tab ke-0.       ║
// ║  - Mengambil data dari `LocalRepository.instance.getRecentCases()`.          ║
// ║  - Memiliki tombol khusus ke `halaman_masuk.dart` (tersembunyi di header)       ║
// ║    bagi petugas polisi yang ingin masuk ke dasbor admin.                     ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `AutomaticKeepAliveClientMixin` : Memastikan tab beranda ini tidak re-    ║
// ║    render ulang dari awal saat pengguna berpindah tab (menghemat memori).    ║
// ║  - `FutureBuilder` : Bertugas menunggu data dari SQLite selesai ditarik      ║
// ║    sebelum menggambar *List* daftar orang hilang terbaru di bagian bawah.    ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'dart:io';
import 'package:flutter/material.dart';
import '../data/repositori_lokal.dart';
import '../models/orang_hilang.dart';
import '../theme/tema_aplikasi.dart';
import '../widgets/komponen_aplikasi.dart';
import 'halaman_masuk.dart';

class UserHomePage extends StatefulWidget {
  final VoidCallback onGoToScan;
  final VoidCallback onGoToReport;

  const UserHomePage({
    super.key,
    required this.onGoToScan,
    required this.onGoToReport,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> with AutomaticKeepAliveClientMixin {
  final _repo = LocalRepository.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        // ── HEADER BIRU GRADIENT ─────────────────────
        SliverAppBar(
          expandedHeight: 220,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primaryDark,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppGradients.hero),
              child: Stack(
                children: [
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
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.manage_search_rounded, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('TraceFace', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                                      Text('Akses Publik', style: TextStyle(fontSize: 11, color: Colors.white60)),
                                    ],
                                  ),
                                ],
                              ),
                              // Tombol Login Petugas di Pojok Kanan Atas
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                                },
                                icon: const Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.white),
                                label: const Text('Petugas', style: TextStyle(color: Colors.white, fontSize: 12)),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Bantu Kami\nMenemukan Mereka',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Gunakan fitur pindai wajah untuk mengenali identitas orang hilang.',
                            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── KONTEN UTAMA ─────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── TINDAKAN CEPAT ────────────────────────────
              const SectionTitle('Fitur Publik'),
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
                      icon: Icons.add_alert_rounded,
                      label: 'Lapor\nKehilangan',
                      color: AppColors.warning,
                      onTap: widget.onGoToReport,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── KASUS TERBARU ─────────────────────────────
              const SectionTitle('Orang Hilang Terbaru'),
              FutureBuilder<List<MissingPerson>>(
                future: _repo.getRecentCases(limit: 5),
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final cases = snap.data ?? [];
                  if (cases.isEmpty) {
                    return const AppCard(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success),
                            SizedBox(height: 12),
                            Text('Belum ada laporan kasus saat ini.', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  }
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: Column(
                      children: [
                        for (int i = 0; i < cases.length; i++)
                          _RecentTile(person: cases[i], index: i, showDivider: i < cases.length - 1),
                      ],
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

// Komponen Pembantu
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withValues(alpha: 0.8)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3))),
          ],
        ),
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  final MissingPerson person;
  final int index;
  final bool showDivider;
  const _RecentTile({required this.person, required this.index, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              person.hasPhoto
                  ? ClipOval(child: Image.file(File(person.photoUrl!), width: 44, height: 44, fit: BoxFit.cover))
                  : PersonAvatar(initials: person.initials, index: index, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${person.lastSeen} · ${person.formattedDate}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: person.status),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 68, endIndent: 12),
      ],
    );
  }
}
