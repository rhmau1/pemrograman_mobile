import '../../entities/campus_notification.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/notification_service.dart';

class MarkNotificationReadResult {
  const MarkNotificationReadResult({
    required this.activeNotifications,
    required this.readHistory,
  });

  final List<CampusNotification> activeNotifications;
  final List<CampusNotification> readHistory;
}

class MarkNotificationReadUseCase {
  const MarkNotificationReadUseCase({
    required this.notificationRepository,
    required this.notificationService,
  });

  final NotificationRepository notificationRepository;
  final NotificationService notificationService;

  Future<MarkNotificationReadResult> execute({
    required List<CampusNotification> currentActive,
    required List<CampusNotification> currentHistory,
    required String id,
  }) async {
    final item = currentActive
        .where((n) => n.id == id || n.announcementId == id)
        .firstOrNull;

    var updatedHistory = currentHistory;
    if (item != null) {
      final readItem = item.copyWith(isRead: true);
      if (!updatedHistory.any((n) => n.id == readItem.id)) {
        updatedHistory = [readItem, ...updatedHistory];
        await notificationRepository.saveReadHistory(updatedHistory);
      }
    }

    final updatedActive = currentActive
        .where((n) => n.id != id && n.announcementId != id)
        .toList();
    await notificationRepository.saveActiveNotifications(updatedActive);

    await notificationService.cancelNotification(id);
    await notificationService.updateLauncherBadge(updatedActive.length);
    if (updatedActive.isEmpty) {
      await notificationService.cancelAllNotifications();
    }

    return MarkNotificationReadResult(
      activeNotifications: updatedActive,
      readHistory: updatedHistory,
    );
  }
}
