import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';

String solveChallenge(String keyHex, String ivHex, String ctHex) {
  final key = Uint8List.fromList(hex.decode(keyHex));
  final iv = Uint8List.fromList(hex.decode(ivHex));
  final ct = Uint8List.fromList(hex.decode(ctHex));
  final cipher = CBCBlockCipher(AESEngine())..init(false, ParametersWithIV(KeyParameter(key), iv));
  final out = Uint8List(16);
  cipher.processBlock(ct, 0, out, 0);
  return hex.encode(out);
}

void main() async {
  final client = http.Client();
  final headers = <String, String>{
    'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
    'Accept': 'application/json, text/html, */*',
  };
  // Check db test or time endpoint
  var response = await client.get(Uri.parse('https://foodchart.free.nf/db_test.php'), headers: headers);
  if (response.body.contains('slowAES.decrypt') && response.body.contains('toNumbers(')) {
    final reg = RegExp(r'toNumbers\("([a-f0-9]+)"\)');
    final matches = reg.allMatches(response.body).toList();
    if (matches.length >= 3) {
      final cookie = solveChallenge(matches[0].group(1)!, matches[1].group(1)!, matches[2].group(1)!);
      headers['Cookie'] = '__test=$cookie';
      response = await client.get(Uri.parse('https://foodchart.free.nf/db_test.php'), headers: headers);
    }
  }
  print('Status: ${response.statusCode}');
  print('Body: ${response.body.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ')}');
}
