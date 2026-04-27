import '../api/cr_api_client.dart';

/// Path of Legends siralarindan pro/yari-pro tag listesi cikar.
/// Birden fazla bolge desteklenir.
class ProPlayerList {
  static const Map<String, String> regions = {
    // location id -> human label
    '57000239': 'Turkey',
    '57000249': 'United States',
    '57000098': 'France',
    '57000094': 'Germany',
    '57000130': 'Italy',
    '57000196': 'Spain',
    '57000027': 'Brazil',
    '57000182': 'Russia',
  };

  final CRApiClient _api;

  ProPlayerList(this._api);

  /// Birden fazla bolgeden top N tag'leri al, dedupe et.
  Future<List<String>> collectTags({
    List<String>? regionIds,
    int perRegion = 50,
  }) async {
    final regions = regionIds ?? ProPlayerList.regions.keys.toList();
    final tags = <String>{};
    for (final r in regions) {
      try {
        final list = await _api.getPathOfLegendsRanking(r, limit: perRegion);
        for (final p in list) {
          final tag = p['tag'] as String?;
          if (tag != null && tag.isNotEmpty) tags.add(tag);
        }
      } catch (_) {
        // bolge yok / hata, gec
      }
    }
    return tags.toList();
  }
}
