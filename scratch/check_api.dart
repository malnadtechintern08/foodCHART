import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';

String solveChallenge(String keyHex, String ivHex, String ctHex) {
  final key = Uint8List.fromList(hex.decode(keyHex));
  final iv = Uint8List.fromList(hex.decode(ivHex));
  final ct = Uint8List.fromList(hex.decode(ctHex));
  final cipher = CBCBlockCipher(AESEngine())
    ..init(false, ParametersWithIV(KeyParameter(key), iv));
  final out = Uint8List(16);
  cipher.processBlock(ct, 0, out, 0);
  return hex.encode(out);
}

Future<http.Response> sendRequest(http.Client client, Uri uri) async {
  final headers = <String, String>{
    'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Accept': 'application/json, text/html, */*',
  };
  var response = await client.get(uri, headers: headers);
  if (response.body.contains('slowAES.decrypt') && response.body.contains('toNumbers(')) {
    final reg = RegExp(r'toNumbers\("([a-f0-9]+)"\)');
    final matches = reg.allMatches(response.body).toList();
    if (matches.length >= 3) {
      final a = matches[0].group(1)!;
      final b = matches[1].group(1)!;
      final c = matches[2].group(1)!;
      final cookie = solveChallenge(a, b, c);
      headers['Cookie'] = '__test=$cookie';
      response = await client.get(uri, headers: headers);
    }
  }
  return response;
}

void main() async {
  final client = http.Client();
  try {
    final resp = await sendRequest(client, Uri.parse('https://foodchart.free.nf/api/recipes.php?limit=500'));
    print('Status: ${resp.statusCode}');
    final data = json.decode(resp.body);
    if (data is Map) {
      final count = data['count'];
      print('Count from server: $count');
      final list = data['data'] as List;
      final catCounts = <String, int>{};
      for (var r in list) {
        final cat = r['category_id']?.toString() ?? 'unknown';
        catCounts[cat] = (catCounts[cat] ?? 0) + 1;
      }
      print('Categories count: $catCounts');
      for (var r in list.take(5)) {
        print('Recipe: ${r['id']} - ${r['title']} - cat: ${r['category_id']}');
      }
    }
  } catch (e, st) {
    print('Error: $e\n$st');
  } finally {
    client.close();
  }
}
