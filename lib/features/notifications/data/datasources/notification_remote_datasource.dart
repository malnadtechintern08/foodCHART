import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 20, String? filter});
  Future<int> getUnreadCount();
  Future<bool> markAsRead(int notificationId);
  Future<int> markAllAsRead();
  Future<bool> markAsUnread(int notificationId);
  Future<NotificationModel> getNotificationDetails(int notificationId);
  Future<bool> deleteNotification(int notificationId);
  Future<int> clearAllNotifications();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final http.Client client;
  static String? _cachedTestCookie;

  static const String mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  static const Duration timeoutDuration = Duration(seconds: 15);

  NotificationRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  /// Solves the InfinityFree slowAES.decrypt(c, 2, a, b) anti-bot challenge
  String _solveChallenge(String keyHex, String ivHex, String ctHex) {
    final key = Uint8List.fromList(hex.decode(keyHex));
    final iv = Uint8List.fromList(hex.decode(ivHex));
    final ct = Uint8List.fromList(hex.decode(ctHex));

    final cipher = CBCBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(key), iv));

    final out = Uint8List(16);
    cipher.processBlock(ct, 0, out, 0);
    return hex.encode(out);
  }

  /// Ensures InfinityFree anti-bot cookie is active before sending requests
  Future<String?> _ensureInfinityFreeCookie() async {
    if (_cachedTestCookie != null && _cachedTestCookie!.isNotEmpty) {
      return _cachedTestCookie;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCookie = prefs.getString('__infinityfree_test_cookie');
      if (savedCookie != null && savedCookie.isNotEmpty) {
        _cachedTestCookie = savedCookie;
        return _cachedTestCookie;
      }
    } catch (_) {}

    try {
      final headers = <String, String>{
        'User-Agent': mobileUserAgent,
        'Accept': 'application/json, text/html, */*',
      };

      final probeUri = Uri.parse(AppConstants.apiCategoriesEndpoint);
      final response = await client.get(probeUri, headers: headers).timeout(timeoutDuration);

      if (response.body.contains('slowAES.decrypt') &&
          response.body.contains('toNumbers(')) {
        final reg = RegExp(r'toNumbers\("([a-f0-9]+)"\)');
        final matches = reg.allMatches(response.body).toList();
        if (matches.length >= 3) {
          final a = matches[0].group(1)!;
          final b = matches[1].group(1)!;
          final c = matches[2].group(1)!;
          _cachedTestCookie = _solveChallenge(a, b, c);

          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('__infinityfree_test_cookie', _cachedTestCookie!);
          } catch (_) {}

          // Register cookie with OpenResty proxy
          headers['Cookie'] = '__test=$_cachedTestCookie';
          await client.get(
            Uri.parse('${AppConstants.apiCategoriesEndpoint}?i=1'),
            headers: headers,
          ).timeout(timeoutDuration);
        }
      }
    } catch (_) {}

    return _cachedTestCookie;
  }

  Future<String> _getOrInitAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(AppConstants.keyUserAuthToken);

    if (token != null && token.isNotEmpty && !token.startsWith('cm_')) {
      return token;
    }

    await _ensureInfinityFreeCookie();

    try {
      final response = await _sendRequest(
        Uri.parse(AppConstants.apiSessionEndpoint),
        method: 'POST',
        body: jsonEncode({
          'display_name': prefs.getString(AppConstants.keyUserDisplayName) ?? 'Food CHART User',
          'device_info': Platform.operatingSystem,
          if (token != null && !token.startsWith('cm_')) 'auth_token': token,
        }),
      );

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == true && decoded['data'] != null) {
        final serverToken = decoded['data']['auth_token']?.toString();
        if (serverToken != null && serverToken.isNotEmpty) {
          await prefs.setString(AppConstants.keyUserAuthToken, serverToken);
          return serverToken;
        }
      }
    } catch (_) {}

    if (token != null && token.isNotEmpty) {
      return token;
    }

    token = 'cm_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9999 * (DateTime.now().microsecond / 1000000))).toInt()}';
    await prefs.setString(AppConstants.keyUserAuthToken, token);
    return token;
  }

  Future<http.Response> _sendRequest(
    Uri uri, {
    String method = 'GET',
    Map<String, String>? extraHeaders,
    Object? body,
  }) async {
    await _ensureInfinityFreeCookie();

    final headers = <String, String>{
      'User-Agent': mobileUserAgent,
      'Accept': 'application/json, text/html, */*',
    };

    if (body != null) {
      headers['Content-Type'] = 'application/json; charset=utf-8';
    }

    if (_cachedTestCookie != null && _cachedTestCookie!.isNotEmpty) {
      headers['Cookie'] = '__test=$_cachedTestCookie';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    http.Response response;
    switch (method.toUpperCase()) {
      case 'POST':
        response = await client.post(uri, headers: headers, body: body).timeout(timeoutDuration);
        break;
      case 'PUT':
        response = await client.put(uri, headers: headers, body: body).timeout(timeoutDuration);
        break;
      case 'DELETE':
        response = await client.delete(uri, headers: headers, body: body).timeout(timeoutDuration);
        break;
      case 'GET':
      default:
        response = await client.get(uri, headers: headers).timeout(timeoutDuration);
        break;
    }

    // Handle InfinityFree slowAES challenge if cookie expired or missing
    if (response.body.contains('slowAES.decrypt') ||
        (response.body.contains('<script>') && response.body.contains('__test'))) {
      final keyMatch = RegExp(r'toNumbers\("([a-f0-9]+)"\)').allMatches(response.body).toList();
      if (keyMatch.length >= 3) {
        final a = keyMatch[0].group(1)!;
        final b = keyMatch[1].group(1)!;
        final c = keyMatch[2].group(1)!;
        _cachedTestCookie = _solveChallenge(a, b, c);

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('__infinityfree_test_cookie', _cachedTestCookie!);
        } catch (_) {}

        headers['Cookie'] = '__test=$_cachedTestCookie';

        // Register cookie with redirect GET first
        try {
          await client.get(
            Uri.parse('${AppConstants.apiCategoriesEndpoint}?i=1'),
            headers: {'User-Agent': mobileUserAgent, 'Cookie': '__test=$_cachedTestCookie'},
          ).timeout(timeoutDuration);
        } catch (_) {}

        // Retry the original request with the fresh solved cookie
        switch (method.toUpperCase()) {
          case 'POST':
            response = await client.post(uri, headers: headers, body: body).timeout(timeoutDuration);
            break;
          case 'PUT':
            response = await client.put(uri, headers: headers, body: body).timeout(timeoutDuration);
            break;
          case 'DELETE':
            response = await client.delete(uri, headers: headers, body: body).timeout(timeoutDuration);
            break;
          case 'GET':
          default:
            response = await client.get(uri, headers: headers).timeout(timeoutDuration);
            break;
        }
      }
    }

    return response;
  }

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 20, String? filter}) async {
    final token = await _getOrInitAuthToken();

    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (filter != null && filter.isNotEmpty) 'filter': filter,
    };

    final uri = Uri.parse(AppConstants.apiNotificationsEndpoint).replace(queryParameters: queryParams);

    final response = await _sendRequest(
      uri,
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (!body.startsWith('{') && !body.startsWith('[')) {
        throw Exception('Server returned invalid content: ${body.length > 60 ? body.substring(0, 60) : body}');
      }
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        final List list = decoded['data'] ?? [];
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();

        return list.map((item) {
          final model = NotificationModel.fromJson(item as Map<String, dynamic>);
          final key = 'notif_received_at_${model.id}';
          final savedTimeStr = prefs.getString(key);
          DateTime receivedTime;
          if (savedTimeStr != null) {
            receivedTime = DateTime.tryParse(savedTimeStr) ?? model.createdAt;
          } else {
            receivedTime = now;
            prefs.setString(key, now.toIso8601String());
          }
          return model.copyWith(receivedAt: receivedTime);
        }).where((m) => !m.isExpired).toList();
      }
    }


    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        throw Exception(decoded['message']);
      }
    } catch (_) {}

    throw Exception('Failed to load notifications: HTTP ${response.statusCode}');
  }

  @override
  Future<int> getUnreadCount() async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsUnreadCountEndpoint);

    try {
      final response = await _sendRequest(
        uri,
        extraHeaders: {
          'Authorization': 'Bearer $token',
          'X-Cookmate-Token': token,
        },
      );

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('{')) {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true) {
            return (decoded['unread_count'] as num?)?.toInt() ?? 0;
          }
        }
      }
    } catch (_) {}

    return 0;
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsMarkReadEndpoint);

    final response = await _sendRequest(
      uri,
      method: 'POST',
      body: jsonEncode({'notification_id': notificationId}),
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.startsWith('{')) {
        final decoded = jsonDecode(body);
        return decoded is Map<String, dynamic> && decoded['success'] == true;
      }
    }

    return false;
  }

  @override
  Future<int> markAllAsRead() async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsMarkAllReadEndpoint);

    final response = await _sendRequest(
      uri,
      method: 'POST',
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.startsWith('{')) {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true) {
          return (decoded['updated_count'] as num?)?.toInt() ?? 0;
        }
      }
    }

    return 0;
  }

  @override
  Future<bool> markAsUnread(int notificationId) async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsMarkUnreadEndpoint);

    final response = await _sendRequest(
      uri,
      method: 'POST',
      body: jsonEncode({'notification_id': notificationId}),
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.startsWith('{')) {
        final decoded = jsonDecode(body);
        return decoded is Map<String, dynamic> && decoded['success'] == true;
      }
    }

    return false;
  }

  @override
  Future<NotificationModel> getNotificationDetails(int notificationId) async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsDetailsEndpoint).replace(queryParameters: {
      'id': notificationId.toString(),
    });

    final response = await _sendRequest(
      uri,
      extraHeaders: {
        'Authorization': 'Bearer $token',
        'X-Cookmate-Token': token,
      },
    );

    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.startsWith('{')) {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic> && decoded['success'] == true && decoded['data'] != null) {
          return NotificationModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    }

    throw Exception('Failed to load notification details: HTTP ${response.statusCode}');
  }

  @override
  Future<bool> deleteNotification(int notificationId) async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsDeleteEndpoint);

    try {
      final response = await _sendRequest(
        uri,
        method: 'POST',
        body: jsonEncode({'notification_id': notificationId}),
        extraHeaders: {
          'Authorization': 'Bearer $token',
          'X-Cookmate-Token': token,
        },
      );

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('{')) {
          final decoded = jsonDecode(body);
          return decoded is Map<String, dynamic> && decoded['success'] == true;
        }
      }
    } catch (_) {}

    return false;
  }

  @override
  Future<int> clearAllNotifications() async {
    final token = await _getOrInitAuthToken();
    final uri = Uri.parse(AppConstants.apiNotificationsDeleteEndpoint);

    try {
      final response = await _sendRequest(
        uri,
        method: 'POST',
        body: jsonEncode({'clear_all': true}),
        extraHeaders: {
          'Authorization': 'Bearer $token',
          'X-Cookmate-Token': token,
        },
      );

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('{')) {
          final decoded = jsonDecode(body);
          if (decoded is Map<String, dynamic> && decoded['success'] == true) {
            return (decoded['deleted_count'] as num?)?.toInt() ?? 1;
          }
        }
      }
    } catch (_) {}

    return 0;
  }
}
