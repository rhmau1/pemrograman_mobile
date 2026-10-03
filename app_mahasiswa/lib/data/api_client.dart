import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.8.104:8000/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint('[Dio] $obj'),
    ),
  );
  return dio;
}
