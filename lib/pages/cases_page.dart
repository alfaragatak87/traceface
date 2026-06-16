// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/pages/cases_page.dart                                             ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Etalase atau galeri seluruh daftar kasus orang hilang yang sudah didata     ║
// ║  oleh masyarakat. Tampilannya menyesuaikan otoritas (Role): jika Publik,     ║
// ║  hanya bersifat lihat data (*read-only*), namun jika Admin, akan muncul      ║
// ║  tombol Ubah Status dan Hapus Kasus (ikon tempat sampah).                    ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Terhubung ke tabel `missing_cases` di SQLite melalui repo lokal.          ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - Konstruktor `isAdmin` : Nilai *boolean* penentu kewenangan tombol hapus.  ║
// ║  - `_repo.deleteCase()` : Fungsi fatal untuk melenyapkan baris kasus di DB.  ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'dart:io';
import 'package:flutter/material.dart';
import '../data/local_repository.dart';
import '../models/missing_person.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class CasesPage extends StatefulWidget {
  final bool isAdmin;
  const CasesPage({super.key, this.isAdmin = true});

  @override
  State<CasesPage> createState() => CasesPageState();
}

class CasesPageState extends State<CasesPage>
    with AutomaticKeepAliveClientMixin {

  final _repo = LocalRepository.instance;
  late Future<List<MissingPerson>> _casesFuture;
  CaseStatus? _filter;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  // ── REFRESH DATA ───────────────────────────────────────────
  void refresh() {
    setState(() {
      _casesFuture = _repo.getAllCases();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Data Kasus',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<MissingPerson>>(
        future: _casesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var cases = snapshot.data ?? [];

          // Terapkan filter jika ada
          if (_filter != null) {
            cases = cases.where((c) => c.status == _filter).toList();
          }

          if (cases.isEmpty) {
            return EmptyState(
              message: 'Tidak ada kasus',
              subtitle: _filter == null
                  ? 'Belum ada laporan kasus yang masuk'
                  : 'Tidak ada kasus dengan status ini',
              icon: Icons.folder_open_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: cases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _CaseCard(
                  person: cases[index],
                  index:  index,
                  isAdmin: widget.isAdmin,
                  onStatusChanged: refresh,
                  onDeleted:       refresh,
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ── FILTER BOTTOM SHEET ──────────────────────────────────────
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _FilterBtn(
                label: 'Semua Kasus',
                isActive: _filter == null,
                onTap: () {
                  setState(() => _filter = null);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              for (final s in CaseStatus.values) ...[
                _FilterBtn(
                  label: s == CaseStatus.ditemukan ? 'Ditemukan'
                      : s == CaseStatus.dalamPenyelidikan ? 'Penyelidikan'
                      : 'Belum Ditemukan',
                  isActive: _filter == s,
                  onTap: () {
                    setState(() => _filter = s);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterBtn({
    required this.label, required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── KARTU KASUS ───────────────────────────────────────────────
class _CaseCard extends StatelessWidget {
  final MissingPerson person;
  final int           index;
  final bool          isAdmin;
  final VoidCallback  onStatusChanged;
  final VoidCallback  onDeleted;

  const _CaseCard({
    required this.person,
    required this.index,
    required this.isAdmin,
    required this.onStatusChanged,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Nama, ID, Badge Status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                person.hasPhoto
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(person.photoUrl!),
                          width: 60, height: 60, fit: BoxFit.cover,
                        ),
                      )
                    : PersonAvatar(
                        initials: person.initials, index: index, size: 60,
                      ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(person.name,
                              style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusBadge(status: person.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('ID Kasus: ${person.caseId}',
                        style: const TextStyle(
                          fontSize: 12, color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Lapor: ${person.formattedDate}',
                        style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Body: Info kontak & lokasi
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(Icons.location_on_outlined, 'Terakhir: ${person.lastSeen}'),
                const SizedBox(height: 8),
                _InfoRow(Icons.phone_outlined, 'Kontak: ${person.contact}'),
                if (person.description != null && person.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoRow(Icons.notes_rounded, person.description!),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Footer: Aksi (Update Status / Hapus) - Hanya untuk Admin
          if (isAdmin) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showUpdateStatusSheet(context),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Ubah Status'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUpdateStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Status: ${person.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              for (final s in CaseStatus.values) ...[
                _FilterBtn(
                  label: s == CaseStatus.ditemukan ? 'Ditemukan'
                      : s == CaseStatus.dalamPenyelidikan ? 'Dalam Penyelidikan'
                      : 'Belum Ditemukan',
                  isActive: person.status == s,
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (person.status != s && person.id != null) {
                      await LocalRepository.instance.updateStatus(person.id!, s);
                      onStatusChanged();
                    }
                  },
                ),
                const SizedBox(height: 8),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kasus?'),
        content: Text('Apakah Anda yakin ingin menghapus data kasus ${person.name} secara permanen dari perangkat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (person.id != null) {
                await LocalRepository.instance.deleteCase(person.id!, person.caseId);
                onDeleted();
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ),
      ],
    );
  }
}
