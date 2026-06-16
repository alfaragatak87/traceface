// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  FILE: lib/pages/admin_messages_page.dart                                    ║
// ║                                                                              ║
// ║  DESKRIPSI:                                                                  ║
// ║  Layar khusus Admin untuk mengecek seluruh pesan/laporan penemuan orang      ║
// ║  hilang yang dikirimkan oleh Pengguna Publik setelah melalui proses Scan.    ║
// ║  Merupakan tab ke-5 (Pesan) di tampilan khusus AdminMainScreen.              ║
// ║                                                                              ║
// ║  KONEKSI & RELASI:                                                           ║
// ║  - Terhubung ke tabel `messages` via `getMessages()` di LocalRepository.     ║
// ║  - Menampilkan objek `Message` (model).                                      ║
// ║                                                                              ║
// ║  BARIS KODE PENTING:                                                         ║
// ║  - Fungsi `_markAsRead()` : Secara reaktif mengubah kolom tabel DB `isRead`  ║
// ║    menjadi True ketika Admin mengetuk pesan (sehingga warnanya pudar).       ║
// ║  - Tampilan Kartu Pesan : Berwarna tebal untuk *Unread*, pudar untuk *Read*. ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

import 'package:flutter/material.dart';
import '../data/local_repository.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminMessagesPage extends StatefulWidget {
  const AdminMessagesPage({super.key});

  @override
  State<AdminMessagesPage> createState() => _AdminMessagesPageState();
}

class _AdminMessagesPageState extends State<AdminMessagesPage> {
  final _repo = LocalRepository.instance;
  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final msgs = await _repo.getMessages();
    setState(() {
      _messages = msgs;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(Message msg) async {
    if (!msg.isRead && msg.id != null) {
      await _repo.markMessageAsRead(msg.id!);
      _loadMessages();
    }
  }

  void _showMessageDialog(Message msg) {
    _markAsRead(msg);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Detail Laporan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.person, 'Pengirim', msg.userName),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.phone, 'Kontak', msg.contactInfo.isEmpty ? '-' : msg.contactInfo),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.fingerprint, 'ID Kasus', msg.caseId),
              const SizedBox(height: 8),
              _buildDetailRow(Icons.access_time, 'Waktu', DateFormat('dd MMM yyyy, HH:mm').format(msg.createdAt)),
              const Divider(height: 24),
              const Text('Isi Laporan / Lokasi:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(msg.textMessage, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesan Masuk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMessages,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _MessageCard(
                        message: msg,
                        onTap: () => _showMessageDialog(msg),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada laporan masuk',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  const _MessageCard({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: message.isRead ? Colors.white : AppColors.primaryLight.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: message.isRead ? Colors.grey.shade200 : AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        message.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_rounded,
                        size: 20,
                        color: message.isRead ? Colors.grey : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message.userName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: message.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isRead ? AppColors.textSecondary : AppColors.primary,
                      fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.textMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: message.isRead ? FontWeight.normal : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ID Kasus: ${message.caseId}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
