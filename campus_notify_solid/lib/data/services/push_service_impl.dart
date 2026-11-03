import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/campus_notification.dart';
import '../../domain/entities/notification_sound_option.dart';
import '../../domain/repositories/notification_service.dart';

const MethodChannel _badgeChannel =
    MethodChannel('com.example.campus_notify/badge');

Future<void> updateNativeLauncherBadge(int count) async {
  try {
    await _badgeChannel.invokeMethod('updateBadge', {'count': count});
  } catch (e) {
    debugPrint('[Badge] MethodChannel error: $e');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint("Handling background message: ${message.messageId}");
}

class PushService implements NotificationService {
  PushService._();
  static final PushService instance = PushService._();

  static const String channelId = 'campus_channel_v1';
  static const String channelName = 'Pengumuman Kampus';
  static const String channelDescription =
      'Notifikasi penting pengumuman kampus dengan suara';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  AudioPlayer? _audioPlayer;
  AudioPlayer get _player => _audioPlayer ??= AudioPlayer();

  NotificationSoundOption _selectedSound = NotificationSoundOption.chime;
  @override
  NotificationSoundOption get selectedSound => _selectedSound;

  @override
  void setSelectedSound(NotificationSoundOption sound) {
    _selectedSound = sound;
  }

  bool _initialized = false;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  ProviderContainer? _container;
  ProviderContainer? get container => _container;
  void setContainer(ProviderContainer container) {
    _container = container;
  }

  void Function(String id)? onNotificationTap;
  void Function(CampusNotification notification)? onIncomingNotification;
  void Function(String token)? onTokenReceived;

  /// Memutar preview suara nada notifikasi (seperti di WhatsApp)
  @override
  Future<void> playPreviewSound([NotificationSoundOption? sound]) async {
    final target = sound ?? _selectedSound;
    try {
      await _player.stop();
      if (target.fileName != null) {
        await _player.play(AssetSource('sounds/${target.fileName}'));
      } else {
        await SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      debugPrint('[PushService] Error playing preview sound: $e');
    }
  }

  /// Inisialisasi awal Firebase & Push Notifications (dipanggil di main)
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Inisialisasi Firebase Core
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      debugPrint('[PushService] Firebase.initializeApp berhasil.');
    } catch (e) {
      debugPrint('[PushService] Firebase.initializeApp warning: $e');
    }

    // 1. Setup Semua Android Notification Channels untuk Pilihan Suara
    final channels = [
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
        showBadge: true,
      ),
      const AndroidNotificationChannel(
        'campus_channel_chime',
        'Pengumuman - Chime Kampus',
        description: 'Notifikasi dengan nada Chime Kampus',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
        showBadge: true,
      ),
      const AndroidNotificationChannel(
        'campus_channel_bell',
        'Pengumuman - Bell Harmony',
        description: 'Notifikasi dengan nada Bell Harmony',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('sound_bell'),
        enableVibration: true,
        showBadge: true,
      ),
      const AndroidNotificationChannel(
        'campus_channel_pop',
        'Pengumuman - Pop Bubble',
        description: 'Notifikasi dengan nada Pop Bubble',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('sound_pop'),
        enableVibration: true,
        showBadge: true,
      ),
      const AndroidNotificationChannel(
        'campus_channel_default',
        'Pengumuman - Default Sistem',
        description: 'Notifikasi dengan nada bawaan sistem Android',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    ];

    // 2. Setup Flutter Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    try {
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            onNotificationTap?.call(payload);
          }
        },
      );

      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        for (final ch in channels) {
          await androidPlugin.createNotificationChannel(ch);
        }
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('[PushService] Android Notification Permission granted: $granted');
      }
    } catch (e) {
      debugPrint('[PushService] Local notifications init error: $e');
    }

    // 3. Setup Firebase Cloud Messaging
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[PushService] FCM AuthorizationStatus: ${settings.authorizationStatus}');

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await messaging.subscribeToTopic('pengumuman-kampus');
      debugPrint('[PushService] Berhasil subscribe ke topik: pengumuman-kampus');

      // ignore: deprecated_member_use
      _fcmToken = await messaging.getToken();
      debugPrint('====================================================');
      debugPrint('FCM TOKEN DEVICE: $_fcmToken');
      debugPrint('====================================================');

      if (_fcmToken != null) {
        onTokenReceived?.call(_fcmToken!);
      }

      // ignore: deprecated_member_use
      messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        onTokenReceived?.call(newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[PushService] FCM onMessage received: ${message.notification?.title}');
        _handleIncomingMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[PushService] FCM onMessageOpenedApp: ${message.messageId}');
        final id = message.data['id'] ??
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString();
        onNotificationTap?.call(id);
      });

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        final id = initialMessage.data['id'] ?? initialMessage.messageId ?? '';
        if (id.isNotEmpty) {
          onNotificationTap?.call(id);
        }
      }
    } catch (e) {
      debugPrint('[PushService] FCM Messaging init warning: $e');
    }
  }

  /// Menampilkan notifikasi lokal dengan suara yang dipilih
  @override
  Future<void> showNotification({
    required String id,
    required String title,
    required String body,
    String? payload,
    NotificationSoundOption? sound,
  }) async {
    final activeSound = sound ?? _selectedSound;

    // Putar suara di aplikasi
    playPreviewSound(activeSound);

    final androidDetails = AndroidNotificationDetails(
      activeSound.channelId,
      'Pengumuman - ${activeSound.name}',
      channelDescription: 'Notifikasi pengumuman kampus',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: activeSound.rawResource != null
          ? RawResourceAndroidNotificationSound(activeSound.rawResource!)
          : null,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);
    final notificationId = id.hashCode & 0x7FFFFFFF;

    try {
      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload ?? id,
      );
    } catch (e) {
      debugPrint('[PushService] Error showing local notification: $e');
    }
  }

  @override
  Future<void> cancelNotification(String id) async {
    try {
      await _localNotifications.cancel(id: id.hashCode & 0x7FFFFFFF);
    } catch (_) {}
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
    } catch (_) {}
  }

  @override
  Future<void> updateLauncherBadge(int count) async {
    await updateNativeLauncherBadge(count);
  }

  void _handleIncomingMessage(RemoteMessage message) {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Pengumuman Baru';
    final body = message.notification?.body ??
        message.data['body'] ??
        'Anda memiliki pengumuman kampus baru.';
    final id = message.data['id'] ??
        message.messageId ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final notification = CampusNotification(
      id: id,
      number: 0,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      announcementId: message.data['id'] ?? id,
    );

    if (onIncomingNotification != null) {
      onIncomingNotification!(notification);
    }

    showNotification(
      id: id,
      title: title,
      body: body,
      payload: id,
    );
  }

  /// Simulasi notifikasi untuk pengujian instan
  void simulateNotification({String? customTitle, String? customBody}) {
    final now = DateTime.now();
    final id = 'sim-${now.millisecondsSinceEpoch}';
    final title = customTitle ?? 'Pengumuman Kuliah Tambahan';
    final body = customBody ??
        'Ada pengumuman baru dari bagian akademik. Ketuk untuk membaca detail pengumuman.';

    final notification = CampusNotification(
      id: id,
      number: 0,
      title: title,
      body: body,
      timestamp: now,
      announcementId: id,
    );

    if (onIncomingNotification != null) {
      onIncomingNotification!(notification);
    }

    showNotification(
      id: id,
      title: title,
      body: body,
      payload: id,
    );
  }
}
