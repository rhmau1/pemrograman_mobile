import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/notification_provider.dart';

class AnnouncementPage extends ConsumerStatefulWidget {
  const AnnouncementPage({
    super.key,
    required this.id,
    this.initialTitle,
    this.initialBody,
  });

  final String id;
  final String? initialTitle;
  final String? initialBody;

  @override
  ConsumerState<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends ConsumerState<AnnouncementPage> {
  CampusNotification? _cachedNotification;

  @override
  void initState() {
    super.initState();
    // Ambil detail notifikasi sebelum ditandai dibaca
    final unread = ref.read(notificationListProvider);
    final history = ref.read(readHistoryProvider);
    _cachedNotification = unread
            .where((n) => n.id == widget.id || n.announcementId == widget.id)
            .firstOrNull ??
        history
            .where((n) => n.id == widget.id || n.announcementId == widget.id)
            .firstOrNull;

    // Otomatis tandai sebagai sudah dibaca (pindah ke riwayat dibaca)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListProvider.notifier).markAsRead(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data notifikasi yang sesuai dengan ID yang diklik
    final unread = ref.watch(notificationListProvider);
    final history = ref.watch(readHistoryProvider);
    final notif = _cachedNotification ??
        unread
            .where((n) => n.id == widget.id || n.announcementId == widget.id)
            .firstOrNull ??
        history
            .where((n) => n.id == widget.id || n.announcementId == widget.id)
            .firstOrNull;

    final title = notif?.title ?? widget.initialTitle ?? 'Pengumuman #${widget.id}';
    final body = notif?.body ??
        widget.initialBody ??
        'Detail pengumuman resmi dari sistem notifikasi kampus.';
    final number = notif?.number ?? int.tryParse(widget.id) ?? 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Detail Pengumuman',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Category Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PENGUMUMAN #$number',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 14, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text(
                          'Sudah Dibaca',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),

              // Metadata (Time & ID)
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    notif != null
                        ? 'Waktu: ${notif.timestamp.hour.toString().padLeft(2, '0')}:${notif.timestamp.minute.toString().padLeft(2, '0')}'
                        : 'Waktu: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.tag_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${widget.id}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 20),

              // Body Section Header
              Text(
                'Isi Lengkap Pengumuman',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),

              // Body Content Box (Clean container, radius 16, border Color(0xFFE2E8F0))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.6,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Status Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: Color(0xFF16A34A), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Notifikasi telah ditandai dibaca dan dipindahkan ke tab Riwayat Notif.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Back Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
