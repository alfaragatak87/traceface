// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/pages/halaman_lapor.dart                                            ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Layar formulir bagi masyarakat atau admin untuk mendata dan melaporkan      ║
// ║  kasus orang hilang baru. Meminta informasi seperti nama, jenis kelamin,     ║
// ║  terakhir terlihat, dan yang paling penting: lampiran foto wajah.            ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Menggunakan `LocalRepository` -> `addCase()` untuk menyimpan entri ke DB. ║
// ║  - Memanggil `NotificationService` agar HP membunyikan notifikasi darurat.   ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `_pickImage()` : Pemanggil native Android API untuk memantik galeri/foto. ║
// ║  - `_submit()` : Validasi manual form dan mem-bundle objek `MissingPerson`   ║
// ║    agar siap ditelan oleh SQLite, disusul pemindahan otomatis ke Tab Kasus.  ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/repositori_lokal.dart';
import '../theme/tema_aplikasi.dart';
import '../widgets/komponen_aplikasi.dart';

class ReportPage extends StatefulWidget {
  final VoidCallback? onReportSaved;
  const ReportPage({super.key, this.onReportSaved});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _repo   = LocalRepository.instance;
  final _picker = ImagePicker();

  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _ageCtrl        = TextEditingController();
  final _locationCtrl   = TextEditingController();
  final _contactCtrl    = TextEditingController();
  final _descCtrl       = TextEditingController();

  String  _gender      = 'Laki-laki';
  File?   _photoFile;   // File foto yang dipilih
  bool    _isSubmitting = false;
  // Progress upload foto (0.0 - 1.0)
  // Di sini kita simulasikan dengan loading biasa karena
  // progress tracking butuh StorageTask listener yang lebih kompleks
  String  _submitStep  = '';

  @override
  void dispose() {
    _nameCtrl.dispose(); _ageCtrl.dispose(); _locationCtrl.dispose();
    _contactCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  // ── PILIH FOTO ────────────────────────────────────────────
  Future<void> _pickPhoto(ImageSource source) async {
    final xfile = await _picker.pickImage(
      source:       source,
      maxWidth:     1280,
      maxHeight:    1280,
      imageQuality: 80,
    );
    if (xfile != null) {
      setState(() => _photoFile = File(xfile.path));
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context:       context,
      shape:         const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Pilih Sumber Foto',
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryXLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                  color: AppColors.primary),
              ),
              title: const Text('Ambil dari Kamera'),
              subtitle: const Text('Foto langsung dengan kamera HP'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryXLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              ),
              title: const Text('Pilih dari Galeri'),
              subtitle: const Text('Pilih foto dari penyimpanan HP'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            if (_photoFile != null)
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
                ),
                title: const Text('Hapus Foto',
                  style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _photoFile = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── SUBMIT FORM ───────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSubmitting = true; _submitStep = 'Memvalidasi data...'; });

    try {
      if (_photoFile != null) {
        setState(() => _submitStep = 'Mengupload foto...');
      }
      setState(() => _submitStep = 'Menyimpan ke database...');

      // Simpan ke SQLite + salin foto ke Storage lokal
      // LocalRepository.addCase() sudah handle keduanya sekaligus
      final newCase = await _repo.addCase(
        name:        _nameCtrl.text.trim(),
        age:         int.tryParse(_ageCtrl.text.trim()),
        gender:      _gender,
        lastSeen:    _locationCtrl.text.trim(),
        contact:     _contactCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        photoFile:   _photoFile, // ← File foto dikirim ke StorageService
      );

      setState(() { _isSubmitting = false; _submitStep = ''; });
      _clearForm();

      if (mounted) {
        _showSuccessDialog(newCase.caseId, newCase.name);
      }

    } catch (e) {
      setState(() { _isSubmitting = false; _submitStep = ''; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _nameCtrl.clear(); _ageCtrl.clear(); _locationCtrl.clear();
    _contactCtrl.clear(); _descCtrl.clear();
    setState(() { _gender = 'Laki-laki'; _photoFile = null; });
  }

  void _showSuccessDialog(String caseId, String name) {
    showDialog(
      context:           context,
      barrierDismissible: false,
      builder:           (_) => Dialog(
        shape:           RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.successLight, shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Laporan Berhasil Disimpan!',
                style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _InfoRow('Nama',       name),
                    const SizedBox(height: 6),
                    _InfoRow('ID Laporan', caseId, isCode: true),
                    if (_photoFile != null) ...[
                      const SizedBox(height: 6),
                      const _InfoRow('Foto', 'Berhasil diupload ✓',
                        isSuccess: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Data tersimpan secara lokal di perangkat ini.',
                style: TextStyle(
                  fontSize: 12, color: AppColors.textSecondary, height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Lihat Data Kasus',
                icon: Icons.folder_open_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onReportSaved?.call();
                },
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                label: 'Tutup',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Orang Hilang'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── UPLOAD FOTO ─────────────────────────
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        // Preview foto atau placeholder
                        GestureDetector(
                          onTap: _showPhotoOptions,
                          child: _photoFile != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(_photoFile!,
                                        width: 120, height: 120,
                                        fit: BoxFit.cover),
                                    ),
                                    // Edit overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          color: Colors.black26,
                                        ),
                                        child: const Icon(
                                          Icons.edit_rounded,
                                          color: Colors.white, size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryXLight,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_add_rounded,
                                    size: 44, color: AppColors.primary,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _photoFile != null
                              ? 'Foto dipilih — tap untuk ganti'
                              : 'Foto Wajah Orang Hilang',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _photoFile != null
                                ? FontWeight.w600 : FontWeight.w400,
                            color: _photoFile != null
                                ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _showPhotoOptions,
                          icon: Icon(
                            _photoFile != null
                                ? Icons.edit_rounded
                                : Icons.camera_alt_rounded,
                            size: 16,
                          ),
                          label: Text(
                            _photoFile != null ? 'Ganti Foto' : 'Ambil / Unggah Foto',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── FORM DATA ───────────────────────────
                  const SectionTitle('Data Orang Hilang'),
                  AppCard(
                    child: Column(
                      children: [
                        _Field('Nama Lengkap *', _nameCtrl,
                          hint: 'Nama lengkap orang hilang',
                          icon: Icons.badge_outlined,
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _Field('Usia', _ageCtrl,
                                hint: 'Tahun',
                                icon: Icons.cake_outlined,
                                type: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GenderDropdown(
                                value:     _gender,
                                onChanged: (v) =>
                                    setState(() => _gender = v ?? 'Laki-laki'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _Field('Terakhir Terlihat di *', _locationCtrl,
                          hint: 'Kota / Kecamatan / Alamat...',
                          icon: Icons.location_on_outlined,
                          validator: (v) => (v?.trim().isEmpty ?? true)
                              ? 'Lokasi wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        _Field('Kontak Pelapor', _contactCtrl,
                          hint: '08xx-xxxx-xxxx',
                          icon: Icons.phone_outlined,
                          type: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _Field('Keterangan Tambahan', _descCtrl,
                          hint: 'Ciri fisik, pakaian terakhir, dll.',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status upload jika sedang proses
                  if (_isSubmitting && _submitStep.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(_submitStep,
                            style: const TextStyle(
                              fontSize: 13, color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  PrimaryButton(
                    label:     'Simpan ke Database',
                    icon:      Icons.cloud_upload_rounded,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label:     'Bersihkan Form',
                    icon:      Icons.clear_rounded,
                    onPressed: _clearForm,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helpers
class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final IconData icon;
  final TextInputType? type;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field(this.label, this.ctrl, {
    required this.hint, required this.icon,
    this.type, this.maxLines = 1, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller:   ctrl,
          keyboardType: type,
          maxLines:     maxLines,
          validator:    validator,
          decoration: InputDecoration(
            hintText:   hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _GenderDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jenis Kelamin',
          style: TextStyle(
            fontSize: 12.5, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:      value,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 14, color: AppColors.textPrimary,
              ),
              items: ['Laki-laki', 'Perempuan']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool isCode, isSuccess;
  const _InfoRow(this.label, this.value,
      {this.isCode = false, this.isSuccess = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ',
          style: const TextStyle(
            fontSize: 13, color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSuccess
                  ? AppColors.success
                  : isCode ? AppColors.primary : AppColors.textPrimary,
              fontFamily: isCode ? 'monospace' : null,
            ),
          ),
        ),
      ],
    );
  }
}
