import 'dart:convert';
import 'dart:io';
import 'package:cr_analyze_app/utils/env.dart';
import 'package:http/http.dart' as http;

Future<void> _hit(String label, String path) async {
  final url = Uri.parse('https://proxy.royaleapi.dev/v1$path');
  final res = await http.get(url, headers: {
    'Authorization': 'Bearer ${Env.crApiToken}',
    'Accept': 'application/json',
  });
  stdout.writeln('=== $label HTTP ${res.statusCode} ===');
  if (res.statusCode == 200) {
    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (j['items'] as List? ?? []).cast<Map<String, dynamic>>();
    stdout.writeln('${items.length} items');
    for (final p in items.take(5)) {
      stdout.writeln('  ${p['name']} (${p['tag']}) ${p['trophies'] ?? p['eloRating'] ?? ''}');
    }
  } else {
    stdout.writeln(res.body.substring(0, res.body.length.clamp(0, 200)));
  }
  stdout.writeln('');
}

Future<void> main() async {
  // Locations listesinden bir USA/TR ID al
  final locUrl = Uri.parse('https://proxy.royaleapi.dev/v1/locations?limit=300');
  final locRes = await http.get(locUrl, headers: {
    'Authorization': 'Bearer ${Env.crApiToken}',
  });
  final locs = (jsonDecode(locRes.body)['items'] as List).cast<Map<String, dynamic>>();
  final tr = locs.firstWhere((l) => l['name'] == 'Turkey', orElse: () => {});
  final us = locs.firstWhere((l) => l['name'] == 'United States', orElse: () => {});
  stdout.writeln('TR id: ${tr['id']}');
  stdout.writeln('US id: ${us['id']}');
  stdout.writeln('');

  await _hit('TR rankings', '/locations/${tr['id']}/rankings/players?limit=5');
  await _hit('US rankings', '/locations/${us['id']}/rankings/players?limit=5');
  await _hit('TR pol-seasons', '/locations/${tr['id']}/pathoflegend/players?limit=5');
  await _hit('Global tournaments', '/tournaments?name=CRL&limit=3');
}
