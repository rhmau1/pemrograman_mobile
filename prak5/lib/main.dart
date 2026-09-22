import 'package:flutter/material.dart';

import 'lirik.dart';
import 'screens/music_player_screen.dart';
import 'widgets/inherited_state.dart';

void main() {
  runApp(const MyApp());
}

/// Kelompok 6: StatelessWidget - Application Root
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentTheme = "Dark";

  void _toggleTheme() {
    setState(() {
      _currentTheme = (_currentTheme == "Dark") ? "Light" : "Dark";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kelompok 6: InheritedWidget wrapping MaterialApp
    return MusicAppThemeInherited(
      appTitle: "Spotilite Mobile",
      currentThemeMode: _currentTheme,
      onToggleTheme: _toggleTheme,
      // Kelompok 2: MaterialApp
      child: MaterialApp(
        title: 'Spotilite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFF1DB954),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF1DB954),
            secondary: Color(0xFF1ED760),
            surface: Color(0xFF1E1E1E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
          ),
          cardColor: const Color(0xFF181818),
          useMaterial3: true,
        ),
        home: const MainMusicContainer(),
      ),
    );
  }
}

/// Kelompok 6: StatefulWidget - Shared Music App Container
class MainMusicContainer extends StatefulWidget {
  const MainMusicContainer({super.key});

  @override
  State<MainMusicContainer> createState() => _MainMusicContainerState();
}

class _MainMusicContainerState extends State<MainMusicContainer> {
  List<Lirik> songs = getSampleSongs();
  int currentSongIndex = 0;

  // Playlist state
  String playlistName = "Lagu Favorit Terbaik 2026";
  String playlistDescription =
      "Koleksi lagu anak Indonesia paling populer dan menyenangkan sepanjang masa.";
  bool isPrivate = false;
  String privacyType = "Publik";
  bool allowComments = true;
  String authorName = "Fijriati Rahmatur R";

  void selectSong(int index) {
    if (index >= 0 && index < songs.length) {
      setState(() {
        currentSongIndex = index;
      });
    }
  }

  void nextSong() {
    setState(() {
      currentSongIndex = (currentSongIndex + 1) % songs.length;
    });
  }

  void previousSong() {
    setState(() {
      currentSongIndex = (currentSongIndex - 1 + songs.length) % songs.length;
    });
  }

  void addSong(Lirik newSong) {
    setState(() {
      songs.add(newSong);
    });
  }

  void reorderSongs(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final song = songs.removeAt(oldIndex);
      songs.insert(newIndex, song);
    });
  }

  void updatePlaylistDetails(
    String name,
    String description,
    bool private,
    String privacy,
  ) {
    setState(() {
      playlistName = name;
      playlistDescription = description;
      isPrivate = private;
      privacyType = privacy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Fijri(
      songs: songs,
      currentSongIndex: currentSongIndex,
      playlistName: playlistName,
      playlistDescription: playlistDescription,
      isPrivate: isPrivate,
      privacyType: privacyType,
      allowComments: allowComments,
      authorName: authorName,
      onSelectSong: selectSong,
      onNextSong: nextSong,
      onPreviousSong: previousSong,
      onAddSong: addSong,
      onReorderSongs: reorderSongs,
      onUpdatePlaylist: updatePlaylistDetails,
    );
  }
}
