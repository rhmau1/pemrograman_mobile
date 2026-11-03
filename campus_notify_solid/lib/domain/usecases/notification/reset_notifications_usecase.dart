import '../../entities/campus_notification.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/notification_service.dart';
import 'get_notifications_usecase.dart';

class ResetNotificationsUseCase {
  const ResetNotificationsUseCase({
    required this.notificationRepository,
    required this.notificationService,
  });

  final NotificationRepository notificationRepository;
  final NotificationService notificationService;

  Future<List<CampusNotification>> execute() async {
    final defaultList = GetNotificationsUseCase.getDefaultNotifications();
    await notificationRepository.saveActiveNotifications(defaultList);
    await notificationService.updateLauncherBadge(defaultList.length);
    return defaultList;
  }
}
