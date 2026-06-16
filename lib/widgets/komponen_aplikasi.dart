// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/widgets/komponen_aplikasi.dart                                          ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Pabrik Komponen (*Widget Factory*). Berisi kumpulan elemen antarmuka yang   ║
// ║  bisa dipakai berulang-ulang (*reusable*) di berbagai halaman. Semua widget  ║
// ║  di sini murni berfokus pada **tampilan UI** dan sama sekali **tidak boleh** ║
// ║  mengandung logika database maupun koneksi service.                          ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Sangat bergantung pada `tema_aplikasi.dart` untuk pewarnaan.                  ║
// ║  - Diimpor secara luas oleh halaman-halaman utama (`pages/`).                ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `AppCard` : Wadah putih melengkung berskala modern dengan bayangan.       ║
// ║  - `PrimaryButton` : Tombol aksi utama dengan efek gradien dan klik reaktif. ║
// ║  - `PersonAvatar` : Gambar profil melingkar dengan inisial dinamis.          ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import '../theme/tema_aplikasi.dart';
import '../models/orang_hilang.dart';

// ══════════════════════════════════════════════════════════════
//  AppCard — Kartu premium dengan shadow dan border halus
// ══════════════════════════════════════════════════════════════
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: card,
        ),
      );
    }
    return card;
  }
}

// ══════════════════════════════════════════════════════════════
//  StatCard — Kartu angka statistik dengan desain premium
// ══════════════════════════════════════════════════════════════
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color  valueColor;
  final Color? backgroundColor;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? valueColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: valueColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: valueColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: valueColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: valueColor, size: 18),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: valueColor,
              letterSpacing: -1.0,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PrimaryButton — Tombol utama premium dengan gradient & shadow
// ══════════════════════════════════════════════════════════════
class PrimaryButton extends StatelessWidget {
  final String      label;
  final IconData?   icon;
  final VoidCallback? onPressed;
  final bool        isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isEnabled
              ? AppGradients.primary
              : const LinearGradient(colors: [Color(0xFFCBD5E1), Color(0xFFCBD5E1)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SecondaryButton — Tombol outline elegant
// ══════════════════════════════════════════════════════════════
class SecondaryButton extends StatelessWidget {
  final String      label;
  final IconData?   icon;
  final VoidCallback? onPressed;
  final Color?      foregroundColor;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = foregroundColor ?? AppColors.textSecondary;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fgColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  StatusBadge — Badge label status kasus
// ══════════════════════════════════════════════════════════════
class StatusBadge extends StatelessWidget {
  final CaseStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      CaseStatus.ditemukan         => (AppColors.successLight, AppColors.success,  'Ditemukan'),
      CaseStatus.dalamPenyelidikan => (AppColors.infoLight,    AppColors.info,     'Penyelidikan'),
      CaseStatus.belumDitemukan    => (AppColors.warningLight,  AppColors.warning,  'Belum Ditemukan'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SectionTitle — Judul section dengan aksen biru
// ══════════════════════════════════════════════════════════════
class SectionTitle extends StatelessWidget {
  final String text;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const SectionTitle(
    this.text, {
    super.key,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: onTrailingTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryXLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  EmptyState — Tampilan kosong yang menarik
// ══════════════════════════════════════════════════════════════
class EmptyState extends StatelessWidget {
  final String  message;
  final String? subtitle;
  final IconData icon;
  final String?  actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.folder_open_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primaryXLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PersonAvatar — Avatar lingkaran gradient dengan inisial nama
// ══════════════════════════════════════════════════════════════
class PersonAvatar extends StatelessWidget {
  final String initials;
  final int    index;
  final double size;

  const PersonAvatar({
    super.key,
    required this.initials,
    required this.index,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppGradients.avatars[index % AppGradients.avatars.length];
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
