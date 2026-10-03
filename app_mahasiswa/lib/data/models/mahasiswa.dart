class Mahasiswa {
  const Mahasiswa({
    required this.nim,
    required this.id,
    required this.nama,
    required this.prodi,
    required this.email,
  });

  final String nim;
  final int id;
  final String nama;
  final String prodi;
  final String email;

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      nim: json['nim'] as String? ?? '',
      id: (json['id'] as num?)?.toInt() ?? 0,
      nama: json['nama'] as String? ?? '',
      prodi: json['prodi'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'nim': nim,
    'id': id,
    'nama': nama,
    'prodi': prodi,
    'email': email,
  };
}
