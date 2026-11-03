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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CampusNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          number == other.number &&
          title == other.title &&
          body == other.body &&
          timestamp == other.timestamp &&
          announcementId == other.announcementId &&
          isRead == other.isRead;

  @override
  int get hashCode =>
      id.hashCode ^
      number.hashCode ^
      title.hashCode ^
      body.hashCode ^
      timestamp.hashCode ^
      announcementId.hashCode ^
      isRead.hashCode;
}
