import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_notify/pages/login_page.dart';

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
}
