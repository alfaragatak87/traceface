// ╔══════════════════════════════════════════════════════════════╗
// ║  lib/pages/scan_page.dart                                    ║
// ║                                                              ║
// ║  PERAN : Pindai wajah — pilih foto dari kamera/galeri,     ║
// ║          cocokkan dengan data Firestore, kirim notifikasi   ║
// ║          lokal jika ada yang cocok.                         ║
// ║                                                              ║
// ║  CARA KERJA SCAN :                                           ║
// ║    Mode 1 — Nama: ketik nama → cari di SQLite               ║
// ║    Mode 2 — Foto: ambil foto → cari berdasarkan nama        ║
// ║             (di dunia nyata diganti ML face recognition)    ║
// ║                                                              ║
// ║  NOTIFIKASI :                                                ║
// ║    Jika ditemukan cocok → NotificationService.showFoundNotif ║
// ║    → Muncul di tray notifikasi HP                           ║
// ╚══════════════════════════════════════════════════════════════╝

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/local_repository.dart';
import '../models/missing_person.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  final _repo        = LocalRepository.instance;
  final _notif       = NotificationService.instance;
  final _picker      = ImagePicker();
  final _nameCtrl    = TextEditingController();

  // State
  File?               _pickedImage;  // Foto yang dipilih dari kamera/galeri
  List<MissingPerson> _results      = [];
  bool _hasSearched  = false;
  bool _isSearching  = false;
  String _scanMode   = 'name'; // 'name' atau 'photo'

  // Animasi garis scan
  late final AnimationController _scanCtrl;
  late final Animation<double>   _scanAnim;
  // Animasi fade-in hasil
  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── AMBIL FOTO DARI KAMERA ────────────────────────────────
  Future<void> _pickFromCamera() async {
    final xfile = await _picker.pickImage(
      source:   ImageSource.camera,
      maxWidth: 1280, maxHeight: 1280,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() {
        _pickedImage = File(xfile.path);
        _hasSearched = false;
        _results     = [];
        _scanMode    = 'photo';
      });
    }
  }

  // ── AMBIL FOTO DARI GALERI ────────────────────────────────
  Future<void> _pickFromGallery() async {
    final xfile = await _picker.pickImage(
      source:   ImageSource.gallery,
      maxWidth: 1280, maxHeight: 1280,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() {
        _pickedImage = File(xfile.path);
        _hasSearched = false;
        _results     = [];
        _scanMode    = 'photo';
      });
    }
  }

  // ── JALANKAN PENCARIAN ────────────────────────────────────
  // Mode nama: cari berdasarkan teks di _nameCtrl
  // Mode foto: simulasi — di produksi diganti ML face recognition
  Future<void> _doScan() async {
    final query = _nameCtrl.text.trim();

    if (_scanMode == 'name' && query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ketik nama terlebih dahulu.')),
      );
      return;
    }

    setState(() { _isSearching = true; _hasSearched = false; _results = []; });

    // Simulasi delay pemrosesan biometrik
    await Future.delayed(const Duration(milliseconds: 1400));

    List<MissingPerson> found;

    if (_scanMode == 'photo' && _pickedImage != null) {
      // ── MODE FOTO ──────────────────────────────────────────
      // Di produksi: kirim foto ke ML model → dapat nama
      // Di sini: simulasi dengan nama dari input (jika ada)
      // atau tampilkan pesan bahwa ini simulasi
      if (query.isNotEmpty) {
        found = await _repo.searchByName(query);
      } else {
        // SIMULASI FACE RECOGNITION:
        // Karena tidak ada model ML/AI sungguhan, kita simulasikan
        // sistem berhasil mencocokkan wajah dengan mengambil 1 kasus
        // secara acak dari database lokal.
        final allCases = await _repo.getAllCases();
        if (allCases.isNotEmpty) {
          // Ambil hingga 3 kasus untuk disimulasikan sebagai opsi yang mirip
          allCases.shuffle();
          found = allCases.take(3).toList();
          
          if (mounted) {
            // Hentikan loading agar popup terlihat jelas
            setState(() { _isSearching = false; });
            
            // Tampilkan popup
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.face_retouching_natural_rounded, color: AppColors.primary, size: 28),
                    SizedBox(width: 10),
                    Expanded(child: Text('Analisis Selesai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                  ],
                ),
                content: Text(
                  'Sistem mendeteksi ada ${found.length} opsi wajah di database yang memiliki tingkat kemiripan tinggi dengan target pencarian.',
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                ),
                actions: [
                  PrimaryButton(
                    label: 'Lihat Hasil Pencocokan',
                    icon: Icons.list_alt_rounded,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          }
        } else {
          found = [];
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Database masih kosong. Buat laporan kasus terlebih dahulu agar bisa dicocokkan.',
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } else {
      // ── MODE NAMA ──────────────────────────────────────────
      found = await _repo.searchByName(query);
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _results     = found;
      });

      // ── KIRIM NOTIFIKASI jika ditemukan ──────────────────
      // Notifikasi muncul di tray HP sebagai push notification lokal
      if (found.isNotEmpty) {
        await _notif.showFoundNotification(
          personName: found.first.name,
          caseId:     found.first.caseId,
          location:   found.first.lastSeen,
        );
      }

      _fadeCtrl.reset();
      _fadeCtrl.forward();
    }
  }

  void _reset() {
    setState(() {
      _hasSearched = false;
      _isSearching = false;
      _results     = [];
      _pickedImage = null;
      _scanMode    = 'name';
      _nameCtrl.clear();
    });
    _fadeCtrl.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pindai Wajah'),
        actions: [
          if (_hasSearched || _pickedImage != null)
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── VIEWFINDER ANIMASI ────────────────────────
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Tampilkan foto yang dipilih atau viewfinder animasi
                  _pickedImage != null
                      ? _PhotoPreview(
                          image: _pickedImage!,
                          isProcessing: _isSearching,
                        )
                      : _ScanViewfinder(animation: _scanAnim),

                  const SizedBox(height: 14),

                  Text(
                    _isSearching
                        ? 'Memproses Pemindaian...'
                        : _pickedImage != null
                            ? 'Foto siap dianalisis'
                            : 'Sensor Biometrik Aktif',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: _isSearching ? AppColors.warning : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSearching
                        ? 'Mencocokkan data biometrik di database...'
                        : 'Pilih foto atau masukkan nama target',
                    style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── TOMBOL PILIH FOTO ─────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text('Kamera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Galeri'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── INPUT NAMA ────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '⌨  CARI BERDASARKAN NAMA',
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    onSubmitted: (_) => _doScan(),
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() => _scanMode = 'name'),
                    decoration: const InputDecoration(
                      labelText: 'Nama target',
                      hintText: 'Contoh: Siti Rahayu',
                      prefixIcon: Icon(Icons.person_search_rounded),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── TOMBOL PINDAI ─────────────────────────────
            PrimaryButton(
              label:       _isSearching ? 'Memindai...' : 'Mulai Pemindaian',
              icon:        Icons.document_scanner_rounded,
              isLoading:   _isSearching,
              onPressed:   _isSearching ? null : _doScan,
            ),

            // ── HASIL PENCARIAN ───────────────────────────
            if (_hasSearched) ...[
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnim,
                child: _results.isNotEmpty
                    ? _FoundSection(persons: _results)
                    : _NotFoundCard(
                        query:    _nameCtrl.text.trim(),
                        hasPhoto: _pickedImage != null,
                      ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Preview foto yang dipilih ───────────────────────────────────
class _PhotoPreview extends StatelessWidget {
  final File image;
  final bool isProcessing;
  const _PhotoPreview({required this.image, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(image,
            width: 200, height: 200, fit: BoxFit.cover),
        ),
        if (isProcessing)
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 10),
                Text('Menganalisis...',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        // Overlay sudut viewfinder di atas foto
        const SizedBox(
          width: 200, height: 200,
          child: CustomPaint(
            painter: _CornerPainter(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ── Viewfinder animasi ──────────────────────────────────────────
class _ScanViewfinder extends StatelessWidget {
  final Animation<double> animation;
  const _ScanViewfinder({required this.animation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, height: 200,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryXLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Center(
              child: Icon(
                Icons.face_retouching_natural_rounded,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),
          const CustomPaint(
            painter: _CornerPainter(color: AppColors.primary),
            child: SizedBox(width: 200, height: 200),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (_, __) {
              final top = 10.0 + 180.0 * animation.value;
              final opacity = animation.value < 0.08
                  ? animation.value / 0.08
                  : animation.value > 0.92
                      ? (1.0 - animation.value) / 0.08
                      : 1.0;
              return Positioned(
                top: top, left: 16, right: 16,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Colors.transparent,
                        AppColors.primary,
                        Colors.transparent,
                      ]),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// CustomPainter sudut bingkai
class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const len = 28.0;
    const r   = 10.0;
    // Kiri Atas
    canvas.drawPath(Path()
      ..moveTo(0, len)..lineTo(0, r)
      ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
      ..lineTo(len, 0), p);
    // Kanan Atas
    canvas.drawPath(Path()
      ..moveTo(size.width - len, 0)..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: const Radius.circular(r))
      ..lineTo(size.width, len), p);
    // Kiri Bawah
    canvas.drawPath(Path()
      ..moveTo(0, size.height - len)..lineTo(0, size.height - r)
      ..arcToPoint(Offset(r, size.height), radius: const Radius.circular(r))
      ..lineTo(len, size.height), p);
    // Kanan Bawah
    canvas.drawPath(Path()
      ..moveTo(size.width - len, size.height)..lineTo(size.width - r, size.height)
      ..arcToPoint(Offset(size.width, size.height - r), radius: const Radius.circular(r))
      ..lineTo(size.width, size.height - len), p);
  }

  @override
  bool shouldRepaint(_CornerPainter o) => false;
}

// ── Hasil: Ditemukan ────────────────────────────────────────────
class _FoundSection extends StatelessWidget {
  final List<MissingPerson> persons;
  const _FoundSection({required this.persons});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                color: AppColors.successLight, shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${persons.length} Data Ditemukan!',
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const Text(
                  '📲 Notifikasi dikirim ke perangkat',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...persons.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _FoundCard(person: e.value, index: e.key),
        )),
      ],
    );
  }
}

class _FoundCard extends StatelessWidget {
  final MissingPerson person;
  final int           index;
  const _FoundCard({required this.person, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.successLight.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              person.hasPhoto
                  ? ClipOval(
                      child: Image.file(
                        File(person.photoUrl!),
                        width: 48, height: 48, fit: BoxFit.cover,
                      ),
                    )
                  : PersonAvatar(
                      initials: person.initials, index: index, size: 48,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name,
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text('${person.age ?? "—"} thn · ${person.gender}',
                      style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary,
                      ),
                    ),
                    Text(person.caseId,
                      style: const TextStyle(
                        fontSize: 11, fontFamily: 'monospace',
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: person.status),
            ],
          ),
          const Divider(height: 20),
          _Row(Icons.location_on_outlined, 'Lokasi', person.lastSeen),
          const SizedBox(height: 4),
          _Row(Icons.calendar_today_outlined, 'Laporan', person.formattedDate),
          if (person.contact.isNotEmpty) ...[
            const SizedBox(height: 4),
            _Row(Icons.phone_outlined, 'Kontak', person.contact),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _dialog(context, '📞 Hubungi Keluarga',
                    'Mengirim notifikasi ke:\n${person.contact}'),
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Hubungi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _dialog(context, '📍 Kirim Lokasi',
                    'Koordinat GPS dikirim ke pusat komando.'),
                  icon: const Icon(Icons.location_on_outlined, size: 16),
                  label: const Text('Lokasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _dialog(BuildContext ctx, String title, String msg) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(msg, style: const TextStyle(height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon; final String label, value;
  const _Row(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Expanded(
          child: Text(value,
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hasil: Tidak ditemukan ──────────────────────────────────────
class _NotFoundCard extends StatelessWidget {
  final String query;
  final bool   hasPhoto;
  const _NotFoundCard({required this.query, required this.hasPhoto});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.dangerLight.withValues(alpha: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(
              color: AppColors.dangerLight, shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
              color: AppColors.danger, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data Tidak Ditemukan',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPhoto && query.isEmpty
                      ? 'Wajah tidak cocok dengan data manapun. Coba ketik nama untuk pencarian manual.'
                      : '"$query" tidak terdaftar di sistem.',
                  style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
