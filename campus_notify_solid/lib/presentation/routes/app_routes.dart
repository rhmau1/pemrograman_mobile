abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const announcement = '/pengumuman/:id';

  static String announcementOf(String id) => '/pengumuman/$id';
}
