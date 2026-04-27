// Matchup engine smoke testi.
// dart run tool/smoke_matchup.dart "#YUY92PP9"

import 'dart:io';

import 'package:cr_analyze_app/data/api/supercell_api_client.dart';
import 'package:cr_analyze_app/data/cache/battle_cache_factory.dart';
import 'package:cr_analyze_app/data/cache/meta_cache_factory.dart';
import 'package:cr_analyze_app/data/card_catalog.dart';
import 'package:cr_analyze_app/data/harvest/matchup_store.dart';
import 'package:cr_analyze_app/data/meta_provider.dart';
import 'package:cr_analyze_app/data/meta_scraper.dart';
import 'package:cr_analyze_app/engine/matchup_engine.dart';
import 'package:cr_analyze_app/engine/matchup_scorer.dart';
import 'package:cr_analyze_app/engine/opponent_analyzer.dart';
import 'package:cr_analyze_app/utils/env.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Tag gerekli');
    exit(64);
  }
  final api = SupercellApiClient(
    token: Env.crApiToken,
    baseUrl: Env.crApiBaseUrl ?? SupercellApiClient.royaleApiProxyBaseUrl,
  );
  await CardCatalog.load(api);
  final analyzer = OpponentAnalyzer(api, cache: createBattleCache());
  final metaProvider = MetaProvider(
    scraper: MetaScraper(availableCardNames: CardCatalog.allNames),
    cache: createMetaCache(),
  );
  final pool = await metaProvider.load();
  final store = MatchupStore();
  final records = store.readAll();

  stdout.writeln('Meta havuz: ${pool.length} deste');
  stdout.writeln('Matchup DB: ${records.length} kayit');
  stdout.writeln('');

  final engine = MatchupEngine(
    pool: pool,
    scorer: MatchupScorer(records),
  );

  try {
    final analysis = await analyzer.analyze(args.first);
    stdout.writeln('${analysis.profile.name} (${analysis.profile.tag})');
    stdout.writeln('');
    for (final u in analysis.deckUsages) {
      stdout.writeln('=== Rakip destesi (${u.count} kez) ===');
      stdout.writeln('Kartlar: ${u.deck.cards.map((c) => c.name).join(", ")}');
      stdout.writeln('Avg elixir: ${u.deck.averageElixir.toStringAsFixed(1)}');
      stdout.writeln('');
      final recs = engine.recommendForDeck(u.deck, maxResults: 5);
      stdout.writeln('Anti-deck onerileri:');
      for (final r in recs) {
        final pct = (r.score * 100).toStringAsFixed(0);
        stdout.writeln('  [%$pct] ${r.deck.name} — ${r.reasoning}');
        stdout.writeln('         ${r.deck.cardNames.join(", ")}');
      }
      stdout.writeln('');
    }
  } finally {
    await api.dispose();
  }
}
