// Anti-deck oneri motoru smoke test.
// dart run tool/smoke_recommend.dart "#YUY92PP9"

import 'dart:io';

import 'package:cr_analyze_app/data/api/supercell_api_client.dart';
import 'package:cr_analyze_app/data/cache/battle_cache_factory.dart';
import 'package:cr_analyze_app/data/cache/meta_cache_factory.dart';
import 'package:cr_analyze_app/data/card_catalog.dart';
import 'package:cr_analyze_app/data/meta_provider.dart';
import 'package:cr_analyze_app/data/meta_scraper.dart';
import 'package:cr_analyze_app/engine/opponent_analyzer.dart';
import 'package:cr_analyze_app/engine/rule_based_engine.dart';
import 'package:cr_analyze_app/engine/win_condition.dart';
import 'package:cr_analyze_app/utils/env.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Tag gerekli');
    exit(64);
  }
  final client = SupercellApiClient(
    token: Env.crApiToken,
    baseUrl: Env.crApiBaseUrl ?? SupercellApiClient.royaleApiProxyBaseUrl,
  );
  final analyzer = OpponentAnalyzer(client, cache: createBattleCache());
  await CardCatalog.load(client);
  final metaProvider = MetaProvider(
    scraper: MetaScraper(availableCardNames: CardCatalog.allNames),
    cache: createMetaCache(),
  );
  final pool = await metaProvider.load();
  stdout.writeln('Meta havuz: ${pool.length} deste');
  final engine = RuleBasedEngine(pool: pool);

  try {
    final analysis = await analyzer.analyze(args.first);
    stdout.writeln('${analysis.profile.name} (${analysis.profile.tag})');
    stdout.writeln('Lokal birikim: ${analysis.rawBattleCount} mac, '
        '${analysis.totalBattles} ranked, +${analysis.newlyAddedCount} yeni');
    stdout.writeln('');

    for (final u in analysis.deckUsages) {
      final winCond = detectWinCondition(u.deck);
      stdout.writeln('=== ${u.count} kez kullandi (W:${u.wins} L:${u.count - u.wins}) ===');
      stdout.writeln('Kartlar: ${u.deck.cards.map((c) => c.name).join(', ')}');
      stdout.writeln('Win condition: $winCond');
      stdout.writeln('Avg elixir: ${u.deck.averageElixir.toStringAsFixed(1)}');
      stdout.writeln('');
      final recs = engine.recommendForDeck(u.deck, maxResults: 5);
      stdout.writeln('Anti-deck onerileri:');
      for (final r in recs) {
        final pct = (r.score * 100).toStringAsFixed(0);
        stdout.writeln('  [%$pct] ${r.deck.name} — ${r.reasoning}');
        final slotted = r.deck.slottedCards.map((c) {
          final tag = c.isEvolution ? '⭐' : c.isHero ? '👑' : '';
          return '$tag${c.name}';
        }).join(', ');
        stdout.writeln('         $slotted');
      }
      stdout.writeln('');
    }
  } finally {
    await client.dispose();
  }
}
