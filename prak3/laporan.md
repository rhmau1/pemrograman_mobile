# praktikum 3 week 4

Fijriati rahmatur rizqi - 244107020069

Kelas: TI 3C

# Gambar Tampilan Aplikasi

![](screenshot/image.png)

## Penjelasan Kode Program & Pembaruan (Update)

Laporan praktikum ini menjelaskan pengembangan aplikasi pemutar lirik lagu (**Spotilite**) dari Praktikum 2 ke Praktikum 3. Pada Praktikum 3 ini, dilakukan berbagai pembaruan UI/UX serta penambahan fitur pemutar audio secara *real-time*.

---

### Perubahan & Pembaruan Utama (Prak 2 -> Prak 3)

1. **Menambahkan Gambar (`Image.asset`)**
2. **Menambahkan Lagu/Audio (`balonku.mp3`)**
3. **Menambahkan Navigasi Samping (`Drawer`)**
4. **Menambahkan Daftar Item (`ListTile`)**
5. **Integrasi Pemutar Musik (`audioplayers`)**

---

### Penjelasan Detail Update & Cara Menambahkannya

#### 1. Menambahkan Gambar (Image Asset)
* **Penjelasan:**
  Gambar digunakan sebagai cover album/lagu di halaman utama aplikasi serta thumbnail pada antrean lagu di dalam *Drawer*.
* **Cara Menambahkan:**
  1. Buat direktori folder `assets/images/` di dalam proyek Flutter.
  2. Masukkan file gambar (misalnya `p.jpg`) ke dalam folder tersebut.
  3. Daftarkan path file gambar pada file `pubspec.yaml`:
     ```yaml
     flutter:
       assets:
         - assets/images/p.jpg
     ```
  4. Panggil gambar di dalam kode Dart menggunakan widget `Image.asset`:
     ```dart
     Image.asset('assets/images/p.jpg', fit: BoxFit.cover)
     ```

#### 2. Menambahkan Lagu (Audio Asset)
* **Penjelasan:**
  File audio fisik berformat `.mp3` disimpan secara lokal sebagai *asset* proyek agar dapat diputar oleh aplikasi.
* **Cara Menambahkan:**
  1. Buat direktori folder `assets/songs/` di dalam proyek.
  2. Masukkan file lagu (misalnya `balonku.mp3`) ke dalam folder tersebut.
  3. Daftarkan path file lagu pada `pubspec.yaml`:
     ```yaml
     flutter:
       assets:
         - assets/songs/balonku.mp3
     ```
  4. File audio siap dipanggil menggunakan `AssetSource('songs/balonku.mp3')` via package `audioplayers`.

#### 3. Menambahkan Drawer (Navigation Drawer)
* **Penjelasan:**
  `Drawer` adalah panel menu navigasi yang tersembunyi di sisi kiri layar dan dapat digeser (ditarik) keluar saat pengguna menekan tombol menu hamburger di `AppBar`.
* **Cara Menambahkan:**
  1. Tambahkan properti `drawer` pada widget `Scaffold`.
  2. Isi properti `drawer` dengan widget `Drawer` yang membungkus `ListView` untuk menampung elemen menu/antrean lagu:
     ```dart
     drawer: Drawer(
       child: ListView(
         children: [
           Container(
             height: 60,
             padding: const EdgeInsets.all(10),
             child: const Text(
               "Antrean lagu",
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
             ),
           ),
           // ListTile items dimasukkan di sini
         ],
       ),
     ),
     ```

#### 4. Menambahkan ListTile
* **Penjelasan:**
  `ListTile` adalah widget standar Material Design Flutter untuk menampilkan baris item berstruktur baku lengkap dengan ikon/gambar di sebelah kiri (`leading`) dan teks judul (`title`).
* **Cara Menambahkan:**
  1. Tempatkan widget `ListTile` sebagai *children* di dalam `ListView` pada `Drawer`.
  2. Atur ikon/gambar pada properti `leading` dan judul pada properti `title`:
     ```dart
     ListTile(
       contentPadding: const EdgeInsets.all(10),
       leading: Image.asset("assets/images/p.jpg"),
       title: const Text("lagu lain"),
     )
     ```

#### 5. Integrasi Fitur Audio Player (`audioplayers`)
* **Penjelasan:**
  Package `audioplayers` digunakan untuk mengontrol pemutaran audio (play, pause, seek position, mendapatkan total durasi lagu).
* **Cara Memasang & Menggunakan:**
  1. Tambahkan dependency `audioplayers: ^6.8.1` pada `pubspec.yaml` di bawah `dependencies:`:
     ```yaml
     dependencies:
       flutter:
         sdk: flutter
       audioplayers: ^6.8.1
     ```
  2. Import package di `lib/main.dart`:
     ```dart
     import 'package:audioplayers/audioplayers.dart';
     ```
  3. Ubah widget tampilan utama dari `StatelessWidget` menjadi `StatefulWidget` untuk mengelola status pemutaran (`_isPlaying`), total durasi (`_duration`), dan posisi audio berjalan (`_position`).
  4. Inisialisasi `AudioPlayer()` dan daftarkan *listener stream* di method `initState()`:
     ```dart
     player.onDurationChanged.listen((newDuration) {
       setState(() { _duration = newDuration; });
     });
     player.onPositionChanged.listen((newPosition) {
       setState(() { _position = newPosition; });
     });
     player.onPlayerStateChanged.listen((state) {
       setState(() { _isPlaying = state == PlayerState.playing; });
     });
     ```
  5. Buat fungsi logika pemutaran lagu `_togglePlayPause()`:
     ```dart
     Future<void> _togglePlayPause() async {
       if (_isPlaying) {
         await player.pause();
       } else {
         await player.play(AssetSource('songs/balonku.mp3'));
       }
     }
     ```
  6. Hubungkan dengan widget `Slider` untuk indikator posisi pemutaran dan navigasi *seek*, serta `IconButton` untuk tombol Play/Pause pada `bottomNavigationBar`.
  7. Bersihkan resource di method `dispose()` dengan `player.dispose()`.

---

### Struktur & Penjelasan File Kode Program

#### 1. `lib/lirik.dart`
File ini mendefinisikan class model data **`Lirik`** untuk menyimpan informasi lagu.
* **Atribut / Property:**
  * `judul` (`String`): Judul lagu.
  * `pencipta` (`String`): Pencipta lagu.
  * `lirik` (`String`): Teks lirik lagu.
* **Constructor:**
  * `Lirik({required this.judul, required this.pencipta, required this.lirik})`: Menggunakan *named parameters* wajib (`required`).

---

#### 2. `lib/main.dart`
File utama (*entry point*) aplikasi **Spotilite**.
* **Fungsi `main()`:** Memanggil `runApp(const MyApp())`.
* **Widget `MyApp` (`StatelessWidget`):** Root widget aplikasi yang mengatur tema dan halaman utama `Fijri()`.
* **Widget `Fijri` (`StatefulWidget`):**
  * Mengelola status audio pemain (`AudioPlayer`), slider durasi lagu, dan tombol play/pause.
* **Struktur Tampilan (UI Layout):**
  * **AppBar**: Menampilkan judul aplikasi `'Spotilite'`.
  * **Drawer**: Menu antrean lagu menggunakan `ListView` dan beberapa `ListTile` berisi gambar thumbnail dan judul lagu.
  * **Body**: Memuat gambar cover album lagu (`Image.asset`), informasi judul dan pencipta lagu, serta area lirik lagu yang dapat di-scroll (`SingleChildScrollView`).
  * **Bottom Navigation Bar**: Kontrol pemutar audio yang terdiri dari:
    * `Slider`: Menampilkan dan mengatur posisi progres waktu audio.
    * Tombol kontrol (`skip_previous`, `play/pause` interaktif, dan `skip_next`).

---

notes:
scaffold tumpukan ke bawah, drawer yang disamping
setiap properties yg ada di widget hanya bisa 1, biar banyak cari yang bisa menampung banyak / array cth. children
