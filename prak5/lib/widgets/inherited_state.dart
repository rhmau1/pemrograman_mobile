import 'package:flutter/material.dart';

/// Kelompok 6: InheritedWidget for sharing state across the widget tree
class MusicAppThemeInherited extends InheritedWidget {
  final String appTitle;
  final String currentThemeMode;
  final VoidCallback onToggleTheme;

  const MusicAppThemeInherited({
    super.key,
    required this.appTitle,
    required this.currentThemeMode,
    required this.onToggleTheme,
    required super.child,
  });

  @override
  bool updateShouldNotify(MusicAppThemeInherited oldWidget) {
    return currentThemeMode != oldWidget.currentThemeMode ||
        appTitle != oldWidget.appTitle;
  }

  static MusicAppThemeInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MusicAppThemeInherited>();
  }
}
