// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/pages/halaman_pembuka.dart                                            ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Layar sambutan animasi yang muncul pertama kali saat aplikasi dibuka.       ║
// ║  Di balik layarnya, ia bekerja secara rahasia sebagai "Gerbang Logika"       ║
// ║  untuk menentukan ke mana pengguna harus diarahkan: apakah ke beranda        ║
// ║  publik, ataukah ke dasbor admin (jika token login masih tersimpan).         ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Dipanggil oleh `main.dart` sebagai halaman awal (home).                   ║
// ║  - Mendorong (*push replacement*) ke `UserMainScreen` atau `AdminMainScreen`.║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `LocalRepository.instance.checkAndCreateDefaultAdmin()` : Memastikan      ║
// ║    akun `admin@traceface.com` selalu ada di database walaupun aplikasinya    ║
// ║    baru saja di-install ulang.                                               ║
// ║  - `isLoggedIn()` : Mengintip status login di `LocalAuthService`.            ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import '../data/repositori_lokal.dart';
import '../services/layanan_autentikasi.dart';
import '../theme/tema_aplikasi.dart';
import 'user_main_screen.dart';
import '../main.dart'; // To import AdminMainScreen

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
    
    _initApp();
  }

  Future<void> _initApp() async {
    // Pastikan admin default terbuat (jika database kosong)
    await LocalRepository.instance.checkAndCreateDefaultAdmin();

    // Tunggu sedikit agar animasi splash terlihat
    await Future.delayed(const Duration(milliseconds: 2500));

    // Cek status sesi login
    final isLoggedIn = await LocalAuthService.instance.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      // Masuk ke Dasbor Admin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminMainScreen()),
      );
    } else {
      // Masuk ke Dasbor User Publik
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserMainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20, offset: const Offset(0, 10),
                    )
                  ]
                ),
                child: const Icon(Icons.manage_search_rounded, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'TraceFace',
                style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w900,
                  color: Colors.white, letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sistem Pencarian Biometrik',
                style: TextStyle(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
