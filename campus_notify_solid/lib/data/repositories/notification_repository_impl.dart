import '../../domain/entities/campus_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/local/notification_local_datasource.dart';
import '../models/campus_notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required this.localDataSource,
  });

  final NotificationLocalDataSource localDataSource;

  @override
  Future<List<CampusNotification>> getActiveNotifications() async {
    final models = await localDataSource.getActiveNotifications();
    return models;
  }

  @override
  Future<void> saveActiveNotifications(
    List<CampusNotification> notifications,
  ) async {
    final models = notifications
        .map((e) => CampusNotificationModel.fromEntity(e))
        .toList();
    await localDataSource.saveActiveNotifications(models);
  }

  @override
  Future<List<CampusNotification>> getReadHistory() async {
    final models = await localDataSource.getReadHistory();
    return models;
  }

  @override
  Future<void> saveReadHistory(List<CampusNotification> history) async {
    final models = history
        .map((e) => CampusNotificationModel.fromEntity(e))
        .toList();
    await localDataSource.saveReadHistory(models);
  }

  @override
  Future<void> clearActiveNotifications() =>
      localDataSource.clearActiveNotifications();

  @override
  Future<void> clearReadHistory() => localDataSource.clearReadHistory();
}
