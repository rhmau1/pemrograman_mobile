import 'package:flutter/material.dart';
import '../lirik.dart';

/// Kelompok 2: Scaffold / Page Screen - Spotify Playlist Screen
class SpotifyPlaylistScreen extends StatefulWidget {
  final List<Lirik> songs;
  final String playlistName;
  final String playlistDescription;
  final bool isPrivate;
  final String privacyType;
  final bool allowComments;
  final String authorName;
  final Function(int) onSelectSong;
  final Function(Lirik) onAddSong;
  final Function(int, int) onReorderSongs;
  final Function(String, String, bool, String) onUpdatePlaylist;

  const SpotifyPlaylistScreen({
    super.key,
    required this.songs,
    required this.playlistName,
    required this.playlistDescription,
    required this.isPrivate,
    required this.privacyType,
    required this.allowComments,
    required this.authorName,
    required this.onSelectSong,
    required this.onAddSong,
    required this.onReorderSongs,
    required this.onUpdatePlaylist,
  });

  @override
  State<SpotifyPlaylistScreen> createState() => _SpotifyPlaylistScreenState();
}

class _SpotifyPlaylistScreenState extends State<SpotifyPlaylistScreen> {
  // Kelompok 5: Form key & TextControllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _searchController;

  late bool _isPrivate;
  late String _privacyType;
  late bool _allowComments;
  String _searchQuery = "";

  // Kelompok 4: DropdownButton state
  String _selectedSortGenre = "Semua";

  // Kelompok 5: DatePicker / TimePicker state
  DateTime? _scheduledReleaseDate;
  TimeOfDay? _scheduledReleaseTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlistName);
    _descController = TextEditingController(text: widget.playlistDescription);
    _searchController = TextEditingController();

    _isPrivate = widget.isPrivate;
    _privacyType = widget.privacyType;
    _allowComments = widget.allowComments;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _savePlaylistMetadata() {
    if (_formKey.currentState!.validate()) {
      widget.onUpdatePlaylist(
        _nameController.text,
        _descController.text,
        _isPrivate,
        _privacyType,
      );
      // Kelompok 8: SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Detail Playlist berhasil diperbarui!'),
          backgroundColor: Color(0xFF1DB954),
        ),
      );
    }
  }

  // Kelompok 5: DatePicker / TimePicker dialog function
  Future<void> _pickReleaseDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledReleaseDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1DB954),
              surface: Color(0xFF282828),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _scheduledReleaseTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF1DB954),
                surface: Color(0xFF282828),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _scheduledReleaseDate = pickedDate;
          _scheduledReleaseTime = pickedTime;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Jadwal Rilis diset: ${pickedDate.day}/${pickedDate.month}/${pickedDate.year} ${pickedTime.format(context)}',
            ),
          ),
        );
      }
    }
  }

  // Kelompok 8: showDialog & AlertDialog
  void _showAddSongDialog() {
    final titleCtrl = TextEditingController();
    final artistCtrl = TextEditingController();
    final lyricCtrl = TextEditingController();
    final songFormKey = GlobalKey<FormState>();
    String newGenre = "Pop Anak";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text("Tambah Lagu Baru", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Form(
              key: songFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Judul Lagu",
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1DB954))),
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Judul wajib diisi" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: artistCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Pencipta / Artis",
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1DB954))),
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Nama pencipta wajib diisi" : null,
                  ),
                  const SizedBox(height: 10),
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      return DropdownButtonFormField<String>(
                        initialValue: newGenre,
                        dropdownColor: const Color(0xFF282828),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Kategori Genre",
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Pop Anak", child: Text("Pop Anak")),
                          DropdownMenuItem(value: "Klasik Anak", child: Text("Klasik Anak")),
                          DropdownMenuItem(value: "Pengantar Tidur", child: Text("Pengantar Tidur")),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => newGenre = val);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: lyricCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Lirik Lagu",
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1DB954))),
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Lirik wajib diisi" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Kelompok 4: TextButton & ElevatedButton
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                if (songFormKey.currentState!.validate()) {
                  final newSong = Lirik(
                    id: DateTime.now().millisecondsSinceEpoch,
                    judul: titleCtrl.text,
                    pencipta: artistCtrl.text,
                    lirik: lyricCtrl.text,
                    duration: "02:30",
                    imageAsset: 'assets/images/p.jpg',
                    audioAsset: 'songs/balonku.mp3',
                    genre: newGenre,
                  );
                  widget.onAddSong(newSong);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lagu "${newSong.judul}" ditambahkan!')),
                  );
                }
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Lirik> filteredSongs = widget.songs.where((song) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = song.judul.toLowerCase().contains(query) ||
          song.pencipta.toLowerCase().contains(query);
      final matchesGenre = _selectedSortGenre == "Semua" || song.genre == _selectedSortGenre;
      return matchesQuery && matchesGenre;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist Details & Form'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tautan playlist disalin ke clipboard!')),
              );
            },
          ),
        ],
      ),
      // Kelompok 10: SingleChildScrollView
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card - Kelompok 1: Container, Row, Column
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade900.withValues(alpha: 0.6), const Color(0xFF181818)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/p.jpg',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 12,
                                  backgroundImage: AssetImage('assets/images/p.jpg'),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Privacy Tag Badge - Kelompok 2: Align / Badge Container
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isPrivate ? Colors.redAccent.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _isPrivate ? Colors.redAccent : Colors.green,
                                ),
                              ),
                              child: Text(
                                _isPrivate ? "🔒 Privat ($_privacyType)" : "🌐 Publik ($_privacyType)",
                                style: TextStyle(
                                  color: _isPrivate ? Colors.redAccent : Colors.greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form Input Section - Kelompok 5: Form & TextFormField
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ubah Nama Playlist (TextFormField):",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            fillColor: Colors.white.withValues(alpha: 0.08),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF1DB954)),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Nama playlist tidak boleh kosong!";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // TextFormField for Editing Description
                        const Text(
                          "Ubah Deskripsi Playlist (TextFormField):",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _descController,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            fillColor: Colors.white.withValues(alpha: 0.08),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF1DB954)),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {}); // Rebuild for RichText live preview
                          },
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Deskripsi playlist tidak boleh kosong!";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // RichText Description Preview - Kelompok 3: RichText & TextStyle
                        const Text(
                          "Pratinjau Deskripsi Playlist (RichText):",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              children: [
                                const TextSpan(
                                  text: "Deskripsi: ",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                TextSpan(text: _descController.text),
                                const TextSpan(
                                  text: "  #Spotify #LaguAnak #MobileApp",
                                  style: TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Access Control Expansion - Kelompok 5: Switch, RadioGroup, Checkbox
                        ExpansionTile(
                          iconColor: const Color(0xFF1DB954),
                          collapsedIconColor: Colors.grey,
                          title: const Text(
                            "Pengaturan Akses & JADWAL (Switch / Checkbox / Radio / DatePicker)",
                            style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                          ),
                          children: [
                            // 1. SwitchListTile / Switch
                            SwitchListTile(
                              activeThumbColor: const Color(0xFF1DB954),
                              title: const Text("Mode Privat (Switch)", style: TextStyle(fontSize: 14)),
                              subtitle: const Text("Hanya Anda yang dapat melihat playlist ini"),
                              value: _isPrivate,
                              onChanged: (bool val) {
                                setState(() {
                                  _isPrivate = val;
                                  _privacyType = val ? "Privat" : "Publik";
                                });
                              },
                            ),
                            const Divider(color: Colors.white12),

                            // 2. RadioGroup & RadioListTile
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Kategori Akses (RadioGroup):", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ),
                            ),
                            RadioGroup<String>(
                              groupValue: _privacyType,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _privacyType = val;
                                    _isPrivate = (val == "Privat");
                                  });
                                }
                              },
                              child: const Column(
                                children: [
                                  RadioListTile<String>(
                                    activeColor: Color(0xFF1DB954),
                                    title: Text("Publik (Dapat ditemukan semua pengguna)", style: TextStyle(fontSize: 13)),
                                    value: "Publik",
                                  ),
                                  RadioListTile<String>(
                                    activeColor: Color(0xFF1DB954),
                                    title: Text("Tersembunyi (Hanya melalui tautan)", style: TextStyle(fontSize: 13)),
                                    value: "Tersembunyi",
                                  ),
                                  RadioListTile<String>(
                                    activeColor: Color(0xFF1DB954),
                                    title: Text("Privat (Hanya Saya)", style: TextStyle(fontSize: 13)),
                                    value: "Privat",
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.white12),

                            // 3. CheckboxListTile / Checkbox
                            CheckboxListTile(
                              activeColor: const Color(0xFF1DB954),
                              title: const Text("Izinkan Komentar Pengguna (Checkbox)", style: TextStyle(fontSize: 14)),
                              value: _allowComments,
                              onChanged: (bool? val) {
                                setState(() {
                                  _allowComments = val ?? true;
                                });
                              },
                            ),
                            const Divider(color: Colors.white12),

                            // 4. DatePicker & TimePicker Trigger Button
                            ListTile(
                              leading: const Icon(Icons.calendar_month, color: Color(0xFF1DB954)),
                              title: const Text("Atur Jadwal Rilis Playlist (DatePicker/TimePicker)"),
                              subtitle: Text(
                                _scheduledReleaseDate == null
                                    ? "Belum ada jadwal rilis"
                                    : "Jadwal: ${_scheduledReleaseDate!.day}/${_scheduledReleaseDate!.month}/${_scheduledReleaseDate!.year} ${!mounted || _scheduledReleaseTime == null ? '' : _scheduledReleaseTime!.format(context)}",
                              ),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                                onPressed: _pickReleaseDateTime,
                                child: const Text("Pilih Date/Time", style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: _savePlaylistMetadata,
                            icon: const Icon(Icons.save),
                            label: const Text("Simpan Perubahan Form"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kelompok 4: ButtonBar / OverflowBar & Button Varieties
            const Text(
              "Variasi Widget Tombol (Kelompok 4 Showcase):",
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Kelompok 10: Wrap for button toolbar
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 1. ElevatedButton
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: () {
                    if (widget.songs.isNotEmpty) {
                      widget.onSelectSong(0);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text("Mainkan (Elevated)", style: TextStyle(fontSize: 12)),
                ),

                // 2. OutlinedButton
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1DB954),
                    side: const BorderSide(color: Color(0xFF1DB954)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daftar lagu diacak!')),
                    );
                  },
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text("Acak (Outlined)", style: TextStyle(fontSize: 12)),
                ),

                // 3. TextButton
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detail playlist dibagikan.')),
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text("Share (TextButton)", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar & Filter Row - Kelompok 5: TextField & Kelompok 4: DropdownButton
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari judul / pencipta...",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1DB954)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = "";
                                });
                              },
                            )
                          : null,
                      fillColor: const Color(0xFF282828),
                      filled: true,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Kelompok 4: DropdownButton
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF282828),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSortGenre,
                    dropdownColor: const Color(0xFF282828),
                    underline: const SizedBox(),
                    icon: const Icon(Icons.filter_list, color: Color(0xFF1DB954)),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: "Semua", child: Text("Semua Genre")),
                      DropdownMenuItem(value: "Pop Anak", child: Text("Pop Anak")),
                      DropdownMenuItem(value: "Klasik Anak", child: Text("Klasik Anak")),
                      DropdownMenuItem(value: "Pengantar Tidur", child: Text("Pengantar Tidur")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedSortGenre = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Lagu (ReorderableListView)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "${filteredSongs.length} Lagu",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Kelompok 10: ReorderableListView
            filteredSongs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        "Lagu tidak ditemukan.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSongs.length,
                    onReorderItem: (oldIdx, newIdx) {
                      if (_searchQuery.isEmpty && _selectedSortGenre == "Semua") {
                        widget.onReorderSongs(oldIdx, newIdx);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reset filter untuk menata ulang urutan lagu.'),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      final originalIndex = widget.songs.indexOf(song);

                      return Card(
                        key: ValueKey(song.id),
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.asset(
                                  song.imageAsset,
                                  width: 38,
                                  height: 38,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 38,
                                    height: 38,
                                    color: Colors.grey.shade800,
                                    child: const Icon(Icons.music_note, size: 20, color: Color(0xFF1DB954)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            song.judul,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            '${song.pencipta} • ${song.genre}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                song.duration,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.drag_handle, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            widget.onSelectSong(originalIndex);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      // Kelompok 4: FloatingActionButton
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.black,
        onPressed: _showAddSongDialog,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Lagu (FAB)", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
