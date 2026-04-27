/// Bir oyuncu icin battlelog cache'i.
///
/// Resmi API son 30 maci verir. Sessiz birikim stratejisi: her sorguda
/// gelen yeni maclari cache'e ekleriz, dedupe icin battle ID kullaniriz.
abstract class BattleCache {
  /// Bir oyuncu icin tum bilinen ham battle JSON'larini getir
  /// (newest-first siralanmis, ID'ye gore dedupe).
  Future<List<Map<String, dynamic>>> read(String playerTag);

  /// Yeni gelen maclari mevcutlarla birlestir, ID'ye gore dedupe et,
  /// kalici'ya yaz. Eklenen yeni mac sayisini dondur.
  Future<int> merge(String playerTag, List<Map<String, dynamic>> incoming);

  /// Son guncelleme zamani (yoksa null).
  Future<DateTime?> lastUpdated(String playerTag);

  /// Cache temizle (sadece debug icin).
  Future<void> clear(String playerTag);
}
