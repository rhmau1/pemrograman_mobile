import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../lirik.dart';
import 'playlist_screen.dart';
import 'widget_catalog_screen.dart';

/// Kelompok 6: StatefulWidget - Main Lyric & Music Player Screen (Fijri)
class Fijri extends StatefulWidget {
  final List<Lirik> songs;
  final int currentSongIndex;
  final String playlistName;
  final String playlistDescription;
  final bool isPrivate;
  final String privacyType;
  final bool allowComments;
  final String authorName;
  final Function(int) onSelectSong;
  final VoidCallback onNextSong;
  final VoidCallback onPreviousSong;
  final Function(Lirik) onAddSong;
  final Function(int, int) onReorderSongs;
  final Function(String, String, bool, String) onUpdatePlaylist;

  const Fijri({
    super.key,
    required this.songs,
    required this.currentSongIndex,
    required this.playlistName,
    required this.playlistDescription,
    required this.isPrivate,
    required this.privacyType,
    required this.allowComments,
    required this.authorName,
    required this.onSelectSong,
    required this.onNextSong,
    required this.onPreviousSong,
    required this.onAddSong,
    required this.onReorderSongs,
    required this.onUpdatePlaylist,
  });

  @override
  State<Fijri> createState() => _FijriState();
}

class _FijriState extends State<Fijri> {
  late AudioPlayer player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Kelompok 6: ValueNotifier for Volume Control state without re-rendering entire screen
  final ValueNotifier<double> _volumeNotifier = ValueNotifier<double>(0.8);
  late PageController _pageController;
  bool _isPageAnimating = false;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _pageController = PageController(initialPage: widget.currentSongIndex);

    player.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    player.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant Fijri oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSongIndex != widget.currentSongIndex) {
      _position = Duration.zero;
      if (_pageController.hasClients && _pageController.page?.round() != widget.currentSongIndex) {
        _isPageAnimating = true;
        _pageController
            .animateToPage(
              widget.currentSongIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {
          _isPageAnimating = false;
        });
      }
      if (_isPlaying) {
        _playCurrentSong();
      }
    }
  }

  @override
  void dispose() {
    player.dispose();
    _pageController.dispose();
    _volumeNotifier.dispose();
    super.dispose();
  }

  Future<void> _playCurrentSong() async {
    try {
      if (widget.songs.isEmpty || widget.currentSongIndex < 0 || widget.currentSongIndex >= widget.songs.length) {
        return;
      }
      final currentSong = widget.songs[widget.currentSongIndex];
      await player.stop();
      String audioPath = currentSong.audioAsset;
      if (audioPath.startsWith('assets/')) {
        audioPath = audioPath.substring('assets/'.length);
      }
      await player.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await player.pause();
      } else {
        await _playCurrentSong();
      }
    } catch (e) {
      debugPrint("Error toggling play/pause: $e");
    }
  }

  void _showSongOptionBottomSheet(BuildContext context, Lirik song) {
    // Kelompok 8: showModalBottomSheet & BottomSheet
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(song.imageAsset, width: 50, height: 50, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text(song.pencipta, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF1DB954)),
              title: const Text('Bagikan Lagu (BottomSheet Action)'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tautan lagu "${song.judul}" telah disalin.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.lightBlueAccent),
              title: const Text('Detail Genre & Durasi'),
              subtitle: Text('Genre: ${song.genre} • Durasi: ${song.duration}'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.songs[widget.currentSongIndex];

    // Kelompok 2: Scaffold
    return Scaffold(
      // Kelompok 2: AppBar
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "PLAYING FROM PLAYLIST",
              style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.grey),
            ),
            Text(
              currentSong.judul,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Kelompok 8: Tooltip
          Tooltip(
            message: currentSong.isFavorite ? 'Hapus dari Favorit' : 'Sukai Lagu Ini',
            child: IconButton(
              icon: Icon(
                currentSong.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: currentSong.isFavorite ? const Color(0xFF1DB954) : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  currentSong.isFavorite = !currentSong.isFavorite;
                });
                // Kelompok 8: SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                      currentSong.isFavorite ? 'Ditambahkan ke Favorit' : 'Dihapus dari Favorit',
                    ),
                  ),
                );
              },
            ),
          ),
          // Kelompok 4: PopupMenuButton
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF282828),
            onSelected: (value) {
              if (value == 'playlist') {
                // Kelompok 9: Navigator & PageRouteBuilder
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) => SpotifyPlaylistScreen(
                      songs: widget.songs,
                      playlistName: widget.playlistName,
                      playlistDescription: widget.playlistDescription,
                      isPrivate: widget.isPrivate,
                      privacyType: widget.privacyType,
                      allowComments: widget.allowComments,
                      authorName: widget.authorName,
                      onSelectSong: (index) {
                        widget.onSelectSong(index);
                        if (_isPlaying) _playCurrentSong();
                      },
                      onAddSong: widget.onAddSong,
                      onReorderSongs: widget.onReorderSongs,
                      onUpdatePlaylist: widget.onUpdatePlaylist,
                    ),
                    transitionsBuilder: (context, anim1, anim2, child) {
                      return FadeTransition(opacity: anim1, child: child);
                    },
                  ),
                );
              } else if (value == 'catalog') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const WidgetCatalogScreen()),
                );
              } else if (value == 'options') {
                _showSongOptionBottomSheet(context, currentSong);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'playlist',
                child: Row(
                  children: [
                    Icon(Icons.queue_music, color: Color(0xFF1DB954)),
                    SizedBox(width: 10),
                    Text('Buka Playlist Screen'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'options',
                child: Row(
                  children: [
                    Icon(Icons.tune, color: Colors.amber),
                    SizedBox(width: 10),
                    Text('Opsi & Detail Lagu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'catalog',
                child: Row(
                  children: [
                    Icon(Icons.widgets, color: Colors.deepPurpleAccent),
                    SizedBox(width: 10),
                    Text('Katalog 10 Kelompok Widget'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // Kelompok 2: Drawer & Kelompok 9: Drawer navigation
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E1E),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1DB954), Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage(currentSong.imageAsset),
              ),
              accountName: const Text(
                "Spotilite Player",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text("Total Koleksi: ${widget.songs.length} Lagu"),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.library_music, color: Color(0xFF1DB954)),
                  SizedBox(width: 10),
                  Text(
                    "Daftar Lagu (Swipe/Tap)",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            // Kelompok 10: ListView
            Expanded(
              child: ListView.builder(
                itemCount: widget.songs.length,
                itemBuilder: (context, index) {
                  final song = widget.songs[index];
                  final isSelected = index == widget.currentSongIndex;
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        song.imageAsset,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.judul,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF1DB954) : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      song.pencipta,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1DB954).withValues(alpha: 0.8) : Colors.grey,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.graphic_eq, color: Color(0xFF1DB954))
                        : Text(song.duration, style: const TextStyle(color: Colors.grey)),
                    tileColor: isSelected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
                    onTap: () {
                      widget.onSelectSong(index);
                      Navigator.pop(context);
                      if (_isPlaying) {
                        _playCurrentSong();
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.widgets, color: Colors.deepPurpleAccent),
              title: const Text("Katalog Semua Widget"),
              subtitle: const Text("Tampilkan showcase 10 kelompok widget"),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const WidgetCatalogScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // Kelompok 2: SafeArea
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              // Kelompok 10: PageView (Swipeable Album Cover Carousel)
              Expanded(
                flex: 4,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.songs.length,
                  onPageChanged: (index) {
                    if (_isPageAnimating) return;
                    if (index != widget.currentSongIndex) {
                      widget.onSelectSong(index);
                      if (_isPlaying) _playCurrentSong();
                    }
                  },
                  itemBuilder: (context, index) {
                    final songItem = widget.songs[index];
                    return Center(
                      // Kelompok 1: Stack for image overlay
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Kelompok 7: Hero animation
                          Hero(
                            tag: 'album_cover_${songItem.id}',
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  songItem.imageAsset,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 250,
                                    width: double.infinity,
                                    color: Colors.grey.shade900,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.music_note, size: 80, color: Color(0xFF1DB954)),
                                        SizedBox(height: 8),
                                        Text("Cover Music", style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Kelompok 2: Align & Kelompok 1: Container overlay badge
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Kelompok 3: ImageIcon
                                  const ImageIcon(
                                    AssetImage('assets/images/p.jpg'),
                                    size: 14,
                                    color: Color(0xFF1DB954),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    songItem.genre,
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Kelompok 1: Row with Title, Pencipta & Action Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kelompok 1: Expanded & Flexible
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kelompok 3: Text & TextStyle
                        Text(
                          currentSong.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Kelompok 3: Flexible + RichText styling
                        Text(
                          'Pencipta: ${currentSong.pencipta}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Kelompok 4: IconButton
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.white60, size: 28),
                    onPressed: () => _showSongOptionBottomSheet(context, currentSong),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Kelompok 3: SelectableText for lyrics & Kelompok 10: Scrollbar + SingleChildScrollView
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        currentSong.lirik,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 1.6,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Kelompok 2: BottomNavigationBar with audio player seekbar & volume control
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF181818),
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kelompok 5: Slider for Seek Position
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF1DB954),
                  inactiveTrackColor: Colors.grey.shade800,
                  thumbColor: Colors.white,
                  trackHeight: 4,
                ),
                child: Slider(
                  min: 0.0,
                  max: _duration.inMilliseconds.toDouble() > 0
                      ? _duration.inMilliseconds.toDouble()
                      : 1.0,
                  value: _position.inMilliseconds.toDouble().clamp(
                        0.0,
                        _duration.inMilliseconds.toDouble() > 0
                            ? _duration.inMilliseconds.toDouble()
                            : 1.0,
                      ),
                  onChanged: (value) async {
                    final position = Duration(milliseconds: value.toInt());
                    await player.seek(position);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Player Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mode Acak diaktifkan')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 36, color: Colors.white),
                    onPressed: () {
                      widget.onPreviousSong();
                      if (_isPlaying) _playCurrentSong();
                    },
                  ),
                  // Kelompok 7: AnimatedSwitcher for smooth Play/Pause transition
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1DB954),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: IconButton(
                        key: ValueKey<bool>(_isPlaying),
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                          color: Colors.black,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 36, color: Colors.white),
                    onPressed: () {
                      widget.onNextSong();
                      if (_isPlaying) _playCurrentSong();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mode Ulang diaktifkan')),
                      );
                    },
                  ),
                ],
              ),

              // Kelompok 6: ValueListenableBuilder for reactive Volume Bar Slider
              ValueListenableBuilder<double>(
                valueListenable: _volumeNotifier,
                builder: (context, vol, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          vol == 0 ? Icons.volume_off : Icons.volume_up,
                          size: 18,
                          color: Colors.grey,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.white70,
                              inactiveTrackColor: Colors.grey.shade800,
                              thumbColor: const Color(0xFF1DB954),
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: vol,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (newVol) {
                                _volumeNotifier.value = newVol;
                                player.setVolume(newVol);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
