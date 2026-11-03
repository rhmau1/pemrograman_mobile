import '../../domain/entities/campus_notification.dart';

class CampusNotificationModel extends CampusNotification {
  const CampusNotificationModel({
    required super.id,
    required super.number,
    required super.title,
    required super.body,
    required super.timestamp,
    super.announcementId,
    super.isRead = false,
  });

  factory CampusNotificationModel.fromEntity(CampusNotification entity) {
    return CampusNotificationModel(
      id: entity.id,
      number: entity.number,
      title: entity.title,
      body: entity.body,
      timestamp: entity.timestamp,
      announcementId: entity.announcementId,
      isRead: entity.isRead,
    );
  }

  factory CampusNotificationModel.fromJson(Map<String, dynamic> json) {
    return CampusNotificationModel(
      id: json['id'] as String? ?? '0',
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      announcementId: json['announcementId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
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
}
