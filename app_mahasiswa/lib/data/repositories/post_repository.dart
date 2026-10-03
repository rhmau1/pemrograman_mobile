import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/mahasiswa.dart';

class MahasiswaRepository {
  MahasiswaRepository(this._dio);
  final Dio _dio;

  static const String _path = '/mahasiswa';

  // READ - ambil semua data
  Future<List<Mahasiswa>> fetchMahasiswas() async {
    final response = await _dio.get(_path);
    final data = response.data['data'] as List? ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Mahasiswa.fromJson)
        .toList();
  }

  // READ - ambil data per halaman (paginated)
  Future<List<Mahasiswa>> fetchMahasiswaPage({
    required int page,
    int limit = 10,
  }) async {
    debugPrint('[Repo] fetchMahasiswaPage: page=$page, limit=$limit');
    
    final response = await _dio.get(
      _path,
      queryParameters: {'page': page, 'per_page': limit},
    );

    debugPrint('[Repo] response.statusCode: ${response.statusCode}');
    debugPrint('[Repo] response.data type: ${response.data.runtimeType}');

    dynamic rawData = response.data;
    if (rawData is String) {
      try {
        rawData = jsonDecode(rawData);
      } catch (_) {}
    }
    
    final responseData = rawData is Map ? rawData : {};
    final data = responseData['data'] is List ? responseData['data'] as List : [];

    debugPrint('[Repo] parsed ${data.length} items from page $page');

    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => Mahasiswa.fromJson(e))
        .toList();
  }

  // CREATE - tambah data baru
  Future<Mahasiswa> createMahasiswa(Mahasiswa m) async {
    final response = await _dio.post(_path, data: m.toJson());
    return Mahasiswa.fromJson(response.data['data']);
  }

  // UPDATE - ubah data berdasarkan id
  Future<Mahasiswa> updateMahasiswa(int id, Mahasiswa m) async {
    final response = await _dio.put('$_path/$id', data: m.toJson());
    return Mahasiswa.fromJson(response.data['data']);
  }

  // DELETE - hapus data berdasarkan id
  Future<void> deleteMahasiswa(int id) async {
    await _dio.delete('$_path/$id');
  }
}
