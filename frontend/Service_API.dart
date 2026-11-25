import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/donor_profile.dart';

class ApiService {
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
      'message': data['message'],
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

    DonorProfile? profile;
    if (data['profile'] != null && data['profile'] is Map<String, dynamic>) {
      profile = DonorProfile.fromJson(data['profile'] as Map<String, dynamic>);
    }

    return {
      'ok': response.statusCode >= 200 && response.statusCode < 300,
      'message': data['message'],
      'hasProfile': data['hasProfile'] == true,
      'profile': profile,
    };
  }

  static Future> savePendonorProfile(
    DonorProfile profileInput,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pendonor'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileInput.toJson()),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    DonorProfile? savedProfile;
    if (data['profile'] != null && data['profile'] is Map<String, dynamic>) {
      savedProfile = DonorProfile.fromJson(data['profile'] as Map<String, dynamic>);
    }

    return {
      'ok': response.statusCode >= 200 && response.statusCode < 300,
      'message': data['message'],
      'profile': savedProfile,
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
    DonorProfile? profile;
    if (data['profile'] != null && data['profile'] is Map<String, dynamic>) {
      profile = DonorProfile.fromJson(data['profile'] as Map<String, dynamic>);
    }

    return {
      'ok': response.statusCode >= 200 && response.statusCode < 300,
      'message': data['message'],
      'profile': profile,
    };
  }
}
