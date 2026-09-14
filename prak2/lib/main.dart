import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// import 'mahasiswa.dart';
import 'lirik.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotilite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Fijri(),
    );
  }
}

class Fijri extends StatefulWidget {
  const Fijri({super.key});
  @override
  State<Fijri> createState() => _FijriState();
}

class _FijriState extends State<Fijri> {
  late AudioPlayer player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();

    // Listener untuk mendengarkan total durasi lagu saat file siap
    player.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    // Listener untuk mendengarkan perubahan posisi waktu saat lagu berjalan
    player.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    // Listener saat lagu selesai diputar
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    player.dispose(); // Wajib di-dispose untuk mencegah memory leak
    super.dispose();
  }

  // Fungsi untuk memutar atau menjeda lagu
  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await player.pause();
    } else {
      // Panggil file audio dari folder assets
      await player.play(AssetSource('songs/balonku.mp3'));
    }
  }

  @override
  Widget build(BuildContext context) {
    var lagu = Lirik(
      judul: "Balonku ada lima",
      penyanyi: "Ibu Sur",
      lirik: "Balonku ada lima\nRupa-rupa warnanya\nHijau kuning kelabu\nMerah muda dan biru\nMeletus balon hijau\nDor...\nHatiku sangat kacau\nBalonku tinggal empat\nKupegang erat-erat \nBalonku ada lima\nRupa-rupa warnanya\nHijau kuning kelabu\nMerah muda dan biru\nMeletus balon hijau\nDor...\nHatiku sangat kacau\nBalonku tinggal empat\nKupegang erat-erat",
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Spotilite')),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Image.asset('assets/images/p.jpg', fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.arrow_back_ios),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lagu.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          'Penyanyi: ${lagu.penyanyi}',
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(lagu.lirik, style: const TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
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
                  // Memungkinkan user menggeser slider untuk melompat ke waktu tertentu
                  final position = Duration(milliseconds: value.toInt());
                  await player.seek(position);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 40),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 50,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 40),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
