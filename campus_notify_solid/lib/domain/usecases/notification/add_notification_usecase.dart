import '../../entities/campus_notification.dart';
import '../../entities/notification_sound_option.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/notification_service.dart';

class AddNotificationUseCase {
  const AddNotificationUseCase({
    required this.notificationRepository,
    required this.notificationService,
  });

  final NotificationRepository notificationRepository;
  final NotificationService notificationService;

  Future<List<CampusNotification>> execute({
    required List<CampusNotification> currentList,
    required CampusNotification notification,
    int? nextNumber,
    bool showPush = true,
    NotificationSoundOption? sound,
  }) async {
    final existingIndex = currentList.indexWhere((n) => n.id == notification.id);
    if (existingIndex >= 0) return currentList;

    final maxNumber = currentList.isEmpty
        ? 0
        : currentList.map((e) => e.number).reduce((a, b) => a > b ? a : b);
    final assignedNumber = notification.number > 0
        ? notification.number
        : (nextNumber ?? (maxNumber + 1));

    final itemWithNumber = notification.copyWith(
      number: assignedNumber,
      title: notification.title.startsWith('Pengumuman #')
          ? notification.title
          : 'Pengumuman #$assignedNumber - ${notification.title}',
    );

    final updated = [...currentList, itemWithNumber];
    updated.sort((a, b) => a.number.compareTo(b.number));

    await notificationRepository.saveActiveNotifications(updated);
    await notificationService.updateLauncherBadge(updated.length);

    if (showPush) {
      await notificationService.showNotification(
        id: itemWithNumber.id,
        title: itemWithNumber.title,
        body: itemWithNumber.body,
        payload: itemWithNumber.announcementId ?? itemWithNumber.id,
        sound: sound,
      );
    }

    return updated;
  }
}
