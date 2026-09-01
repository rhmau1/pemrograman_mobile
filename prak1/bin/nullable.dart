import 'dart:io';

void main(List<String> args) {
  String? name;
  name = null;
  print(name);
  print("nama saya ${name ?? "tidak diketahui"}");
  print("masukkan nama anda");
  String? nama = stdin.readLineSync();
  print(
    "nama anda adalah ${nama == null || nama.isEmpty ? "tidak diketahui" : nama}",
  );
  if (nama != null && nama.isNotEmpty) {
    print("nama anda adalah $nama");
  } else {
    print("nama anda adalah tidak diketahui");
  }
  String status = (nama == null || nama.isEmpty ? "tidak diketahui" : nama);
  print("nama anda adalah: $status");
}
