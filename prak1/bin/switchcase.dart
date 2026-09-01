import 'dart:io';

void main(List<String> args) {
  print("masukkan nama");
  String? nama = stdin.readLineSync();
  switch (nama) {
    case null:
    case "":
      print("nama anda tidak diketahui");
      break;
    default:
      print("nama anda $nama");
      break;
  }
}
