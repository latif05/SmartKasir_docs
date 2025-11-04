import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static SharedPreferences? _prefs;
  static const _baseUrlKey = 'smartkasir.auth.base_url_override';
  static const String _envBaseUrl =
      String.fromEnvironment('SMARTKASIR_API_BASE_URL', defaultValue: '');

  /// Ensure shared preferences is ready before accessing overrides.
  static Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save a new base url override (e.g. when running on a physical device).
  static Future<void> setBaseUrl(String baseUrl) async {
    await ensureInitialized();
    final normalized = _normalizeBaseUrl(baseUrl);
    await _prefs!.setString(_baseUrlKey, normalized);
  }

  static String get baseUrl {
    final override = _prefs?.getString(_baseUrlKey);
    if (override != null && override.isNotEmpty) return override;
    if (_envBaseUrl.isNotEmpty) return _normalizeBaseUrl(_envBaseUrl);
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static String _normalizeBaseUrl(String baseUrl) {
    var trimmed = baseUrl.trim();
    if (trimmed.isEmpty) return trimmed;
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'http://$trimmed';
    }
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final uri = Uri.parse('${baseUrl}/auth/login');
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'username': username, 'password': password}))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return {'token': body['token']};
      } else {
        // log for debugging
        print('AuthService.login failed: status=${res.statusCode}, body=${res.body}');
        return {'error': 'Server error ${res.statusCode}: ${res.body}'};
      }
    } on TimeoutException catch (_) {
      final message =
          'Permintaan login melebihi batas waktu. Pastikan server merespon dan coba lagi.';
      print('AuthService.login timeout: $message');
      return {'error': message};
    } on SocketException catch (e) {
      final message =
          'Tidak dapat terhubung ke ${baseUrl} (${e.message}). Pastikan backend berjalan dan perangkat berada dalam jaringan yang sama.';
      print('AuthService.login socket exception: $message');
      return {'error': message};
    } catch (e) {
      // network error / timeout / other
      print('AuthService.login exception: $e');
      return {'error': e.toString()};
    }
  }
}
