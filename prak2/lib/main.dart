import 'package:flutter/material.dart';

// import 'mahasiswa.dart';
import 'lirik.dart';

void main() {
  runApp(const Fijri());
}

class Fijri extends StatelessWidget {
  const Fijri({super.key});

  @override
  Widget build(BuildContext context) {
    // final mahasiswa = Mahasiswa(nama: "rahma", umur: 20, kelas: "TI 3C");
    var lagu = Lirik(
      judul: "Balonku ada lima",
      penyanyi: "Ibu Sur",
      lirik: "Balonku ada lima\nRupa-rupa warnanya\nHijau kuning kelabu\nMerah muda dan biru\nMeletus balon hijau\nDor...\nHatiku sangat kacau\nBalonku tinggal empat\nKupegang erat-erat",
    );
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Spotilite')),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_back_ios),
                    SizedBox(width: 50),
                    Column(
                      children: [
                        Text(
                          '${lagu.judul}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          'Penyanyi: ${lagu.penyanyi}',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 40,
                      ),
                      child: Align(
                        alignment: AlignmentGeometry.topLeft,
                        child: Text(
                          '${lagu.lirik}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: AlignmentGeometry.topRight,
                        child: Text(
                          '${lagu.lirik}',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(20),
          color: Colors.pinkAccent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.skip_previous, size: 50),
              SizedBox(width: 50),
              Icon(Icons.play_arrow, size: 50),
              SizedBox(width: 50),
              Icon(Icons.skip_next, size: 50),
            ],
          ),
        ),
      ),
    );
  }
}
// TUGAS MELANJUTKAN HALAMAN INI UNTUK APLIKASI LIRIK LAGU
