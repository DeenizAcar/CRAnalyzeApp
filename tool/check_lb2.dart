import 'dart:convert';
import 'dart:io';
import 'package:cr_analyze_app/utils/env.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final url = Uri.parse('https://proxy.royaleapi.dev/v1/locations/global/rankings/players?limit=10');
  final res = await http.get(url, headers: {
    'Authorization': 'Bearer ${Env.crApiToken}',
    'Accept': 'application/json',
  });
  if (res.statusCode != 200) {
    stderr.writeln('HTTP ${res.statusCode}: ${res.body}');
    exit(1);
  }
  final j = jsonDecode(res.body) as Map<String, dynamic>;
  final items = (j['items'] as List).cast<Map<String, dynamic>>();
  stdout.writeln('Top 10 global oyuncu:');
  for (final p in items) {
    stdout.writeln('  rank ${p['rank']}: ${p['name']} (${p['tag']}) — ${p['trophies']}');
  }
}
