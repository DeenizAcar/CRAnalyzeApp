import '../static/meta_decks.dart';

/// 6 saatlik meta deste cache'i. Native: dosya, web: localStorage.
abstract class MetaCache {
  /// Cache'ten oku. Null donerse expired ya da yok.
  Future<List<MetaDeck>?> read({Duration ttl = const Duration(hours: 6)});

  /// Yeni meta listesini kaydet (now ile timestamp ekler).
  Future<void> write(List<MetaDeck> decks);
}
