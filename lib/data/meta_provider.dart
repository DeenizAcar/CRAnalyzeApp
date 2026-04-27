import 'cache/meta_cache.dart';
import 'meta_scraper.dart';
import 'static/meta_decks.dart' as fallback;

/// Meta destelerini saglayan koordinator.
/// Sira: cache (taze) -> scraper -> cache yaz -> donus
/// Hata olursa: cache (eski olsa bile) -> statik fallback
class MetaProvider {
  final MetaScraper _scraper;
  final MetaCache _cache;

  MetaProvider({required MetaScraper scraper, required MetaCache cache})
      : _scraper = scraper,
        _cache = cache;

  Future<List<fallback.MetaDeck>> load({
    Duration ttl = const Duration(hours: 6),
    int limit = 50,
  }) async {
    // 1) Taze cache
    final cached = await _cache.read(ttl: ttl);
    if (cached != null && cached.isNotEmpty) return cached;

    // 2) Scrape
    try {
      final decks = await _scraper.fetchTopRanked(limit: limit);
      if (decks.isNotEmpty) {
        await _cache.write(decks);
        return decks;
      }
    } catch (_) {
      // gec
    }

    // 3) Eski cache (TTL'yi yok say)
    final stale = await _cache.read(ttl: const Duration(days: 365));
    if (stale != null && stale.isNotEmpty) return stale;

    // 4) Statik fallback
    return fallback.metaDecks;
  }
}
