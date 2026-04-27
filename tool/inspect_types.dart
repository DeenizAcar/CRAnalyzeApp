// Battlelog'daki tum 'type' degerlerini listele (filtre tasarimi icin).
// dart run tool/inspect_types.dart "#YUY92PP9"

import 'dart:io';

import 'package:cr_analyze_app/data/api/supercell_api_client.dart';
import 'package:cr_analyze_app/utils/env.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Kullanim: dart run tool/inspect_types.dart <player_tag>');
    exit(64);
  }

  final client = SupercellApiClient(
    token: Env.crApiToken,
    baseUrl: Env.crApiBaseUrl ?? SupercellApiClient.royaleApiProxyBaseUrl,
  );

  try {
    final battles = await client.getBattleLog(args.first);
    final counts = <String, int>{};
    for (final b in battles) {
      counts[b.type] = (counts[b.type] ?? 0) + 1;
    }
    stdout.writeln('Toplam ${battles.length} mac. Type dagilimi:');
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sorted) {
      stdout.writeln('  ${e.key.padRight(24)} ${e.value}');
    }
  } finally {
    await client.dispose();
  }
}
