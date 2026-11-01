import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../messaging/push_service.dart';
import 'auth_provider.dart';

class CampusNotification {
  const CampusNotification({
    required this.id,
    required this.number,
    required this.title,
    required this.body,
    required this.timestamp,
    this.announcementId,
    this.isRead = false,
  });

  final String id;
  final int number; // Nomor urut notifikasi: 1, 2, 3...
  final String title;
  final String body;
  final DateTime timestamp;
  final String? announcementId;
  final bool isRead;

  CampusNotification copyWith({
    String? id,
    int? number,
    String? title,
    String? body,
    DateTime? timestamp,
    String? announcementId,
    bool? isRead,
  }) {
    return CampusNotification(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      announcementId: announcementId ?? this.announcementId,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'announcementId': announcementId,
        'isRead': isRead,
      };

  factory CampusNotification.fromJson(Map<String, dynamic> json) {
    return CampusNotification(
      id: json['id'] as String? ?? '',
      number: json['number'] as int? ?? 1,
      title: json['title'] as String? ?? 'Pengumuman Kampus',
      body: json['body'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      announcementId: json['announcementId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

const MethodChannel _badgeChannel = MethodChannel('com.example.campus_notify/badge');

void updateNativeLauncherBadge(int count) async {
  try {
    await _badgeChannel.invokeMethod('updateBadge', {'count': count});
  } catch (e) {
    debugPrint('[Badge] MethodChannel error: $e');
  }
}

/// Provider untuk Daftar Notifikasi yang BELUM DIBACA (Home)
class NotificationNotifier extends Notifier<List<CampusNotification>> {
  static const _storageKey = 'cached_campus_notifications';
  int _globalCounter = 3;

  @override
  List<CampusNotification> build() {
    _loadFromStorage();

    final now = DateTime.now();
    final defaultList = [
      CampusNotification(
        id: '1',
        number: 1,
        title: 'Pengumuman #1 - Jadwal Kuliah Pemrograman Mobile',
        body: 'Perkuliahan semester ini dilaksanakan secara tatap muka di Lab Komputer Gedung TI lantai 2.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        announcementId: '1',
      ),
      CampusNotification(
        id: '2',
        number: 2,
        title: 'Pengumuman #2 - Pengisian KRS Semester Baru',
        body: 'Pengisian KRS dibuka mulai tanggal 10. Harap segera konsultasi dengan DPA sebelum batas akhir.',
        timestamp: now.subtract(const Duration(minutes: 10)),
        announcementId: '2',
      ),
      CampusNotification(
        id: '3',
        number: 3,
        title: 'Pengumuman #3 - Perubahan Ruang Kuliah Tamu',
        body: 'Kuliah tamu pakar industri dipindahkan ke Aula Utama Lantai 3 pukul 13.00 WIB.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        announcementId: '3',
      ),
    ];

    updateNativeLauncherBadge(defaultList.length);
    return defaultList;
  }

  Future<void> _loadFromStorage() async {
    try {
      final store = ref.read(tokenStoreProvider);
      final raw = await store.readCustom(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final list = (jsonDecode(raw) as List)
            .map((e) => CampusNotification.fromJson(e as Map<String, dynamic>))
            .where((n) => !n.isRead)
            .toList();
        if (list.isNotEmpty) {
          list.sort((a, b) => a.number.compareTo(b.number));
          state = list;
          _globalCounter = list.map((e) => e.number).fold(0, (max, v) => v > max ? v : max);
          updateNativeLauncherBadge(list.length);
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final store = ref.read(tokenStoreProvider);
      final jsonStr = jsonEncode(state.map((e) => e.toJson()).toList());
      await store.writeCustom(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  void addNotification(CampusNotification notification) {
    final existingIndex = state.indexWhere((n) => n.id == notification.id);
    if (existingIndex >= 0) return;

    _globalCounter++;
    final assignedNumber = notification.number > 0 ? notification.number : _globalCounter;

    final itemWithNumber = notification.copyWith(
      number: assignedNumber,
      title: notification.title.startsWith('Pengumuman #')
          ? notification.title
          : 'Pengumuman #$assignedNumber - ${notification.title}',
    );

    final updated = [...state, itemWithNumber];
    updated.sort((a, b) => a.number.compareTo(b.number));
    state = updated;
    _saveToStorage();
    updateNativeLauncherBadge(updated.length);
  }

  /// Membaca notifikasi: hilang dari belum dibaca, masuk ke riwayat dibaca
  void markAsRead(String id) {
    final item = state.where((n) => n.id == id || n.announcementId == id).firstOrNull;
    if (item != null) {
      ref.read(readHistoryProvider.notifier).addToHistory(item.copyWith(isRead: true));
    }

    state = state.where((n) => n.id != id && n.announcementId != id).toList();
    _saveToStorage();

    PushService.instance.cancelNotification(id);
    updateNativeLauncherBadge(state.length);
    if (state.isEmpty) {
      PushService.instance.cancelAllNotifications();
    }
  }

  /// Reset ke 3 notifikasi default untuk demonstrasi ke dosen
  void resetToThreeNotifications() {
    _globalCounter = 3;
    final now = DateTime.now();
    state = [
      CampusNotification(
        id: '1',
        number: 1,
        title: 'Pengumuman #1 - Jadwal Kuliah Pemrograman Mobile',
        body: 'Perkuliahan semester ini dilaksanakan secara tatap muka di Lab Komputer Gedung TI lantai 2.',
        timestamp: now.subtract(const Duration(minutes: 15)),
        announcementId: '1',
      ),
      CampusNotification(
        id: '2',
        number: 2,
        title: 'Pengumuman #2 - Pengisian KRS Semester Baru',
        body: 'Pengisian KRS dibuka mulai tanggal 10. Harap segera konsultasi dengan DPA sebelum batas akhir.',
        timestamp: now.subtract(const Duration(minutes: 10)),
        announcementId: '2',
      ),
      CampusNotification(
        id: '3',
        number: 3,
        title: 'Pengumuman #3 - Perubahan Ruang Kuliah Tamu',
        body: 'Kuliah tamu pakar industri dipindahkan ke Aula Utama Lantai 3 pukul 13.00 WIB.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        announcementId: '3',
      ),
    ];
    _saveToStorage();
    updateNativeLauncherBadge(3);
  }

  void restoreFromHistory(List<CampusNotification> items) {
    final active = [...state];
    for (final item in items) {
      if (!active.any((n) => n.id == item.id)) {
        active.add(item.copyWith(isRead: false));
      }
    }
    active.sort((a, b) => a.number.compareTo(b.number));
    state = active;
    _saveToStorage();
    updateNativeLauncherBadge(state.length);
  }

  void clearAll() {
    state = [];
    _saveToStorage();
    updateNativeLauncherBadge(0);
    PushService.instance.cancelAllNotifications();
  }
}

final notificationListProvider =
    NotifierProvider<NotificationNotifier, List<CampusNotification>>(
  NotificationNotifier.new,
);

/// Provider untuk RIWAYAT NOTIFIKASI yang sudah dibaca
class ReadHistoryNotifier extends Notifier<List<CampusNotification>> {
  static const _historyKey = 'cached_history_notifications';

  @override
  List<CampusNotification> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    try {
      final store = ref.read(tokenStoreProvider);
      final raw = await store.readCustom(_historyKey);
      if (raw != null && raw.isNotEmpty) {
        final list = (jsonDecode(raw) as List)
            .map((e) => CampusNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        state = list;
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final store = ref.read(tokenStoreProvider);
      final jsonStr = jsonEncode(state.map((e) => e.toJson()).toList());
      await store.writeCustom(_historyKey, jsonStr);
    } catch (_) {}
  }

  void addToHistory(CampusNotification item) {
    if (state.any((n) => n.id == item.id)) return;
    state = [item, ...state];
    _save();
  }

  void deleteItem(String id) {
    state = state.where((n) => n.id != id).toList();
    _save();
  }

  void clearHistory() {
    state = [];
    _save();
  }

  void resetAndRestoreToActive() {
    final historyItems = [...state];
    state = [];
    _save();
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
