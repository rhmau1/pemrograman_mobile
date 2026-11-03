import '../entities/notification_sound_option.dart';

abstract class NotificationService {
  NotificationSoundOption get selectedSound;
  void setSelectedSound(NotificationSoundOption sound);
  Future<void> playPreviewSound([NotificationSoundOption? sound]);
  Future<void> showNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
    NotificationSoundOption? sound,
  });
  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
  Future<void> updateLauncherBadge(int count);
}
