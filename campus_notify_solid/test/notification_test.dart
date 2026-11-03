import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_notify/presentation/providers/notification_provider.dart';
import 'package:campus_notify/data/repositories/auth_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Requirement 2 & 3: Notification List, Badge Count & History', () {
    test('Initial notifications are present in list with count 3', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifications = container.read(notificationListProvider);
      final count = container.read(unreadNotificationCountProvider);

      expect(notifications.length, equals(3));
      expect(count, equals(3));
      expect(notifications[0].number, equals(1));
      expect(notifications[1].number, equals(2));
      expect(notifications[2].number, equals(3));
    });

    test('Adding notification updates list and increments icon badge count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialCount = container.read(unreadNotificationCountProvider);

      final newNotif = CampusNotification(
        id: 'test-100',
        number: 4,
        title: 'Pengumuman Penting Kuliah Tamu',
        body: 'Kuliah tamu akan diadakan besok pukul 09.00 di Aula.',
        timestamp: DateTime.now(),
        announcementId: '100',
      );

      container.read(notificationListProvider.notifier).addNotification(newNotif);

      final updatedList = container.read(notificationListProvider);
      final updatedCount = container.read(unreadNotificationCountProvider);

      expect(updatedList.any((n) => n.id == 'test-100'), true);
      expect(updatedCount, equals(initialCount + 1));
    });

    test('When notification is read, it disappears from list and enters history', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final newNotif = CampusNotification(
        id: 'to-be-read',
        number: 5,
        title: 'Notifikasi Uji Baca',
        body: 'Notifikasi ini harus hilang setelah dibaca.',
        timestamp: DateTime.now(),
      );

      container.read(notificationListProvider.notifier).addNotification(newNotif);
      expect(container.read(notificationListProvider).any((n) => n.id == 'to-be-read'), true);

      // Simulasikan dibaca
      container.read(notificationListProvider.notifier).markAsRead('to-be-read');

      final listAfterRead = container.read(notificationListProvider);
      final history = container.read(readHistoryProvider);

      expect(listAfterRead.any((n) => n.id == 'to-be-read'), false);
      expect(history.any((n) => n.id == 'to-be-read'), true);
    });
  });

  group('Requirement 1: Strict ReqRes API Password Validation', () {
    test('Validation fails on wrong password for ReqRes', () async {
      final repo = AuthRepositoryImpl();
      expect(
        () => repo.login(email: 'eve.holt@reqres.in', password: 'wrongpassword'),
        throwsA(isA<Exception>()),
      );
    });

    test('Validation fails on empty inputs', () async {
      final repo = AuthRepositoryImpl();
      expect(
        () => repo.login(email: '', password: ''),
        throwsA(isA<Exception>()),
      );
    });
  });
}
