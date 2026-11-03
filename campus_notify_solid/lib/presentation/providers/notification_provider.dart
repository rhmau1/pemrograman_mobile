import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/notification_local_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/services/push_service_impl.dart';
import '../../domain/controllers/notification_controller.dart';
import '../../domain/entities/campus_notification.dart';
import '../../domain/entities/notification_sound_option.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/notification_service.dart';
import '../../domain/usecases/notification/add_notification_usecase.dart';
import '../../domain/usecases/notification/get_notifications_usecase.dart';
import '../../domain/usecases/notification/manage_history_usecase.dart';
import '../../domain/usecases/notification/mark_notification_read_usecase.dart';
import '../../domain/usecases/notification/reset_notifications_usecase.dart';
import '../../domain/usecases/notification/restore_history_usecase.dart';
import 'auth_provider.dart';

export '../../domain/entities/campus_notification.dart';
export '../../domain/entities/notification_sound_option.dart';
export '../../data/services/push_service_impl.dart'
    show updateNativeLauncherBadge;

// Data Source Provider
final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>((ref) {
  final tokenStorage = ref.watch(tokenLocalDataSourceProvider);
  return NotificationLocalDataSourceImpl(storage: tokenStorage);
});

// Repository Provider (DIP)
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final localDataSource = ref.watch(notificationLocalDataSourceProvider);
  return NotificationRepositoryImpl(localDataSource: localDataSource);
});

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return PushService.instance;
});

// Domain Use Case Providers
final getNotificationsUseCaseProvider =
    Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

final addNotificationUseCaseProvider = Provider<AddNotificationUseCase>((ref) {
  return AddNotificationUseCase(
    notificationRepository: ref.watch(notificationRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
});

final markNotificationReadUseCaseProvider =
    Provider<MarkNotificationReadUseCase>((ref) {
  return MarkNotificationReadUseCase(
    notificationRepository: ref.watch(notificationRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
});

final resetNotificationsUseCaseProvider =
    Provider<ResetNotificationsUseCase>((ref) {
  return ResetNotificationsUseCase(
    notificationRepository: ref.watch(notificationRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
});

final restoreHistoryUseCaseProvider = Provider<RestoreHistoryUseCase>((ref) {
  return RestoreHistoryUseCase(
    notificationRepository: ref.watch(notificationRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
});

final manageHistoryUseCaseProvider = Provider<ManageHistoryUseCase>((ref) {
  return ManageHistoryUseCase(
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

// Domain Controller Provider ("Domain ibarat controller")
final notificationControllerProvider =
    Provider<NotificationController>((ref) {
  return NotificationController(
    getNotificationsUseCase: ref.watch(getNotificationsUseCaseProvider),
    addNotificationUseCase: ref.watch(addNotificationUseCaseProvider),
    markNotificationReadUseCase: ref.watch(markNotificationReadUseCaseProvider),
    resetNotificationsUseCase: ref.watch(resetNotificationsUseCaseProvider),
    restoreHistoryUseCase: ref.watch(restoreHistoryUseCaseProvider),
    manageHistoryUseCase: ref.watch(manageHistoryUseCaseProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );
});

/// Provider untuk Daftar Notifikasi yang BELUM DIBACA (Home)
class NotificationNotifier extends Notifier<List<CampusNotification>> {
  @override
  List<CampusNotification> build() {
    _loadFromStorage();
    final defaultList = GetNotificationsUseCase.getDefaultNotifications();
    ref.read(notificationServiceProvider).updateLauncherBadge(defaultList.length);
    return defaultList;
  }

  Future<void> _loadFromStorage() async {
    try {
      final list = await ref
          .read(notificationControllerProvider)
          .loadActiveNotifications();
      if (list.isNotEmpty && ref.mounted) {
        state = list;
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void addNotification(
    CampusNotification notification, {
    bool showPush = true,
    NotificationSoundOption? sound,
  }) {
    final controller = ref.read(notificationControllerProvider);
    final updated = controller.prepareAddNotification(
      currentList: state,
      notification: notification,
    );
    if (identical(updated, state)) return;

    final itemWithNumber = updated.firstWhere((n) => n.id == notification.id);
    state = updated;

    controller.persistNotification(
      updatedList: updated,
      item: itemWithNumber,
      showPush: showPush,
      sound: sound,
    );
  }

  /// Membaca notifikasi: hilang dari belum dibaca, masuk ke riwayat dibaca
  void markAsRead(String id) {
    final item =
        state.where((n) => n.id == id || n.announcementId == id).firstOrNull;
    if (item != null) {
      ref.read(readHistoryProvider.notifier).addToHistory(item.copyWith(isRead: true));
    }

    final updated =
        state.where((n) => n.id != id && n.announcementId != id).toList();
    state = updated;

    ref.read(notificationControllerProvider).persistMarkAsRead(
      activeList: updated,
      id: id,
    );
  }

  /// Reset ke 3 notifikasi default untuk demonstrasi ke dosen
  void resetToThreeNotifications() {
    final defaultList = GetNotificationsUseCase.getDefaultNotifications();
    state = defaultList;
    ref.read(notificationControllerProvider).resetToDefault();
  }

  void restoreFromHistory(List<CampusNotification> items) async {
    try {
      final restored = await ref
          .read(notificationControllerProvider)
          .restoreFromHistory(
            currentActive: state,
            itemsToRestore: items,
          );
      state = restored;
    } catch (e) {
      debugPrint('Error restoring from history: $e');
    }
  }

  void clearAll() {
    state = [];
    ref.read(notificationControllerProvider).clearAllActive();
  }
}

final notificationListProvider =
    NotifierProvider<NotificationNotifier, List<CampusNotification>>(
  NotificationNotifier.new,
);

/// Provider untuk RIWAYAT NOTIFIKASI yang sudah dibaca
class ReadHistoryNotifier extends Notifier<List<CampusNotification>> {
  @override
  List<CampusNotification> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    try {
      final history =
          await ref.read(notificationControllerProvider).loadHistory();
      if (ref.mounted) {
        state = history;
      }
    } catch (_) {}
  }

  void setHistory(List<CampusNotification> history) {
    state = history;
  }

  void addToHistory(CampusNotification item) {
    if (state.any((n) => n.id == item.id)) return;
    final updated = [item.copyWith(isRead: true), ...state];
    state = updated;
    ref.read(notificationControllerProvider).persistHistory(updated);
  }

  void deleteItem(String id) {
    final updated = state.where((n) => n.id != id).toList();
    state = updated;
    ref.read(notificationControllerProvider).persistHistory(updated);
  }

  void clearHistory() {
    state = [];
    ref.read(notificationControllerProvider).clearHistory();
  }

  void resetAndRestoreToActive() {
    final historyItems = [...state];
    state = [];
    ref.read(notificationControllerProvider).clearHistory();
    ref.read(notificationListProvider.notifier).restoreFromHistory(historyItems);
  }
}

final readHistoryProvider =
    NotifierProvider<ReadHistoryNotifier, List<CampusNotification>>(
  ReadHistoryNotifier.new,
);

/// Provider untuk jumlah notifikasi belum dibaca (Home & Badge)
final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationListProvider);
  return list.where((n) => !n.isRead).length;
});

class FcmTokenNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setToken(String token) {
    state = token;
  }
}

final fcmTokenProvider =
    NotifierProvider<FcmTokenNotifier, String>(FcmTokenNotifier.new);
