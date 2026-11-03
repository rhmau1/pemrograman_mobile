import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/services/push_service_impl.dart';
import 'presentation/pages/announcement_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authChanges = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, _) => authChanges.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      if (auth.isLoading && !auth.hasValue) return null;
      final loggedIn = auth.value ?? false;
      final goingLogin = state.matchedLocation == '/login';
      if (!loggedIn && !goingLogin) return '/login';
      if (loggedIn && goingLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AnnouncementPage(id: id);
        },
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  PushService.instance.setContainer(container);

  await PushService.instance.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    PushService.instance.onNotificationTap = (id) {
      router.push('/pengumuman/$id');
    };

    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          primary: const Color(0xFF10B981),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
