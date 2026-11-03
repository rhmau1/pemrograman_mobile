import '../../entities/campus_notification.dart';
import '../../repositories/notification_repository.dart';

class ManageHistoryUseCase {
  const ManageHistoryUseCase({
    required this.notificationRepository,
  });

  final NotificationRepository notificationRepository;

  Future<List<CampusNotification>> loadHistory() async {
    return notificationRepository.getReadHistory();
  }

  Future<List<CampusNotification>> addHistoryItem(
    List<CampusNotification> currentHistory,
    CampusNotification item,
  ) async {
    if (currentHistory.any((n) => n.id == item.id)) return currentHistory;
    final updated = [item.copyWith(isRead: true), ...currentHistory];
    await notificationRepository.saveReadHistory(updated);
    return updated;
  }

  Future<List<CampusNotification>> deleteHistoryItem(
    List<CampusNotification> currentHistory,
    String id,
  ) async {
    final updated = currentHistory.where((n) => n.id != id).toList();
    await notificationRepository.saveReadHistory(updated);
    return updated;
  }

  Future<List<CampusNotification>> clearHistory() async {
    await notificationRepository.clearReadHistory();
    return [];
  }
}
