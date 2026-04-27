// /battlelog endpoint'i kac mac veriyor? Type bazinda dagilim ne?
// Filtre + ?limit gibi parametreler kabul ediliyor mu test et.
// dart run tool/inspect_battlelog_size.dart "#YUY92PP9"

import 'dart:convert';
import 'dart:io';

import 'package:cr_analyze_app/utils/env.dart';
import 'package:http/http.dart' as http;

Future<void> _hit(String label, Uri url, Map<String, String> headers) async {
  stdout.writeln('=== $label ===');
  stdout.writeln('URL: $url');
  final res = await http.get(url, headers: headers);
  stdout.writeln('HTTP ${res.statusCode}');
  if (res.statusCode == 200) {
    final list = jsonDecode(res.body) as List;
    stdout.writeln('Toplam mac: ${list.length}');
    final types = <String, int>{};
    DateTime? oldest;
    DateTime? newest;
    for (final raw in list) {
      final b = raw as Map<String, dynamic>;
      final type = b['type'] as String? ?? 'unknown';
      types[type] = (types[type] ?? 0) + 1;
      final t = b['battleTime'] as String?;
      if (t != null && t.length >= 15) {
        final iso =
            '${t.substring(0, 4)}-${t.substring(4, 6)}-${t.substring(6, 11)}:${t.substring(11, 13)}:${t.substring(13, 15)}Z';
        final dt = DateTime.tryParse(iso);
        if (dt != null) {
          if (oldest == null || dt.isBefore(oldest)) oldest = dt;
          if (newest == null || dt.isAfter(newest)) newest = dt;
        }
      }
    }
    stdout.writeln('En eski: $oldest');
    stdout.writeln('En yeni: $newest');
    final sorted = types.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sorted) {
      stdout.writeln('  ${e.key.padRight(20)} ${e.value}');
    }
  } else {
    stdout.writeln(res.body);
  }
  stdout.writeln('');
}

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Tag gerekli');
    exit(64);
  }
  final tag = args.first.startsWith('#') ? args.first : '#${args.first}';
  final encoded = Uri.encodeComponent(tag);
  final headers = {
    'Authorization': 'Bearer ${Env.crApiToken}',
    'Accept': 'application/json',
  };

  await _hit(
    'Default (no params)',
    Uri.parse('https://proxy.royaleapi.dev/v1/players/$encoded/battlelog'),
    headers,
  );

  await _hit(
    'With ?limit=100',
    Uri.parse('https://proxy.royaleapi.dev/v1/players/$encoded/battlelog?limit=100'),
    headers,
  );

  await _hit(
    'With ?type=PvP',
    Uri.parse('https://proxy.royaleapi.dev/v1/players/$encoded/battlelog?type=PvP'),
    headers,
  );

  await _hit(
    'With ?type=pathOfLegend',
    Uri.parse('https://proxy.royaleapi.dev/v1/players/$encoded/battlelog?type=pathOfLegend'),
    headers,
  );
}
