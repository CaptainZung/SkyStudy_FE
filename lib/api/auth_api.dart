// lib/api/auth_api.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthAPI {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "http://192.168.1.5:8000/api",
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
     headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",
  },
  ));

  // Hàm login
  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login/',
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        return response.data['token'];
      }

      debugPrint("Lỗi: Sai tài khoản hoặc mật khẩu");
      return null;

    } on DioException catch (e) {
  if (e.response != null) {
    debugPrint("Lỗi API: ${e.response?.statusCode} - ${e.response?.data}");
  } else if (e.type == DioExceptionType.connectionTimeout) {
    debugPrint("Kết nối quá thời gian, kiểm tra lại server");
  } else {
    debugPrint("Lỗi kết nối: ${e.message}");
  }
  return null;
}
  }
}
