class Lirik {
  final int id;
  String judul;
  String pencipta;
  String lirik;
  String duration;
  String imageAsset;
  String audioAsset;
  bool isFavorite;
  String genre;

  Lirik({
    required this.id,
    required this.judul,
    required this.pencipta,
    required this.lirik,
    this.duration = "02:30",
    this.imageAsset = 'assets/images/p.jpg',
    this.audioAsset = 'songs/balonku.mp3',
    this.isFavorite = false,
    this.genre = 'Pop Anak',
  });
}

List<Lirik> getSampleSongs() {
  return [
    Lirik(
      id: 1,
      judul: "Balonku Ada Lima",
      pencipta: "AT Mahmud / Pak Kasur",
      duration: "02:15",
      lirik: "Balonku ada lima\nRupa-rupa warnanya\nHijau, kuning, kelabu\nMerah muda dan biru\n\nMeletus balon hijau... DOR!\nHatiku sangat kacau\nBalonku tinggal empat\nKupegang erat-erat",
      imageAsset: 'assets/images/p.jpg',
      audioAsset: 'songs/balonku.mp3',
      isFavorite: true,
      genre: 'Pop Anak',
    ),
    Lirik(
      id: 2,
      judul: "Pelangi-Pelangi",
      pencipta: "AT Mahmud",
      duration: "01:50",
      lirik: "Pelangi-pelangi alangkah indahmu\nMerah kuning hijau di langit yang biru\nPelukismu agung, siapa gerangan?\nPelangi-pelangi ciptaan Tuhan",
      imageAsset: 'assets/images/p.jpg',
      audioAsset: 'songs/balonku.mp3',
      genre: 'Pop Anak',
    ),
    Lirik(
      id: 3,
      judul: "Naik-Naik ke Puncak Gunung",
      pencipta: "Ibu Sud",
      duration: "03:10",
      lirik: "Naik-naik ke puncak gunung\nTinggi-tinggi sekali\nNaik-naik ke puncak gunung\nTinggi-tinggi sekali\n\nKiri kanan kulihat saja\nBanyak pohon cemara\nKiri kanan kulihat saja\nBanyak pohon cemara",
      imageAsset: 'assets/images/p.jpg',
      audioAsset: 'songs/balonku.mp3',
      isFavorite: true,
      genre: 'Klasik Anak',
    ),
    Lirik(
      id: 4,
      judul: "Bintang Kecil",
      pencipta: "Daljono",
      duration: "02:05",
      lirik: "Bintang kecil di langit yang tinggi\nAmat banyak menghias angkasa\nAku ingin terbang dan menari\nJauh tinggi ke tempat kau berada",
      imageAsset: 'assets/images/p.jpg',
      audioAsset: 'songs/balonku.mp3',
      genre: 'Pengantar Tidur',
    ),
    Lirik(
      id: 5,
      judul: "Lihat Kebunku",
      pencipta: "Ibu Sud",
      duration: "02:25",
      lirik: "Lihat kebunku penuh dengan bunga\nAda yang putih dan ada yang merah\nSetiap hari kusiram semua\nMawar melati semuanya indah",
      imageAsset: 'assets/images/p.jpg',
      audioAsset: 'songs/balonku.mp3',
      genre: 'Klasik Anak',
    ),
  ];
}
