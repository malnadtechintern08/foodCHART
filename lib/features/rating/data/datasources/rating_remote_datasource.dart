import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import '../../../../core/constants/app_constants.dart';

abstract class RatingRemoteDataSource {
  Future<bool> submitRating({
    required int stars,
    required String category,
    required String feedbackText,
    String? userName,
    String? userEmail,
    String? deviceInfo,
    String appVersion = '2.0.0',
  });
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  final http.Client client;
  static String? _cachedTestCookie;

  static const String mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  static const Duration timeoutDuration = Duration(seconds: 12);

  RatingRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

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

  Future<String?> _ensureInfinityFreeCookie() async {
    if (_cachedTestCookie != null && _cachedTestCookie!.isNotEmpty) {
      return _cachedTestCookie;
    }

    try {
      final headers = <String, String>{
        'User-Agent': mobileUserAgent,
        'Accept': 'application/json, text/html, */*',
      };

      final probeUri = Uri.parse(AppConstants.apiRatingsSubmitEndpoint);
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

          headers['Cookie'] = '__test=$_cachedTestCookie';
          await client.get(
            Uri.parse('${AppConstants.apiRatingsSubmitEndpoint}?i=1'),
            headers: headers,
          ).timeout(timeoutDuration);
        }
      }
    } catch (_) {}

    return _cachedTestCookie;
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'User-Agent': mobileUserAgent,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_cachedTestCookie != null && _cachedTestCookie!.isNotEmpty) {
      headers['Cookie'] = '__test=$_cachedTestCookie';
    }
    return headers;
  }

  List<String> _getEndpointCandidates() {
    final candidates = <String>[];

    // In debug / local testing, also test local XAMPP endpoints so admin on localhost sees ratings instantly
    if (kDebugMode) {
      candidates.add('http://10.0.2.2/cookmate-admin/api/ratings/submit.php'); // Android Emulator
      candidates.add('http://localhost/cookmate-admin/api/ratings/submit.php'); // iOS / Desktop / macOS
      candidates.add('http://127.0.0.1/cookmate-admin/api/ratings/submit.php');
      candidates.add('http://10.0.2.2:80/cookmate-admin/api/ratings/submit.php');
      candidates.add('http://localhost:80/cookmate-admin/api/ratings/submit.php');
    }

    // Always include production server endpoint
    if (!candidates.contains(AppConstants.apiRatingsSubmitEndpoint)) {
      candidates.add(AppConstants.apiRatingsSubmitEndpoint);
    }

    return candidates;
  }

  @override
  Future<bool> submitRating({
    required int stars,
    required String category,
    required String feedbackText,
    String? userName,
    String? userEmail,
    String? deviceInfo,
    String appVersion = '2.0.0',
  }) async {
    final payload = json.encode({
      'stars': stars,
      'category': category,
      'feedback_text': feedbackText,
      'user_name': userName ?? 'Food CHART User',
      'user_email': userEmail,
      'device_info': deviceInfo,
      'app_version': appVersion,
    });

    final endpoints = _getEndpointCandidates();
    bool anySuccess = false;

    for (final url in endpoints) {
      try {
        final isInfinityFree = url.contains('.free.nf') ||
            url.contains('infinityfree') ||
            url.contains('cookmate') ||
            url.contains('foodchart') ||
            url.contains('foodcart');
        if (isInfinityFree) {
          await _ensureInfinityFreeCookie();
        }

        final headers = _buildHeaders();
        final uri = Uri.parse(url);
        final response = await client.post(uri, headers: headers, body: payload).timeout(
          const Duration(seconds: 8),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic> && data['status'] == 'success') {
            anySuccess = true;
            // In debug mode, if local succeeded, we can still attempt live, but any success counts!
            if (!kDebugMode) {
              return true;
            }
          }
        }
      } catch (_) {
        // Continue to next candidate
      }
    }

    return anySuccess;
  }
}
