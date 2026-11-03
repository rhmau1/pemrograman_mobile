import '../../entities/campus_notification.dart';
import '../../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase({
    required this.notificationRepository,
  });

  final NotificationRepository notificationRepository;

  static List<CampusNotification> getDefaultNotifications() {
    final now = DateTime.now();
    return [
      CampusNotification(
        id: '1',
        number: 1,
        title: 'Pengumuman #1 - Jadwal Kuliah Pemrograman Mobile',
        body:
            'Perkuliahan semester ini dilaksanakan secara tatap muka di Lab Komputer Gedung TI lantai 2.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        announcementId: '1',
      ),
      CampusNotification(
        id: '2',
        number: 2,
        title: 'Pengumuman #2 - Pengisian KRS Semester Baru',
        body:
            'Pengisian KRS dibuka mulai tanggal 10. Harap segera konsultasi dengan DPA sebelum batas akhir.',
        timestamp: now.subtract(const Duration(minutes: 10)),
        announcementId: '2',
      ),
      CampusNotification(
        id: '3',
        number: 3,
        title: 'Pengumuman #3 - Perubahan Ruang Kuliah Tamu',
        body:
            'Kuliah tamu pakar industri dipindahkan ke Aula Utama Lantai 3 pukul 13.00 WIB.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        announcementId: '3',
      ),
    ];
  }

  Future<List<CampusNotification>> execute() async {
    final cached = await notificationRepository.getActiveNotifications();
    if (cached.isNotEmpty) {
      cached.sort((a, b) => a.number.compareTo(b.number));
      return cached;
    }
    return getDefaultNotifications();
  }
}
