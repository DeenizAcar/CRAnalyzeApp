import 'dart:convert';
import 'dart:io';
import 'package:cr_analyze_app/utils/env.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final url = Uri.parse('https://proxy.royaleapi.dev/v1/cards');
  final res = await http.get(url, headers: {
    'Authorization': 'Bearer ${Env.crApiToken}',
    'Accept': 'application/json',
  });
  stdout.writeln('HTTP ${res.statusCode}');
  if (res.statusCode == 200) {
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (j['items'] as List).cast<Map<String, dynamic>>();
    stdout.writeln('Toplam kart: ${items.length}');
    for (final c in items.take(3)) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(c));
    }
  }
}
