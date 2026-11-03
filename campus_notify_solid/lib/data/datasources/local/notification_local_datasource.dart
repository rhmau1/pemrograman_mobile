import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../models/campus_notification_model.dart';
import 'token_local_datasource.dart';

abstract class NotificationLocalDataSource {
  Future<List<CampusNotificationModel>> getActiveNotifications();
  Future<void> saveActiveNotifications(List<CampusNotificationModel> notifications);
  Future<List<CampusNotificationModel>> getReadHistory();
  Future<void> saveReadHistory(List<CampusNotificationModel> history);
  Future<void> clearActiveNotifications();
  Future<void> clearReadHistory();
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  NotificationLocalDataSourceImpl({
    required this.storage,
  });

  final TokenLocalDataSource storage;
  static const _activeKey = 'cached_campus_notifications';
  static const _historyKey = 'cached_history_notifications';

  @override
  Future<List<CampusNotificationModel>> getActiveNotifications() async {
    try {
      final raw = await storage.readCustom(_activeKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        return decoded
            .map((e) => CampusNotificationModel.fromJson(e as Map<String, dynamic>))
            .where((n) => !n.isRead)
            .toList();
      }
    } catch (e) {
      debugPrint('[NotificationLocalDataSource] Error loading active notifications: $e');
    }
    return [];
  }

  @override
  Future<void> saveActiveNotifications(
    List<CampusNotificationModel> notifications,
  ) async {
    try {
      final jsonStr = jsonEncode(notifications.map((e) => e.toJson()).toList());
      await storage.writeCustom(_activeKey, jsonStr);
    } catch (e) {
      debugPrint('[NotificationLocalDataSource] Error saving active notifications: $e');
    }
  }

  @override
  Future<List<CampusNotificationModel>> getReadHistory() async {
    try {
      final raw = await storage.readCustom(_historyKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List;
        return decoded
            .map((e) => CampusNotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[NotificationLocalDataSource] Error loading history: $e');
    }
    return [];
  }

  @override
  Future<void> saveReadHistory(List<CampusNotificationModel> history) async {
    try {
      final jsonStr = jsonEncode(history.map((e) => e.toJson()).toList());
      await storage.writeCustom(_historyKey, jsonStr);
    } catch (e) {
      debugPrint('[NotificationLocalDataSource] Error saving history: $e');
    }
  }

  @override
  Future<void> clearActiveNotifications() async {
    await storage.deleteCustom(_activeKey);
  }

  @override
  Future<void> clearReadHistory() async {
    await storage.deleteCustom(_historyKey);
  }
}
