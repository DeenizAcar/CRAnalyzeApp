// Hizli smoke test: token + proxy calisiyor mu?
// Calistirma: dart run tool/smoke_test.dart <player_tag>
// Ornek: dart run tool/smoke_test.dart "#9CG28PRR"

import 'dart:io';

import 'package:cr_analyze_app/data/api/cr_api_client.dart';
import 'package:cr_analyze_app/data/api/supercell_api_client.dart';
import 'package:cr_analyze_app/utils/env.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Kullanim: dart run tool/smoke_test.dart <player_tag>');
    stderr.writeln('Ornek:   dart run tool/smoke_test.dart "#9CG28PRR"');
    exit(64);
  }

  final tag = args.first;
  final baseUrl = Env.crApiBaseUrl ?? SupercellApiClient.royaleApiProxyBaseUrl;

  stdout.writeln('Base URL : $baseUrl');
  stdout.writeln('Tag      : $tag');
  stdout.writeln('---');

  final client = SupercellApiClient(
    token: Env.crApiToken,
    baseUrl: baseUrl,
  );

  try {
    stdout.writeln('Oyuncu cekiliyor...');
    final player = await client.getPlayer(tag);
    stdout.writeln('  -> ${player.name} (${player.tag}) — ${player.trophies} trophies');
    stdout.writeln('  -> Koleksiyon: ${player.cardCollection.length} kart');
    if (player.currentDeck != null) {
      stdout.writeln('  -> Mevcut deste (avg elixir ${player.currentDeck!.averageElixir.toStringAsFixed(1)}):');
      for (final c in player.currentDeck!.cards) {
        stdout.writeln('       - $c');
      }
    }

    stdout.writeln('');
    stdout.writeln('Battlelog cekiliyor...');
    final battles = await client.getBattleLog(tag);
    stdout.writeln('  -> ${battles.length} mac bulundu');
    for (final b in battles.take(3)) {
      stdout.writeln('     ${b.battleTime} | ${b.type} | ${b.playerCrowns}-${b.opponentCrowns} | rakip: ${b.opponentTag}');
    }

    stdout.writeln('');
    stdout.writeln('SMOKE TEST OK');
  } on CRApiException catch (e) {
    stderr.writeln('API hatasi: $e');
    exit(1);
  } catch (e, st) {
    stderr.writeln('Beklenmeyen hata: $e');
    stderr.writeln(st);
    exit(2);
  } finally {
    await client.dispose();
  }
}
