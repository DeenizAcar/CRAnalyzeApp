// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

import '../static/meta_decks.dart';
import 'meta_cache.dart';
import 'meta_cache_codec.dart';

MetaCache createMetaCache() => LocalStorageMetaCache();

class LocalStorageMetaCache implements MetaCache {
  // v2: variant alani eklendi, eski cache yoksay
  static const String _key = 'crAnalyze.metaDecks.v2';

  @override
  Future<List<MetaDeck>?> read(
      {Duration ttl = const Duration(hours: 6)}) async {
    final raw = html.window.localStorage[_key];
    if (raw == null) return null;
    try {
      final doc = jsonDecode(raw) as Map<String, dynamic>;
      final ts = DateTime.tryParse(doc['savedAt'] as String? ?? '');
      if (ts == null) return null;
      if (DateTime.now().toUtc().difference(ts.toUtc()) > ttl) return null;
      final list = (doc['decks'] as List).cast<Map<String, dynamic>>();
      return list.map(metaDeckFromJson).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(List<MetaDeck> decks) async {
    final doc = {
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'decks': decks.map(metaDeckToJson).toList(),
    };
    html.window.localStorage[_key] = jsonEncode(doc);
  }
}
