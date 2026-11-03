enum NotificationSoundOption {
  chime(
    id: 'chime',
    name: 'Chime Kampus (Bawaan)',
    fileName: 'notification_sound.wav',
    rawResource: 'notification_sound',
    channelId: 'campus_channel_chime',
  ),
  bell(
    id: 'bell',
    name: 'Bell Harmony',
    fileName: 'sound_bell.wav',
    rawResource: 'sound_bell',
    channelId: 'campus_channel_bell',
  ),
  pop(
    id: 'pop',
    name: 'Pop Bubble',
    fileName: 'sound_pop.wav',
    rawResource: 'sound_pop',
    channelId: 'campus_channel_pop',
  ),
  systemDefault(
    id: 'default',
    name: 'Default Sistem HP',
    fileName: null,
    rawResource: null,
    channelId: 'campus_channel_default',
  );

  const NotificationSoundOption({
    required this.id,
    required this.name,
    required this.fileName,
    required this.rawResource,
    required this.channelId,
  });

  final String id;
  final String name;
  final String? fileName;
  final String? rawResource;
  final String channelId;
}
