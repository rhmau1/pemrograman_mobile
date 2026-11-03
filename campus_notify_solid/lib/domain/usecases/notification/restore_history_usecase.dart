import '../../entities/campus_notification.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/notification_service.dart';

class RestoreHistoryUseCase {
  const RestoreHistoryUseCase({
    required this.notificationRepository,
    required this.notificationService,
  });

  final NotificationRepository notificationRepository;
  final NotificationService notificationService;

  Future<List<CampusNotification>> execute({
    required List<CampusNotification> currentActive,
    required List<CampusNotification> itemsToRestore,
  }) async {
    final active = [...currentActive];
    for (final item in itemsToRestore) {
      if (!active.any((n) => n.id == item.id)) {
        active.add(item.copyWith(isRead: false));
      }
    }
    active.sort((a, b) => a.number.compareTo(b.number));

    await notificationRepository.saveActiveNotifications(active);
    await notificationService.updateLauncherBadge(active.length);
    return active;
  }
}
