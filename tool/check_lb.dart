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
  stdout.writeln('$label HTTP ${res.statusCode}');
  if (res.statusCode == 200) {
    final j = jsonDecode(res.body);
    if (j is Map && j['items'] is List) {
      final items = (j['items'] as List).take(3).toList();
      for (final i in items) {
        stdout.writeln('  ${i is Map ? i['name'] : i}');
      }
    }
  }
}

Future<void> main() async {
  await _hit('locations', '/locations');
  await _hit('global ranking pol', '/locations/global/pathoflegend/seasons');
  await _hit('rankings players', '/locations/global/rankings/players?limit=5');
  await _hit('pol seasons rankings', '/locations/global/pathoflegend/57000023/rankings/players?limit=5');
}
