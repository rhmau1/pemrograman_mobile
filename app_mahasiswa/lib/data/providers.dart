import 'package:app_mahasiswa/data/api_client.dart';
import 'package:app_mahasiswa/data/models/mahasiswa.dart';
import 'package:app_mahasiswa/data/repositories/post_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final mahasiswaRepositoryProvider = Provider<MahasiswaRepository>(
  (ref) => MahasiswaRepository(ref.watch(dioProvider)),
);

class MahasiswaListNotifier extends AsyncNotifier<List<Mahasiswa>> {
  @override
  Future<List<Mahasiswa>> build() async {
    // Exception dari repository otomatis menjadi AsyncError
    final repository = ref.watch(mahasiswaRepositoryProvider);
    return repository.fetchMahasiswas();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(mahasiswaRepositoryProvider);
      state = AsyncData(await repository.fetchMahasiswas());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> createMahasiswa(Mahasiswa m) async {
    final repository = ref.read(mahasiswaRepositoryProvider);
    await repository.createMahasiswa(m);
    await refresh();
  }

  Future<void> updateMahasiswa(int id, Mahasiswa m) async {
    final repository = ref.read(mahasiswaRepositoryProvider);
    await repository.updateMahasiswa(id, m);
    await refresh();
  }

  Future<void> deleteMahasiswa(int id) async {
    final repository = ref.read(mahasiswaRepositoryProvider);
    await repository.deleteMahasiswa(id);
    await refresh();
  }
}

final mahasiswaListProvider =
    AsyncNotifierProvider<MahasiswaListNotifier, List<Mahasiswa>>(
      MahasiswaListNotifier.new,
    );
