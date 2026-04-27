// MetaScraper smoke testi.
// dart run tool/smoke_meta_scraper.dart

import 'dart:io';

import 'package:cr_analyze_app/data/api/supercell_api_client.dart';
import 'package:cr_analyze_app/data/card_catalog.dart';
import 'package:cr_analyze_app/data/meta_scraper.dart';
import 'package:cr_analyze_app/utils/env.dart';

Future<void> main() async {
  // 1) Resmi API'den kart kataloğunu yükle (kart adları için)
  final api = SupercellApiClient(
    token: Env.crApiToken,
    baseUrl: Env.crApiBaseUrl ?? SupercellApiClient.royaleApiProxyBaseUrl,
  );
  await CardCatalog.load(api);
  await api.dispose();

  final scraper = MetaScraper(availableCardNames: CardCatalog.allNames);

  try {
    stdout.writeln('Top meta desteler cekiliyor (Ranked, son 7 gun)...');
    final decks = await scraper.fetchTopRanked(limit: 20);
    stdout.writeln('${decks.length} deste bulundu.');
    stdout.writeln('');
    for (final d in decks.take(10)) {
      stdout.writeln('${d.name} (${d.archetype})');
      stdout.writeln('  ${d.cardNames.join(', ')}');
    }
  } finally {
    scraper.dispose();
  }
}
