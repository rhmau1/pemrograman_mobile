import '../entities/campus_notification.dart';

abstract class NotificationRepository {
  Future<List<CampusNotification>> getActiveNotifications();
  Future<void> saveActiveNotifications(List<CampusNotification> notifications);
  Future<List<CampusNotification>> getReadHistory();
  Future<void> saveReadHistory(List<CampusNotification> history);
  Future<void> clearActiveNotifications();
  Future<void> clearReadHistory();
}
