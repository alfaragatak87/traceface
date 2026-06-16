// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/pages/halaman_masuk.dart                                             ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Layar formulir autentikasi masuk (Login) khusus bagi Petugas Polisi atau    ║
// ║  Administrator yang ingin mengelola data di TraceFace.                       ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Dipanggil dari `UserHomePage` jika Publik mengetuk tombol "Petugas".      ║
// ║  - Menghubungi `repositori_lokal.dart` -> `loginAdmin()` untuk validasi.     ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - `_repo.loginAdmin(email, pass)` : Menyuntikkan kredensial ke repo SQLite  ║
// ║    yang di sana sandi akan di-hash menggunakan **SHA-256**.                  ║
// ║  - `LocalAuthService.instance.login(user.name)` : Menyimpan status aktif     ║
// ║    di memori HP.                                                             ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import '../data/repositori_lokal.dart';
import '../services/layanan_autentikasi.dart';
import '../theme/tema_aplikasi.dart';
import '../widgets/komponen_aplikasi.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _isLoading  = false;
  bool _obscure    = true;

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Cek di tabel users SQLite
    final user = await LocalRepository.instance.loginAdmin(email, pass);

    if (!mounted) return;

    if (user != null) {
      // Simpan session
      final userName = user['name'] as String;
      await LocalAuthService.instance.login(userName);

      if (!mounted) return;

      // Arahkan ke dasbor admin
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        (route) => false,
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau kata sandi salah. Coba lagi.')),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Login Petugas'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings_rounded, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Akses Terbatas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan masuk menggunakan akun petugas Anda',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              
              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              
              // Tombol Login
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _isLoading ? 'Memproses...' : 'Masuk',
                  icon: Icons.login_rounded,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleLogin,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
