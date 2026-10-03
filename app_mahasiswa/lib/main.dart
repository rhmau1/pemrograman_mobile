import 'package:app_mahasiswa/pages/mahasiswa_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Week 4 - REST API',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    home: const MahasiswaListPage(),
  );
}
