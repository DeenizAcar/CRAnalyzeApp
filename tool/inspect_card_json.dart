// Bir oyuncudan ham JSON kart verisi alip ornek goster.
// dart run tool/inspect_card_json.dart "#YUY92PP9"

import 'dart:convert';
import 'dart:io';

import 'package:cr_analyze_app/utils/env.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Kullanim: dart run tool/inspect_card_json.dart <player_tag>');
    exit(64);
  }
  final tag = args.first.startsWith('#') ? args.first : '#${args.first}';
  final url = Uri.parse(
    'https://proxy.royaleapi.dev/v1/players/${Uri.encodeComponent(tag)}',
  );
  final res = await http.get(url, headers: {
    'Authorization': 'Bearer ${Env.crApiToken}',
    'Accept': 'application/json',
  });
  if (res.statusCode != 200) {
    stderr.writeln('HTTP ${res.statusCode}: ${res.body}');
    exit(1);
  }
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  final currentDeck = (json['currentDeck'] as List).cast<Map<String, dynamic>>();
  for (final c in currentDeck) {
    stdout.writeln('--- ${c['name']} ---');
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(c));
    stdout.writeln('');
  }
}
