import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator -> http://10.0.2.2:3000/api
  // Web / Chrome / Desktop -> http://localhost:3000/api
  // HP Fisik -> ganti dengan IP lokal laptop kamu, misal http://192.168.1.10:3000/api
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static String? token;

  static Future> register({
    required String emailKampus,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email_kampus': emailKampus,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 201 && data['token'] != null) {
      token = data['token'];
    }
    return {
      'ok': response.statusCode >= 200 && response.statusCode < 300,
      'data': data,
    };
  }

  static Future> login({
    required String emailKampus,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email_kampus': emailKampus,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['token'] != null) {
      token = data['token'];
    }
    return {
      'ok': response.statusCode >= 200 && response.statusCode < 300,
      'data': data,
    };
  }

  static Future> savePendonorProfile({
    required String namaLengkap,
    required String nimIdCivitas,
    required String noTelepon,
    required String fakultasUnit,
    required String golonganDarah,
    required bool bersediaDonor,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pendonor'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama_lengkap': namaLengkap,
        'nim_id_civitas': nimIdCivitas,
        'no_telepon': noTelepon,
        'fakultas_unit': fakultasUnit,
        'golongan_darah': golonganDarah,
        'bersedia_donor': bersediaDonor,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'ok': response.statusCode >= 200 && response.statusCode < 300,
      'data': data,
    };
  }

  static Future> getBeranda() async {
    final response = await http.get(
      Uri.parse('$baseUrl/beranda'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'ok': response.statusCode >= 200 && response.statusCode < 300,
      'data': data,
    };
  }
}
