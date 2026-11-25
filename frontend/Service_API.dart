import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pendonor_profile.dart';

class ApiResponse {
  final bool ok;
  final int statusCode;
  final String message;
  final Map<String, dynamic> raw;

  ApiResponse({
    required this.ok,
    required this.statusCode,
    required this.message,
    required this.raw,
  });
}

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static String? _token;

  static String? get token => _token;

  static void setToken(String? value) {
    _token = value;
  }

  static void logout() {
    _token = null;
  }

  static Map<String, String> _headers({bool withAuth = false}) {
    return {
      'Content-Type': 'application/json',
      if (withAuth && _token != null) 'Authorization': 'Bearer $_token',
    };
  }

  static ApiResponse _parseResponse(http.Response response) {
    Map<String, dynamic> decoded = {};
    if (response.body.isNotEmpty) {
      try {
        final parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) {
          decoded = parsed;
        }
      } catch (_) {
        decoded = {};
      }
    }

    final isOk = response.statusCode >= 200 && response.statusCode < 300;
    final msg = (decoded['message'] ??
            (isOk ? 'Berhasil' : 'Terjadi kesalahan (${response.statusCode})'))
        .toString();

    return ApiResponse(
      ok: isOk,
      statusCode: response.statusCode,
      message: msg,
      raw: decoded,
    );
  }

  static Future<ApiResponse> register({
    required String emailKampus,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: _headers(),
            body: jsonEncode({
              'email_kampus': emailKampus,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 12));

      final parsed = _parseResponse(res);
      if (parsed.ok && parsed.raw['token'] != null) {
        _token = parsed.raw['token'].toString();
      }
      return parsed;
    } on TimeoutException {
      return ApiResponse(
        ok: false,
        statusCode: 408,
        message: 'Koneksi ke server melebihi batas waktu',
        raw: {},
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        statusCode: 500,
        message: 'Gagal terhubung ke server: $e',
        raw: {},
      );
    }
  }

  static Future<ApiResponse> login({
    required String emailKampus,
    required String password,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: _headers(),
            body: jsonEncode({
              'email_kampus': emailKampus,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 12));

      final parsed = _parseResponse(res);
      if (parsed.ok && parsed.raw['token'] != null) {
        _token = parsed.raw['token'].toString();
      }
      return parsed;
    } on TimeoutException {
      return ApiResponse(
        ok: false,
        statusCode: 408,
        message: 'Koneksi ke server melebihi batas waktu',
        raw: {},
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        statusCode: 500,
        message: 'Gagal terhubung ke server: $e',
        raw: {},
      );
    }
  }

  static Future<ApiResponse> savePendonorProfile(PendonorProfile profile) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/pendonor'),
            headers: _headers(withAuth: true),
            body: jsonEncode(profile.toJson()),
          )
          .timeout(const Duration(seconds: 12));

      return _parseResponse(res);
    } on TimeoutException {
      return ApiResponse(
        ok: false,
        statusCode: 408,
        message: 'Koneksi ke server melebihi batas waktu',
        raw: {},
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        statusCode: 500,
        message: 'Gagal menyimpan profil: $e',
        raw: {},
      );
    }
  }

  static Future<ApiResponse> getBeranda() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/beranda'),
            headers: _headers(withAuth: true),
          )
          .timeout(const Duration(seconds: 12));

      return _parseResponse(res);
    } on TimeoutException {
      return ApiResponse(
        ok: false,
        statusCode: 408,
        message: 'Koneksi ke server melebihi batas waktu',
        raw: {},
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        statusCode: 500,
        message: 'Gagal memuat beranda: $e',
        raw: {},
      );
    }
  }
}