import 'api/cr_api_client.dart';

/// Kart adindan iconUrl'e (ve elixirCost'a) erismek icin global lookup.
/// Anti-deck onerilerinde statik kart adlarindan resim cikarmak icin kullanilir.
class CardCatalog {
  static final Map<String, _CatalogEntry> _byName = {};

  static String? iconFor(String name) => _byName[name]?.iconUrl;
  static String? evolutionIconFor(String name) => _byName[name]?.evolutionIconUrl;
  static String? heroIconFor(String name) => _byName[name]?.heroIconUrl;

  static int? elixirFor(String name) => _byName[name]?.elixirCost;
  static String? rarityFor(String name) => _byName[name]?.rarity;

  static bool get isLoaded => _byName.isNotEmpty;
  static List<String> get allNames => _byName.keys.toList();

  /// API'den tüm karta katalogunu cek ve doldur. Idempotent.
  static Future<void> load(CRApiClient api) async {
    if (_byName.isNotEmpty) return;
    final items = await api.getCardsRaw();
    for (final c in items) {
      final name = c['name'] as String?;
      if (name == null) continue;
      final icons = c['iconUrls'] as Map<String, dynamic>?;
      _byName[name] = _CatalogEntry(
        iconUrl: icons?['medium'] as String?,
        evolutionIconUrl: icons?['evolutionMedium'] as String?,
        heroIconUrl: icons?['heroMedium'] as String?,
        elixirCost: c['elixirCost'] as int?,
        rarity: c['rarity'] as String?,
      );
    }
  }
}

class _CatalogEntry {
  final String? iconUrl;
  final String? evolutionIconUrl;
  final String? heroIconUrl;
  final int? elixirCost;
  final String? rarity;
  const _CatalogEntry({
    this.iconUrl,
    this.evolutionIconUrl,
    this.heroIconUrl,
    this.elixirCost,
    this.rarity,
  });
}
