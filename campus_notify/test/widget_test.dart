import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_notify/pages/login_page.dart';
import 'package:campus_notify/pages/home_page.dart';

void main() {
  testWidgets('LoginPage renders input fields and single API login button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Campus Notify'), findsOneWidget);
    expect(find.text('Portal Pengumuman & Notifikasi Kampus'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.text('eve.holt@reqres.in'), findsAtLeastNWidgets(1));
  });

  testWidgets('HomePage displays Buat Notif Uji button and opens form modal', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tombol Buat Notif Uji tersedia
    final buttonFinder = find.text('Buat Notif Uji');
    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Form dialog bottom sheet muncul dengan input title & deskripsi
    expect(find.text('Buat Notifikasi Uji'), findsOneWidget);
    expect(find.text('Judul Notifikasi'), findsOneWidget);
    expect(find.text('Deskripsi Notifikasi'), findsOneWidget);
    expect(find.text('Kirim Notif'), findsOneWidget);

    // Isi input form judul & deskripsi
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contoh: Kuliah Pengganti Mobile Dev'),
      'Pengumuman Ujian Akhir',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tuliskan isi detail pengumuman notifikasi di sini...'),
      'Ujian akhir semester dilaksanakan tanggal 15.',
    );

    // Submit form
    await tester.tap(find.text('Kirim Notif'));
    await tester.pumpAndSettle();

    // Notifikasi baru dengan judul kustom tampil pada list
    expect(find.textContaining('Pengumuman Ujian Akhir'), findsAtLeastNWidgets(1));
  });
}
