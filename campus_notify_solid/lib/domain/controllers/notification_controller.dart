import '../entities/campus_notification.dart';
import '../entities/notification_sound_option.dart';
import '../repositories/notification_repository.dart';
import '../repositories/notification_service.dart';
import '../usecases/notification/add_notification_usecase.dart';
import '../usecases/notification/get_notifications_usecase.dart';
import '../usecases/notification/manage_history_usecase.dart';
import '../usecases/notification/mark_notification_read_usecase.dart';
import '../usecases/notification/reset_notifications_usecase.dart';
import '../usecases/notification/restore_history_usecase.dart';

class NotificationController {
  NotificationController({
    required this.getNotificationsUseCase,
    required this.addNotificationUseCase,
    required this.markNotificationReadUseCase,
    required this.resetNotificationsUseCase,
    required this.restoreHistoryUseCase,
    required this.manageHistoryUseCase,
    required this.notificationRepository,
    required this.notificationService,
  });

  final GetNotificationsUseCase getNotificationsUseCase;
  final AddNotificationUseCase addNotificationUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final ResetNotificationsUseCase resetNotificationsUseCase;
  final RestoreHistoryUseCase restoreHistoryUseCase;
  final ManageHistoryUseCase manageHistoryUseCase;
  final NotificationRepository notificationRepository;
  final NotificationService notificationService;

  int _globalCounter = 3;
  int get globalCounter => _globalCounter;

  Future<List<CampusNotification>> loadActiveNotifications() async {
    final list = await getNotificationsUseCase.execute();
    if (list.isNotEmpty) {
      _globalCounter =
          list.map((e) => e.number).fold(0, (max, v) => v > max ? v : max);
    }
    await notificationService.updateLauncherBadge(list.length);
    return list;
  }

  List<CampusNotification> prepareAddNotification({
    required List<CampusNotification> currentList,
    required CampusNotification notification,
  }) {
    final existingIndex =
        currentList.indexWhere((n) => n.id == notification.id);
    if (existingIndex >= 0) return currentList;

    _globalCounter++;
    final assignedNumber =
        notification.number > 0 ? notification.number : _globalCounter;

    final itemWithNumber = notification.copyWith(
      number: assignedNumber,
      title: notification.title.startsWith('Pengumuman #')
          ? notification.title
          : 'Pengumuman #$assignedNumber - ${notification.title}',
    );

    final updated = [...currentList, itemWithNumber];
    updated.sort((a, b) => a.number.compareTo(b.number));
    return updated;
  }

  Future<void> persistNotification({
    required List<CampusNotification> updatedList,
    required CampusNotification item,
    bool showPush = true,
    NotificationSoundOption? sound,
  }) async {
    try {
      await notificationRepository.saveActiveNotifications(updatedList);
      await notificationService.updateLauncherBadge(updatedList.length);
      if (showPush) {
        await notificationService.showNotification(
          id: item.id,
          title: item.title,
          body: item.body,
          payload: item.announcementId ?? item.id,
          sound: sound,
        );
      }
    } catch (_) {}
  }

  Future<void> persistMarkAsRead({
    required List<CampusNotification> activeList,
    required String id,
  }) async {
    try {
      await notificationRepository.saveActiveNotifications(activeList);
      await notificationService.cancelNotification(id);
      await notificationService.updateLauncherBadge(activeList.length);
      if (activeList.isEmpty) {
        await notificationService.cancelAllNotifications();
      }
    } catch (_) {}
  }

  Future<List<CampusNotification>> resetToDefault() async {
    _globalCounter = 3;
    return resetNotificationsUseCase.execute();
  }

  Future<List<CampusNotification>> restoreFromHistory({
    required List<CampusNotification> currentActive,
    required List<CampusNotification> itemsToRestore,
  }) {
    return restoreHistoryUseCase.execute(
      currentActive: currentActive,
      itemsToRestore: itemsToRestore,
    );
  }

  Future<List<CampusNotification>> loadHistory() =>
      manageHistoryUseCase.loadHistory();

  Future<void> persistHistory(List<CampusNotification> history) async {
    try {
      await notificationRepository.saveReadHistory(history);
    } catch (_) {}
  }

  Future<List<CampusNotification>> clearHistory() =>
      manageHistoryUseCase.clearHistory();

  Future<void> clearAllActive() async {
    try {
      await notificationRepository.clearActiveNotifications();
      await notificationService.updateLauncherBadge(0);
      await notificationService.cancelAllNotifications();
    } catch (_) {}
  }

  NotificationSoundOption get selectedSound =>
      notificationService.selectedSound;

  void setSelectedSound(NotificationSoundOption sound) =>
      notificationService.setSelectedSound(sound);

  Future<void> playPreviewSound([NotificationSoundOption? sound]) =>
      notificationService.playPreviewSound(sound);
}
